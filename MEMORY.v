`timescale 1ns/1ps

module MEMORY(
	clk,
	rst,
	XM_MemtoReg,
	XM_RegWrite,
	XM_MemRead,
	XM_MemWrite,
	ALUout,
	XM_RD,
	XM_MD,
	XM_swaddr,
	XM_jal,
	XM_jaladdr,
	FM_PC,

	bsy,
	haddr,
	dm_write,
	hdin,
	dm_out,

	MW_MemtoReg,
	MW_RegWrite,
	MW_ALUout,
	MDR,
	MW_RD,
	MD_jal,
	MD_jaladdr,
	res2
);
input clk, rst, XM_MemtoReg, XM_RegWrite, XM_MemRead, XM_MemWrite, dm_write,XM_jal;
input bsy;
input [31:0] ALUout, XM_MD, hdin,haddr,XM_swaddr,XM_jaladdr,FM_PC;
input [4:0] XM_RD;


output reg MW_MemtoReg, MW_RegWrite,MD_jal;
output reg [31:0]	MW_ALUout,MD_jaladdr,res2;
output reg [4:0]	MW_RD;
output [31:0] MDR, dm_out;
wire write_en;


/*================================ MEMORY_INOUTPUT ===============================*/
wire [7:0] address;
wire [31:0] din,res1;
wire rst2;

reg [31:0]sw_addr,sw_regaddr;
reg MDM_MemWrite;


assign address 	= (haddr == 32'd0) ? 8'd0 :(haddr == 32'd1) ? 8'd1 :  (bsy) ?  ALUout[9:2]: (haddr <= 32'd89478485)? 8'd0: (haddr <= 32'd178956971) ?8'd1 : 8'd3; //選擇位置
//assign address 	= (haddr == 32'b0) ? 8'd0 :  (bsy) ?  ALUout[9:2]: 8'd0; //選擇位置
assign din      = (haddr == 32'b0) ? hdin: (haddr == 32'b1) ? hdin: XM_MD;
assign dm_out = MDR;
assign write_en	= (haddr == 32'd0) ? 1 :(haddr == 32'd1) ? 1 :(!XM_MemRead && XM_MemWrite) || dm_write;
assign rst2 = rst;


DATA_MEMORY DM(
	.rst2(rst2),
	.clk(clk),
	.wea(write_en),
	.sw_regaddr(sw_regaddr),
	.sw_addr(sw_addr),
	.MDM_MemWrite(MDM_MemWrite),
	.addr(address),
	.din(din),

	.res1(res1),
	.dout(MDR)
);
always @(posedge clk) begin
	//if(rst) $display("P");
	//if(rst2) $display("R");
	//rst2 <= rst;
	//$display("~~~~ %d",XM_swaddr);
	//$display("888888888 %d",write_en);
	//$display("@////// %d -> %b",XM_jal,XM_jaladdr);
	if(FM_PC == 32'd112) begin
		$display("Hoor2 %d",res1);

		//$finish;
	end
	res2 <= res1;
	$display("Now Count = %d",haddr);
	$display("din in MEM = %d",din);
end

always @(posedge clk or posedge rst) begin
	//$display("ALUout[9:2] = %d",ALUout[9:2]);
	//$display("ALUout = %d",ALUout);
	if (rst) begin
		sw_regaddr			<= 5'd0;
		sw_addr 			<= 32'd0;
		MW_MemtoReg 		<= 1'b0;
		MW_RegWrite 		<= 1'b0;
		MW_ALUout 			<= 0;
		MDM_MemWrite		<= 0;
		MW_RD 				<= XM_RD;
		MD_jaladdr 			<= 32'd0;
		MD_jal  			<= 0;
	end
	else if (XM_MemRead) begin // lw
		MW_MemtoReg 		<= XM_MemtoReg;
		MW_RegWrite 		<= XM_RegWrite;
		MW_ALUout			<= MDR;
		MW_RD 				<= XM_RD;
		sw_regaddr			<= 5'd0;
		sw_addr 			<= 32'd0;
		MDM_MemWrite		<= 0;
		MD_jaladdr 			<= 32'd0;
		MD_jal  			<= 0;
		//$display("    MDR in Mem <= %d",MDR);
	end
	else if (XM_MemWrite) begin // sw
		MW_MemtoReg 		<= XM_MemtoReg;
		MW_RegWrite 		<= XM_RegWrite;
		MW_ALUout			<= 32'd0;
		MW_RD 				<= 5'd0;
		sw_regaddr			<= XM_swaddr;
		sw_addr 			<= ALUout[9:2];
		MDM_MemWrite		<= 1;
		MD_jaladdr 			<= 32'd0;
		MD_jal  			<= 0;
		//$display("    ALUout in Mem <= %d",ALUout);
		//$display("    XM_MemWrite in Mem <= %d",XM_MemWrite);
		//$display("    XM_RD in Mem <= %d",XM_RD);
	end
	else if (XM_jal) begin 	// jal
		MW_MemtoReg 		<= XM_MemtoReg;
		MW_RegWrite 		<= XM_RegWrite;
		MW_ALUout			<= ALUout;
		MW_RD 				<= 5'd31;
		sw_regaddr			<= 32'd0;
		sw_addr 			<= 32'd0;
		MDM_MemWrite		<= 0;
		MD_jaladdr 			<= XM_jaladdr;
		MD_jal  			<= XM_jal;
		//$display("    ALUout in Mem <= %d",ALUout);
		//$display("    XM_MemWrite in Mem <= %d",XM_MemWrite);
		//$display("    XM_RD in Mem <= %d",XM_RD);
	end
	else begin 
		MW_MemtoReg 		<= XM_MemtoReg;
		MW_RegWrite 		<= XM_RegWrite;
		MW_ALUout			<= ALUout;
		sw_regaddr			<= XM_swaddr;
		sw_addr 			<= 32'd0;
		MDM_MemWrite		<= 0;
		MD_jaladdr 			<= 32'd0;
		MD_jal  			<= 0;
		//$display("    [Mem] din is %d",din);
		//$display("    addr = %d",address);
		$display("    ALUout in Mem <= %d",ALUout);
		MW_RD 				<= XM_RD;
	end
end

endmodule
