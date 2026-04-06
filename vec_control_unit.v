//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/22/2026 06:01:27 PM
// Design Name: 
// Module Name: vec_control_unit
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

module vec_control_unit (
    input  wire [31:0] instruction,
    output wire [4:0]  rs1,           // source register 1
    output wire [4:0]  rs2,           // source register 2
    output wire [4:0]  rd,            // destination register
    output wire [2:0]  funct3,        // operation type
    output reg         write_enable   // save result to regfile?
);

    // slice fields directly from instruction
    assign rs1    = instruction[19:15];
    assign rs2    = instruction[24:20];
    assign rd     = instruction[11:7];
    assign funct3 = instruction[14:12];

    // opcode check - only act on vector instructions
    always @(*) begin
        if (instruction[6:0] == 7'b1010111)
            write_enable = 1;
        else
            write_enable = 0;
    end

endmodule

