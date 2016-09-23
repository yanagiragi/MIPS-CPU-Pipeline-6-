`timescale 1ns/1ps

`define IDLE	(2'b00)
`define RUN		(2'b01)

module CPU(
	clk,
	rst,
	start,
	wen,
	haddr,			//
	hdin,			// input : datain
	bsy,
	//Product_Valid, 	// control flag for final 7 segment display
	dout 			// final result pass to top.v
);

input clk, rst, wen, start;
input [31:0] haddr;
input [31:0] hdin;
output reg bsy;
output [31:0] dout;

reg [31:0] res3;
wire [31:0] res2;

/*================================ MEMORY_INOUTPUT ===============================*/
wire ir_write;
wire [31:0] im_out, dm_out;
reg [31:0] haddr_reg;

//assign ir_write = (haddr[31:10] == 22'b0100_0000_0000_0000_0000_00) ? wen : 1'b0;
//assign dm_write = (haddr[31:10] == 22'b0100_0000_0000_0000_0000_01) ? wen : 1'b0;

wire [31:0] reg_dout;

// ORIGINAL TA VERSION ( dout != reg )
assign dout = dm_out;//將結果送到TOP


/*============================  Finite State Machine  ============================*/

reg [1:0] curr_state;
reg [31:0] cycles;

// FSM state reg
always @(posedge clk or posedge rst)
begin
	if(rst)
		curr_state <= `IDLE;
	else begin
		case(curr_state)
			`IDLE: 
				if(start) 
					curr_state <= `RUN;
				else
					curr_state <= `IDLE;
			`RUN:
				if(FD_IR==32'h00000030/*cycles>32'd250*/) begin
					curr_state <= `IDLE;
					//$finish;
				end
				else
					curr_state <= `RUN;
			default:
					curr_state <= curr_state;
		endcase
	end
end

// Cycle counter 
always @(posedge clk)
begin
	if(curr_state == `RUN)
		cycles <= cycles + 1'b1;
	else
		cycles <= 32'd0;
end

//bsy signal
always @(posedge clk or posedge rst)
begin
	if(rst)
		bsy <= 1'b0;
	else if(start&&!bsy)
		bsy <= 1'b1;
	else if(curr_state==`IDLE)
		bsy <= 1'b0;
end

/*============================== INSTRUCTION_FETCH  ==============================*/
wire [31:0] reg29;

// INSTRUCTION_FETCH wires
wire [31:0] FD_PC, FD_IR,FM_PC;

// INSTRUCTION_DECODE wires
wire DX_MemtoReg, DX_RegWrite, DX_MemRead, DX_MemWrite, DX_jump, DX_branch,DX_jal;
wire [31:0] DX_JT, DX_PC, DX_NPC, A, B, DX_MD,DX_swaddr,DX_jaladdr;
wire [15:0] imm;
wire [4:0] DX_RD;
wire [2:0] ALUctr;

// EXECUTION wires
wire XM_MemtoReg, XM_RegWrite, XM_MemRead, XM_MemWrite, XM_branch,XM_jal;
wire [31:0] XM_ALUout,XM_ALUout_DMEM, XM_BT, XM_MD,XM_swaddr,XM_jaladdr;
wire [4:0] XM_RD;

// DATA_MEMORY wires
wire MW_MemtoReg, MW_RegWrite,MD_jal;
wire [31:0] 	MDR, MW_ALUout,MD_jaladdr;
wire [5-1:0]	MW_RD;


INSTRUCTION_FETCH IF(
	.clk(clk),
	.rst(rst),
	.jump(DX_jump),
	.branch(XM_branch),
	.jump_addr(DX_JT),
	.branch_addr(XM_BT),
	.MD_jal(MD_jal),
	.MD_jaladdr(MD_jaladdr),
	.FM_PC(FM_PC),

	.curr_state(curr_state),

	//.haddr(haddr),
	.ir_write(1'b0),
	.hdin(hdin),
	.im_out(im_out),

	.PC(FD_PC),
	.IR(FD_IR)
);

/*============================== INSTRUCTION_DECODE ==============================*/


INSTRUCTION_DECODE ID(
	.clk(clk),
	.rst(rst),
	.PC(FD_PC),
	.IR(FD_IR),
	.MW_MemtoReg(MW_MemtoReg),
	.MW_RegWrite(MW_RegWrite),
	.MW_RD(MW_RD),
	.MDR(MDR),
	.MW_ALUout(MW_ALUout),

//	.reg_addr(haddr_reg), // for debug
//	.reg_dout(reg_dout),  // for debug
	.reg29(reg29),        // for debug
	.curr_state(curr_state),

	.MemtoReg(DX_MemtoReg),
	.RegWrite(DX_RegWrite),
	.MemRead(DX_MemRead),
	.MemWrite(DX_MemWrite),
	.branch(DX_branch),
	.jump(DX_jump),
	.ALUctr(ALUctr),
	.JT(DX_JT),
	.DX_PC(DX_PC),
	.NPC(DX_NPC),
	.A(A),
	.B(B),
	.imm(imm),
	.RD(DX_RD),
	.MD(DX_MD),
	.DX_swaddr(DX_swaddr),
	.DX_jal(DX_jal),
	.DX_jaladdr(DX_jaladdr)
);

/*==============================     EXECUTION  	==============================*/


EXECUTION EXE(
	.clk(clk),
	.rst(rst),
	.DX_MemtoReg(DX_MemtoReg),
	.DX_RegWrite(DX_RegWrite),
	.DX_MemRead(DX_MemRead),
	.DX_MemWrite(DX_MemWrite),
	.DX_branch(DX_branch),
	.ALUctr(ALUctr),
	.NPC(DX_NPC),
	.A(A),
	.B(B),
	.imm(imm),
	.DX_RD(DX_RD),
	.DX_MD(DX_MD),
	.DX_swaddr(DX_swaddr),
	.DX_jal(DX_jal),
	.DX_jaladdr(DX_jaladdr),

	.XM_MemtoReg(XM_MemtoReg),
	.XM_RegWrite(XM_RegWrite),
	.XM_MemRead(XM_MemRead),
	.XM_MemWrite(XM_MemWrite),
	.XM_branch(XM_branch),
	.ALUout(XM_ALUout),
	.XM_RD(XM_RD),
	.XM_MD(XM_MD),
	.XM_BT(XM_BT),
	.XM_swaddr(XM_swaddr),
	.XM_jaladdr(XM_jaladdr),
	.XM_jal(XM_jal)
);

/*==============================     DATA_MEMORY	==============================*/


MEMORY MEM(
	.clk(clk),
	.rst(rst),
	.XM_MemtoReg(XM_MemtoReg),
	.XM_RegWrite(XM_RegWrite),
	.XM_MemRead(XM_MemRead),
	.XM_MemWrite(XM_MemWrite),
	.ALUout(XM_ALUout),
	.XM_RD(XM_RD),
	.XM_MD(XM_MD),
	.XM_swaddr(XM_swaddr),
	.XM_jaladdr(XM_jaladdr),
	.XM_jal(XM_jal),
	.FM_PC(FM_PC),

	.bsy(bsy),
	.haddr(haddr),
	.dm_write(wen),
	.hdin(hdin),
	.dm_out(dm_out),

	.MW_MemtoReg(MW_MemtoReg),
	.MW_RegWrite(MW_RegWrite),
	.MW_ALUout(MW_ALUout),
	.MDR(MDR),
	.MW_RD(MW_RD),
	.MD_jal(MD_jal),
	.MD_jaladdr(MD_jaladdr),
	.res2(res2)
);

/*==============================     WRITE_BACK		==============================*/

endmodule
