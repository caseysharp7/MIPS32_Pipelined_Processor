`timescale 1ns / 1ps

module EX_pipe_stage(
    input [31:0] id_ex_instr,
    input [31:0] reg1, reg2,
    input [31:0] id_ex_imm_value,
    input [31:0] ex_mem_alu_result,
    input [31:0] mem_wb_write_back_result,
    input id_ex_alu_src,
    input [1:0] id_ex_alu_op,
    input [1:0] Forward_A, Forward_B,
    output [31:0] alu_in2_out,
    output [31:0] alu_result
    );
    wire [31:0] temp_mux4_1;
    wire [31:0] temp_mux4_2;
    wire [31:0] temp_mux2_1;
    wire [3:0] ALU_Control;
    
    mux4 #(.mux_width(32)) mux4_1
    (   .a(reg1),
        .b(mem_wb_write_back_result),
        .c(ex_mem_alu_result),
        .d(32'b0),
        .sel(Forward_A),
        .y(temp_mux4_1));
    
    mux4 #(.mux_width(32)) mux4_2
    (   .a(reg2),
        .b(mem_wb_write_back_result),
        .c(ex_mem_alu_result),
        .d(32'b0),
        .sel(Forward_B),
        .y(temp_mux4_2));
    
    assign alu_in2_out = temp_mux4_2;
    
    mux2 #(.mux_width(32)) mux2_1 
    (   .a(temp_mux4_2),
        .b(id_ex_imm_value),
        .sel(id_ex_alu_src),
        .y(temp_mux2_1));
    
    ALUControl ALU_Control_unit(
        .ALUOp(id_ex_alu_op),
        .Function(id_ex_instr[5:0]),
        .ALU_Control(ALU_Control));
    
    ALU alu_inst (
        .a(temp_mux4_1),
        .b(temp_mux2_1),
        .alu_control(ALU_Control),
        .zero(zero),
        .alu_result(alu_result));
    
endmodule