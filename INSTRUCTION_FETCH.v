`timescale 1ns/1ps


`define IDLE	(2'b00)
`define RUN		(2'b01)

module INSTRUCTION_FETCH(
	clk,
	rst,
	jump,
	branch,
	jump_addr,
	branch_addr,
	MD_jal,
	MD_jaladdr,
	curr_state,
	ir_write,
	hdin,
	im_out,
	FM_PC,
	PC,
	IR
);

input clk, rst, jump, branch, ir_write,MD_jal;
input [31:0] jump_addr, branch_addr/*, haddr*/, hdin,MD_jaladdr;
input [1:0] curr_state;

output reg 	[31:0] PC, IR, FM_PC;
output [31:0] im_out;

wire [31:0] instruction;
wire rst1;

/*================================ MEMORY_INOUTPUT ===============================*/
wire [7:0] address;

assign rst1 = rst;
assign address 	= PC[9:2];
assign im_out = instruction;

INSTRUCTION_MEMORY IM(
	.rst1(rst1),
	.clk(clk),
	.wea(1'b0),
	.addr(address),
	.din(32'b0),
	.dout(instruction)
);

always @(posedge clk or posedge rst) begin
	//PC <= 32'd0;
	//IR <= 32'd0;
	end
	
// instructions
always @(posedge clk or posedge rst)
begin
	if(rst)begin
		PC <= 32'd0;
		IR <= 32'd0;
		FM_PC <= 32'd0;
	end 
	else begin
		PC <= (curr_state==`RUN)?( (jump)?jump_addr:((branch)?branch_addr:((MD_jal)?MD_jaladdr+'d4:(PC+'d4)))) :32'h0 ;
		FM_PC <= PC;
		IR <= instruction;
	end
end

endmodule

