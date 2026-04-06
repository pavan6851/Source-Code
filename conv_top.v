`timescale 1ns / 1ps
module conv_top (
    input  wire        clk,
    input  wire        reset,
    output wire        done,
    output wire [7:0]  out0, out1, out2,
    output wire [7:0]  out3, out4, out5,
    output wire [7:0]  out6, out7, out8
);

    wire [31:0] instruction;
    wire [31:0] vmac_result;
    wire [31:0] reg_write_data;
    wire [4:0]  reg_write_addr;
    wire        reg_force_write;

    vec_processor VP (
        .clk             (clk),
        .reset           (reset),
        .instruction     (instruction),
        .reg_force_write (reg_force_write),
        .reg_write_addr  (reg_write_addr),
        .reg_write_data  (reg_write_data),
        .debug_result    (vmac_result)
    );

    conv_controller CTRL (
        .clk             (clk),
        .reset           (reset),
        .vmac_result     (vmac_result),
        .instruction     (instruction),
        .reg_write_data  (reg_write_data),
        .reg_write_addr  (reg_write_addr),
        .reg_force_write (reg_force_write),
        .op0(out0), .op1(out1), .op2(out2),
        .op3(out3), .op4(out4), .op5(out5),
        .op6(out6), .op7(out7), .op8(out8),
        .done            (done)
    );

endmodule
