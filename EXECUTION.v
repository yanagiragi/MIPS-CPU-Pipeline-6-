`timescale 1ns/1ps

module EXECUTION(
	clk,
	rst,
	DX_MemtoReg,
	DX_RegWrite,
	DX_MemRead,
	DX_MemWrite,
	DX_branch,
	ALUctr,
	NPC,
	A,
	B,
	imm,
	DX_RD,
	DX_MD,
	DX_swaddr,
	DX_jal,
	DX_jaladdr,

	XM_MemtoReg,
	XM_RegWrite,
	XM_MemRead,
	XM_MemWrite,
	XM_branch,
	ALUout,
	XM_RD,
	XM_MD,
	XM_BT,
	XM_swaddr,
	XM_jal,
	XM_jaladdr
);
input clk, rst, DX_MemtoReg, DX_RegWrite, DX_MemRead, DX_MemWrite, DX_branch,DX_jal;
input [2:0] ALUctr;
input [31:0] NPC, A, B, DX_MD,DX_swaddr,DX_jaladdr;
input [15:0]imm;
input [4:0] DX_RD;

output reg XM_MemtoReg, XM_RegWrite, XM_MemRead, XM_MemWrite, XM_branch,XM_jal;
output reg [31:0]ALUout, XM_BT, XM_MD,XM_swaddr,XM_jaladdr;
output reg [4:0] XM_RD;

always @(posedge clk or posedge rst)
begin
	if(rst) begin
		XM_swaddr	<= 32'd0;
		XM_MemtoReg	<= 1'b0;
		XM_RegWrite	<= 1'b0;
		XM_MemRead 	<= 1'b0;
		XM_MemWrite	<= 1'b0;
		XM_branch	<= 1'b0;
		XM_jal  	<= 1'd0;
		XM_jaladdr  <= 32'd0;
	end else begin
		XM_swaddr	<= DX_swaddr;
		XM_MemtoReg	<= DX_MemtoReg;
		XM_RegWrite	<= DX_RegWrite;
		XM_MemRead 	<= DX_MemRead;
		XM_MemWrite	<= DX_MemWrite;
		XM_RD 	  	<= DX_RD;
		XM_MD 	  	<= DX_MD;
	   	XM_branch	<= ((ALUctr==6) && (A == B) && DX_branch);
		XM_BT		<= NPC + { { 14{imm[15]}}, imm, 2'b0};
		XM_jal 		<= DX_jal;
		XM_jaladdr 		<= DX_jaladdr;
	end
end

always @(posedge clk or posedge rst)
begin
	if(rst) begin
		ALUout <= 32'd0;
	end
	else begin
		case(ALUctr)
			3'd2: begin //and
	    		ALUout <= A & B;
	    	end
		  	3'd0: begin//add //lw //sw
	     		ALUout <= A + B;
	     	end
		  	3'd1: //sub 
		  		begin
	    			ALUout <= A - B;
	    		end
	  		3'd3: //or
	    	 	ALUout <= A | B;
	  		3'd4: //slt
		     	ALUout <= (A >= B) ? 32'b0 : 32'b1;
	  		3'd5: //mul
	     		ALUout <= A * B;
	  		3'd6: //branch
		     	ALUout <= 32'd0;

			default: begin
	 			ALUout <= 32'd0;
	    	end
		endcase
		
	end
end
endmodule