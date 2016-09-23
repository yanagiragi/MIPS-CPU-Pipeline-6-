`timescale 1ns/1ps

`define IDLE	(2'b00)
`define RUN		(2'b01)

module INSTRUCTION_DECODE(
	clk,
	rst,
	PC,
	IR,
	MW_MemtoReg,
	MW_RegWrite,
	MW_RD,
	MDR,
	MW_ALUout,

	reg29,
	curr_state,

	MemtoReg,
	RegWrite,
	MemRead,
	MemWrite,
	branch,
	jump,
	ALUctr,
	JT,
	DX_PC,
	NPC,
	A,
	B,
	imm,
	RD,
	MD,
	DX_swaddr,
	DX_jal,
	DX_jaladdr
);
input clk, rst, MW_MemtoReg, MW_RegWrite;
input [31:0] IR, PC, MDR, MW_ALUout;
input [4:0]  MW_RD;

output reg MemtoReg, RegWrite, MemRead, MemWrite, branch, jump,DX_jal;
output reg [2:0] ALUctr;
output reg [31:0]JT, DX_PC, NPC, A, B, MD,DX_swaddr,DX_jaladdr;
output reg [15:0]imm;
output reg [4:0] RD;

input [1:0] curr_state;

output [31:0] reg29;                  // for debug   
assign reg29 = REG['d10];               // for debug

reg [31:0] REG [0:31];
reg [31:0]i;

initial begin
	for (i=0; i<32; i=i+1)
		REG[i] = 32'd0;
end


/*always @(posedge clk) begin
	if(MW_RegWrite&&curr_state==`RUN) begin
		REG[MW_RD] = (MW_MemtoReg)? MDR : MW_ALUout;
		$display("[write] RD = %d",MW_RD);
		$display("REG[%d] = %d",8,REG[8]);
		$display("REG[%d] = %d",9,REG[9]);
		$display("REG[%d] = %d",10,REG[10]);
		$display("REG[%d] = %d",11,REG[11]);
		$display("REG[%d] = %d",31,REG[31]);
		//$display("REG[%d] = %d",31,REG[31]);
	end
end*/

always @(posedge clk or posedge rst)
begin
	if(rst) begin
		jump<=1'b0;
		JT 	<=32'b0;
		
	end 
	else begin
		RD 	<=(IR[31:26]==6'd35 || IR[31:26]==6'd8 )?IR[20:16]:IR[15:11];
		MD 	<=REG[IR[20:16]];
		imm <=IR[15:0];
	  	DX_PC<=PC;
		NPC	<=PC;
		jump<=(IR[31:26]==6'd2 || (IR[31:26]==6'd0 && IR[5:0]==6'd8) );
		JT	<=(IR[31:26]==6'd0 && IR[5:0]==6'd8)? REG[IR[25:21]]<<2 :{PC[31:28], IR[25:0], 2'b0};
		// JT store value of j and jr
		DX_jaladdr <= {PC[31:28], IR[25:0], 2'b0};
		DX_jal <= (IR[31:26] == 6'd3)?1:0;
	end
end

always @(posedge clk or posedge rst)
begin
   if(rst) begin
		MemtoReg<= 1'b0;
		RegWrite<= 1'b0;
		MemRead <= 1'b0;
		MemWrite<= 1'b0;
		branch  <= 1'b0;
		DX_swaddr <= 32'd0;
   end else begin
   		case( IR[31:26] )
		6'd0:
			begin  // R-type
				A 		<= REG[IR[25:21]];
				B 		<= REG[IR[20:16]];
				MemtoReg<= 1'b0;
				RegWrite<= 1'b1;
				MemRead <= 1'b0;
				MemWrite<= 1'b0;
				branch  <= 1'b0;
			    case(IR[5:0])
			    	//funct
				    6'd32://add
				        ALUctr <= 3'd0;				    
				    6'd34://sub
				       	ALUctr <= 3'd1;				    
				    6'd36://and
				        ALUctr <= 3'd2;
				    6'd37://or
				        ALUctr <= 3'd3;
				    6'd42://slt
				    	ALUctr <= 3'd4;	
					6'd1 ://mul
					     ALUctr <= 3'd5;
					//6'd8: // jr
						// ALUctr <= 3'd5;
				    default:
		   				ALUctr <= 3'd7;
		    	endcase
			end
      	6'd8 :  begin // addi
      		 A 	<=REG[IR[25:21]];
             B       <= { { 16{IR[15]} } , IR[15:0] };
             MemtoReg<= 1'b0;
             RegWrite<= 1'b1;
             MemRead <= 1'b0;
             MemWrite<= 1'b0;
             branch  <= 1'b0;
             ALUctr  <= 3'd0;
			end

		6'd35:  begin// lw
				A 		<= REG[IR[25:21]];
			    B 		<= { { 16{IR[15]} } , IR[15:0] };//sign_extend(IR[15:0]);
			    MemtoReg<= 1'b1;
			    RegWrite<= 1'b1;
			    MemRead <= 1'b1;
			    MemWrite<= 1'b0;
			    branch  <= 1'b0;
			    ALUctr  <= 3'd0;
		 	end
		6'd43:  begin// sw
				A 		<=	REG[IR[25:21]];
			    B 		<= { { 16{IR[15]} } , IR[15:0] };//sign_extend(IR[15:0]);
			    DX_swaddr <= REG[IR[20:16]];
			    MemtoReg<= 1'b0;
			    RegWrite<= 1'b0;
			    MemRead <= 1'b0;
			    MemWrite<= 1'b1;
			    branch  <= 1'b0;
			    ALUctr  <= 3'd0;
		 	end
		6'd4:   begin // beq
				A 		<= REG[IR[25:21]];
			    B 		<= REG[IR[20:16]];

			    MemtoReg<= 1'b0;
			    RegWrite<= 1'b0;
			    MemRead <= 1'b0;
			    MemWrite<= 1'b0;
			    branch  <= 1'b1;
			    ALUctr  <= 3'd6;
			end
		6'd2: begin  // j
				A 		<=REG[IR[25:21]];
			    B 		<= 32'b0;
			    MemtoReg<= 1'b0;
			    RegWrite<= 1'b0;
			    MemRead <= 1'b0;
			    MemWrite<= 1'b1;
			    branch 	<= 1'b0;
			    ALUctr  <= 3'd0;
			end
		6'd3: begin  // jal
				A 		<= PC;
			    B 		<= 32'b0;
			    MemtoReg<= 1'b0;
			    RegWrite<= 1'b1;
			    MemRead <= 1'b0;
			    MemWrite<= 1'b0;
			    branch 	<= 1'b0;
			    ALUctr  <= 3'd0;
		end
		default: begin
				A 		<= 32'b0;
			    B 		<= 32'b0;
			    MemtoReg<= 1'b0;
			    RegWrite<= 1'b0;
			    MemRead <= 1'b0;
			    MemWrite<= 1'b0;
			    branch 	<= 1'b0;
			    ALUctr  <= 3'd7;
			end
		endcase
   end
end

endmodule

