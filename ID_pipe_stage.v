`timescale 1ns / 1ps

module ID_pipe_stage(
    input  clk, reset,
    input  [9:0] pc_plus4,
    input  [31:0] instr,
    input  mem_wb_reg_write,
    input  [4:0] mem_wb_write_reg_addr,
    input  [31:0] mem_wb_write_back_data,
    input  Data_Hazard,
    input  Control_Hazard,
    output [31:0] reg1, reg2,
    output [31:0] imm_value,
    output [9:0] branch_address,
    output [9:0] jump_address,
    output branch_taken,
    output [4:0] destination_reg, 
    output mem_to_reg,
    output [1:0] alu_op,
    output mem_read,  
    output mem_write,
    output alu_src,
    output reg_write,
    output jump
    );
    wire [6:0] temp1;
    wire [6:0] temp2;

    mux2#(.mux_width(7)) data_hazard_mux(   
        .a(temp1), .b(7'b000000),
        .sel((!Data_Hazard) || Control_Hazard),
        .y(temp2)
        );

    assign mem_to_reg = temp2[6];
    assign alu_op = temp2[5:4];
    assign mem_read = temp2[3];
    assign mem_write = temp2[2];
    assign alu_src = temp2[1];
    assign reg_write = temp2[0];


    wire reg_dst;
    wire branch;
    control control(
        .reset(reset),
        .opcode(instr[31:26]), 
        .reg_dst(reg_dst), .mem_to_reg(temp1[6]), 
        .alu_op(temp1[5:4]),  
        .mem_read(temp1[3]), 
        .mem_write(temp1[2]),
        .alu_src(temp1[1]), 
        .reg_write(temp1[0]),
        .branch(branch), .jump(jump) 
        );
    
    mux2 #(.mux_width(5)) destination_reg_mux(
        .a(instr[20:16]),
        .b(instr[15:11]),
        .sel(reg_dst),
        .y(destination_reg)
        );
    
    register_file reg_file(
        .clk(clk), .reset(reset),  
        .reg_write_en(mem_wb_reg_write), 
        .reg_write_dest(mem_wb_write_reg_addr),  
        .reg_write_data(mem_wb_write_back_data),
        .reg_read_addr_1(instr[25:21]),
        .reg_read_addr_2(instr[20:16]),  
        .reg_read_data_1(reg1),  
        .reg_read_data_2(reg2) 
        );
     
     wire eq_test;
     assign eq_test = (reg1 ^ reg2) == 32'd0;
     assign branch_taken = branch && eq_test ? 1'b1 : 1'b0;
     
     sign_extend sign_ex_inst(
        .sign_ex_in(instr[15:0]),
        .sign_ex_out(imm_value)
        );
     
     assign branch_address = pc_plus4 + (imm_value << 2);
     assign jump_address = instr[25:0] << 2;

endmodule
