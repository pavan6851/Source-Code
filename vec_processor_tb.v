//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/22/2026 06:08:12 PM
// Design Name: 
// Module Name: vec_processor_tb
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
`timescale 1ns / 1ps

module vec_processor_tb;

    reg         clk;
    reg         reset;
    reg  [31:0] instruction;
    wire [31:0] debug_result;

    // instantiate the top module
    vec_processor uut (
        .clk          (clk),
        .reset        (reset),
        .instruction  (instruction),
        .debug_result (debug_result)
    );

    // clock generation - toggles every 5ns = 100MHz
    always #5 clk = ~clk;

    initial begin
        // initialise
        clk         = 0;
        reset       = 1;
        instruction = 32'b0;

        // hold reset for 2 clock cycles
        #20 reset = 0;
        #10;

        // load test values directly into registers
        // R1 = [3, 2, 1, 4] → 32'h03020104
        // R2 = [1, 2, 3, 2] → 32'h01020302
        uut.RF.registers[1] = 32'h03020104;
        uut.RF.registers[2] = 32'h01020302;

        //------------------------------------------------
        // TEST 1 - VADD
        // R3 = R1 + R2
        // expected = [4, 4, 4, 6] = 32'h04040406
        //------------------------------------------------
        instruction = 32'b0000000_00010_00001_000_00011_1010111;
        #20;
        $display("VADD result = 32'h%h (expected 32'h04040406)", debug_result);

        //------------------------------------------------
        // TEST 2 - VMUL
        // R3 = R1 × R2
        // expected = [3, 4, 3, 8] = 32'h03040308
        //------------------------------------------------
        instruction = 32'b0000000_00010_00001_001_00011_1010111;
        #20;
        $display("VMUL result = 32'h%h (expected 32'h03040308)", debug_result);

        //------------------------------------------------
        // TEST 3 - VMAC
        // R3 = (4×2) + (1×3) + (2×2) + (3×1)
        //    =   8   +   3   +   4   +   3
        //    = 18 = 32'h00000012
        //------------------------------------------------
        instruction = 32'b0000000_00010_00001_010_00011_1010111;
        #20;
        $display("VMAC result = 32'h%h (expected 32'h00000012)", debug_result);

        //------------------------------------------------
        // TEST 4 - VMAC convolution patch example
        // simulating one 3×3 convolution position
        // image patch  R4 = [2, 1, 3, 0] → 32'h02010300
        // filter       R5 = [1, 0, 2, 1] → 32'h01000201
        // expected MAC = (0×1)+(3×2)+(1×0)+(2×1) = 0+6+0+2 = 8
        //------------------------------------------------
        uut.RF.registers[4] = 32'h02010300;
        uut.RF.registers[5] = 32'h01000201;

        // VMAC R6 = R4 MAC R5
        // rs1=00100(R4), rs2=00101(R5), rd=00110(R6), funct3=010
        instruction = 32'b0000000_00101_00100_010_00110_1010111;
        #20;
        $display("VMAC conv patch = 32'h%h (expected 32'h00000008)", debug_result);

        $display("------ ALL TESTS DONE ------");
        $finish;
    end

endmodule

