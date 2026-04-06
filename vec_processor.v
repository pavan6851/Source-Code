    //////////////////////////////////////////////////////////////////////////////////
    // Company: 
    // Engineer: 
    // 
    // Create Date: 03/22/2026 06:02:52 PM
    // Design Name: 
    // Module Name: vec_processor
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
    module vec_processor (
        input  wire        clk,
        input  wire        reset,
        input  wire [31:0] instruction,
        input  wire        reg_force_write,  // NEW - force write from controller
        input  wire [4:0]  reg_write_addr,   // NEW - which register to write
        input  wire [31:0] reg_write_data,   // NEW - what data to write
        output wire [31:0] debug_result
    );
    
        wire [4:0]  rs1, rs2, rd;
        wire [2:0]  funct3;
        wire        write_enable;
        wire [31:0] v1, v2;
        wire [31:0] alu_result;
    
        // actual write enable = normal instruction write OR force write
        wire        actual_wen   = write_enable | reg_force_write;
    
        // actual write address = force address OR instruction rd
        wire [4:0]  actual_waddr = reg_force_write ? reg_write_addr : rd;
    
        // actual write data = force data OR ALU result
        wire [31:0] actual_wdata = reg_force_write ? reg_write_data : alu_result;
    
        vec_control_unit CU (
            .instruction  (instruction),
            .rs1          (rs1),
            .rs2          (rs2),
            .rd           (rd),
            .funct3       (funct3),
            .write_enable (write_enable)
        );
    
        vec_regfile RF (
            .clk          (clk),
            .reset        (reset),
            .write_enable (actual_wen),
            .write_addr   (actual_waddr),
            .write_data   (actual_wdata),
            .read_addr1   (rs1),
            .read_addr2   (rs2),
            .read_data1   (v1),
            .read_data2   (v2)
        );
    
        vec_alu ALU (
            .v1     (v1),
            .v2     (v2),
            .op     (funct3),
            .result (alu_result)
        );
    
        assign debug_result = alu_result;
    
    endmodule
    
