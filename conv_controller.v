`timescale 1ns / 1ps
module conv_controller (
    input  wire        clk,
    input  wire        reset,
    input  wire [31:0] vmac_result,
    output reg  [31:0] instruction,
    output reg  [31:0] reg_write_data,
    output reg  [4:0]  reg_write_addr,
    output reg         reg_force_write,
    output reg  [7:0]  op0, op1, op2,
    output reg  [7:0]  op3, op4, op5,
    output reg  [7:0]  op6, op7, op8,
    output reg         done
);

    reg [7:0] matrix [24:0];
    reg [7:0] filter  [8:0];

    // states - each group has: LOAD_A, LOAD_B, FIRE, WAIT
    localparam IDLE     = 5'd0;
    localparam LDA_G1   = 5'd1;   // load R1 with image row 0
    localparam LDB_G1   = 5'd2;   // load R2 with filter row 0
    localparam FIRE_G1  = 5'd3;   // fire VMAC
    localparam WAIT_G1  = 5'd4;   // wait for result
    localparam LDA_G2   = 5'd5;
    localparam LDB_G2   = 5'd6;
    localparam FIRE_G2  = 5'd7;
    localparam WAIT_G2  = 5'd8;
    localparam LDA_G3   = 5'd9;
    localparam LDB_G3   = 5'd10;
    localparam FIRE_G3  = 5'd11;
    localparam WAIT_G3  = 5'd12;
    localparam SAVE     = 5'd13;
    localparam NEXT_POS = 5'd14;
    localparam DONE_ST  = 5'd15;

    reg [4:0]  state;
    reg [1:0]  out_row, out_col;
    reg [31:0] partial1, partial2;
    reg [4:0]  out_idx;

    localparam VMAC_INSTR = 32'b0000000_00010_00001_010_00011_1010111;
    localparam NOP_INSTR  = 32'b0;

    initial begin
        matrix[0]=1;  matrix[1]=2;  matrix[2]=3;
        matrix[3]=4;  matrix[4]=5;
        matrix[5]=6;  matrix[6]=7;  matrix[7]=8;
        matrix[8]=9;  matrix[9]=10;
        matrix[10]=11; matrix[11]=12; matrix[12]=13;
        matrix[13]=14; matrix[14]=15;
        matrix[15]=16; matrix[16]=17; matrix[17]=18;
        matrix[18]=19; matrix[19]=20;
        matrix[20]=21; matrix[21]=22; matrix[22]=23;
        matrix[23]=24; matrix[24]=25;

        filter[0]=1; filter[1]=0; filter[2]=1;
        filter[3]=0; filter[4]=1; filter[5]=0;
        filter[6]=1; filter[7]=0; filter[8]=1;
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state           <= IDLE;
            out_row         <= 0;
            out_col         <= 0;
            out_idx         <= 0;
            partial1        <= 0;
            partial2        <= 0;
            done            <= 0;
            instruction     <= NOP_INSTR;
            reg_force_write <= 0;
            reg_write_addr  <= 0;
            reg_write_data  <= 0;
            op0<=0; op1<=0; op2<=0;
            op3<=0; op4<=0; op5<=0;
            op6<=0; op7<=0; op8<=0;
        end
        else begin
            case (state)

                IDLE: begin
                    done            <= 0;
                    instruction     <= NOP_INSTR;
                    reg_force_write <= 0;
                    state           <= LDA_G1;
                end

                //===================
                // GROUP 1 - row 0
                //===================
                LDA_G1: begin
                    // write image row 0 into R1
                    reg_write_addr  <= 5'd1;
                    reg_write_data  <= {
                        8'd0,
                        matrix[out_row*5 + out_col + 2],
                        matrix[out_row*5 + out_col + 1],
                        matrix[out_row*5 + out_col + 0]
                    };
                    reg_force_write <= 1;
                    instruction     <= NOP_INSTR;
                    state           <= LDB_G1;
                end

                LDB_G1: begin
                    // write filter row 0 into R2
                    reg_write_addr  <= 5'd2;
                    reg_write_data  <= {
                        8'd0,
                        filter[2],
                        filter[1],
                        filter[0]
                    };
                    reg_force_write <= 1;
                    instruction     <= NOP_INSTR;
                    state           <= FIRE_G1;
                end

                FIRE_G1: begin
                    // R1 and R2 are ready - fire VMAC
                    reg_force_write <= 0;
                    instruction     <= VMAC_INSTR;
                    state           <= WAIT_G1;
                end

                WAIT_G1: begin
                    // ALU result is now stable - capture it
                    instruction     <= NOP_INSTR;
                    partial1        <= vmac_result;
                    state           <= LDA_G2;
                end

                //===================
                // GROUP 2 - row 1
                //===================
                LDA_G2: begin
                    reg_write_addr  <= 5'd1;
                    reg_write_data  <= {
                        8'd0,
                        matrix[(out_row+1)*5 + out_col + 2],
                        matrix[(out_row+1)*5 + out_col + 1],
                        matrix[(out_row+1)*5 + out_col + 0]
                    };
                    reg_force_write <= 1;
                    instruction     <= NOP_INSTR;
                    state           <= LDB_G2;
                end

                LDB_G2: begin
                    reg_write_addr  <= 5'd2;
                    reg_write_data  <= {
                        8'd0,
                        filter[5],
                        filter[4],
                        filter[3]
                    };
                    reg_force_write <= 1;
                    instruction     <= NOP_INSTR;
                    state           <= FIRE_G2;
                end

                FIRE_G2: begin
                    reg_force_write <= 0;
                    instruction     <= VMAC_INSTR;
                    state           <= WAIT_G2;
                end

                WAIT_G2: begin
                    instruction     <= NOP_INSTR;
                    partial2        <= vmac_result;
                    state           <= LDA_G3;
                end

                //===================
                // GROUP 3 - row 2
                //===================
                LDA_G3: begin
                    reg_write_addr  <= 5'd1;
                    reg_write_data  <= {
                        8'd0,
                        matrix[(out_row+2)*5 + out_col + 2],
                        matrix[(out_row+2)*5 + out_col + 1],
                        matrix[(out_row+2)*5 + out_col + 0]
                    };
                    reg_force_write <= 1;
                    instruction     <= NOP_INSTR;
                    state           <= LDB_G3;
                end

                LDB_G3: begin
                    reg_write_addr  <= 5'd2;
                    reg_write_data  <= {
                        8'd0,
                        filter[8],
                        filter[7],
                        filter[6]
                    };
                    reg_force_write <= 1;
                    instruction     <= NOP_INSTR;
                    state           <= FIRE_G3;
                end

                FIRE_G3: begin
                    reg_force_write <= 0;
                    instruction     <= VMAC_INSTR;
                    state           <= WAIT_G3;
                end

                WAIT_G3: begin
                    // capture group 3 result then save
                    instruction     <= NOP_INSTR;
                    state           <= SAVE;
                end

                //===================
                // SAVE OUTPUT PIXEL
                //===================
                SAVE: begin
                    case (out_idx)
                        5'd0: op0 <= partial1 + partial2 + vmac_result;
                        5'd1: op1 <= partial1 + partial2 + vmac_result;
                        5'd2: op2 <= partial1 + partial2 + vmac_result;
                        5'd3: op3 <= partial1 + partial2 + vmac_result;
                        5'd4: op4 <= partial1 + partial2 + vmac_result;
                        5'd5: op5 <= partial1 + partial2 + vmac_result;
                        5'd6: op6 <= partial1 + partial2 + vmac_result;
                        5'd7: op7 <= partial1 + partial2 + vmac_result;
                        5'd8: op8 <= partial1 + partial2 + vmac_result;
                        default: ;
                    endcase
                    instruction <= NOP_INSTR;
                    state       <= NEXT_POS;
                end

                //===================
                // NEXT POSITION
                //===================
                NEXT_POS: begin
                    out_idx <= out_idx + 1;
                    if (out_col == 2) begin
                        out_col <= 0;
                        if (out_row == 2)
                            state <= DONE_ST;
                        else begin
                            out_row <= out_row + 1;
                            state   <= LDA_G1;
                        end
                    end
                    else begin
                        out_col <= out_col + 1;
                        state   <= LDA_G1;
                    end
                end

                DONE_ST: begin
                    done        <= 1;
                    instruction <= NOP_INSTR;
                end

                default: state <= IDLE;

            endcase
        end
    end

endmodule
