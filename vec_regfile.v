`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/22/2026 05:57:24 PM
// Design Name: 
// Module Name: vec_regfile
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
module vec_regfile (
    input  wire        clk,
    input  wire        reset,
    input  wire        write_enable,
    input  wire [4:0]  write_addr,      // 5-bit → 32 registers
    input  wire [31:0] write_data,      // 32-bit → 4 lanes of 8-bit
    input  wire [4:0]  read_addr1,      // source register 1
    input  wire [4:0]  read_addr2,      // source register 2
    output wire [31:0] read_data1,      // data from rs1
    output wire [31:0] read_data2       // data from rs2
);

    // 32 registers, each 32 bits wide
    reg [31:0] registers [31:0];

    // READ — instant, no clock needed, it will run once per clk cycle
    assign read_data1 = registers[read_addr1];
    assign read_data2 = registers[read_addr2];

    integer i;

    // WRITE — only on clock edge
    always @(posedge clk or posedge reset) begin // sensitivity list
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
                registers[i] <= 32'b0;
        end
        else if (write_enable) begin
            registers[write_addr] <= write_data;
        end
    end

endmodule

