`timescale 1ns / 1ps

module IF_pipe_stage(
    input clk, reset,
    input en,
    input [9:0] branch_address,
    input [9:0] jump_address,
    input branch_taken,
    input jump,
    output [9:0] pc_plus4,
    output [31:0] instr
    );
    reg [9:0] pc;
    wire [9:0] temp1;
    wire [9:0] temp2;
    
    assign temp1 = branch_taken ? branch_address : pc_plus4;
    assign temp2 = jump ? jump_address : temp1;
    always @(posedge clk or posedge reset) begin
        if(reset)
            pc <= 10'b0000000000;
        else if(en)
            pc <= temp2;
    end
    
    assign pc_plus4 = pc + 10'b0000000100;
    
    instruction_mem inst_mem (
        .read_addr(pc),
        .data(instr));
endmodule
