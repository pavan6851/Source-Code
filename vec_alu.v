`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/22/2026 05:59:39 PM
// Design Name: 
// Module Name: vec_alu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module vec_alu (
    input  wire [31:0] v1,        // source register 1 (4 x 8-bit lanes)
    input  wire [31:0] v2,        // source register 2 (4 x 8-bit lanes)
    input  wire [2:0]  op,        // operation (funct3 from instruction)
    output reg  [31:0] result     // result
);

    // split v1 into 4 lanes
    wire [7:0] a0 = v1[7:0];
    wire [7:0] a1 = v1[15:8];
    wire [7:0] a2 = v1[23:16];
    wire [7:0] a3 = v1[31:24];

    // split v2 into 4 lanes
    wire [7:0] b0 = v2[7:0];
    wire [7:0] b1 = v2[15:8];
    wire [7:0] b2 = v2[23:16];
    wire [7:0] b3 = v2[31:24];

    // intermediate multiply results (16-bit to avoid overflow)
    wire [15:0] mul0 = a0 * b0;
    wire [15:0] mul1 = a1 * b1;
    wire [15:0] mul2 = a2 * b2;
    wire [15:0] mul3 = a3 * b3;

    always @(*) begin
        case(op)

            3'b000: begin
                // VADD - add each lane separately
                result[7:0]   = a0 + b0;
                result[15:8]  = a1 + b1;
                result[23:16] = a2 + b2;
                result[31:24] = a3 + b3;
            end
            
            3'b001: begin
                // VMUL - multiply each lane separately
                // keep lower 8 bits of each 16-bit result
                result[7:0]   = mul0[7:0];
                result[15:8]  = mul1[7:0];
                result[23:16] = mul2[7:0];
                result[31:24] = mul3[7:0];
            end

            3'b010: begin
                // VMAC - multiply all lanes then accumulate into one sum
                // result is a single 32-bit number in result[31:0]
                result = mul0 + mul1 + mul2 + mul3;
            end

            default: result = 32'b0;

        endcase
    end

endmodule

