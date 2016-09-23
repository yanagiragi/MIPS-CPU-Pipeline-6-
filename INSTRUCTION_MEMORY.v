`define IM_MAX 256
`define IMSIZE 8
`timescale 1ns/1ps

module INSTRUCTION_MEMORY(
	rst1,
	clk,
	wea,
	addr,
	din,
	dout
);

input clk, wea,rst1;
input [`IMSIZE-1:0] addr;
input [31:0] din;

output [31:0] dout;

// IM_MAX = how many memory space can use
reg [31:0] instruction [0:`IM_MAX-1];
reg [31:0]i;

initial begin
	instruction[0] = 32'h00000020;								// nop;
	instruction[1] = 32'h00000020;								// nop;
	
	instruction[2] = 32'b100011_00000_01010_00000_00000_000000; // lw t10,0(0)
	instruction[3] = 32'h00000020;								// nop;
	instruction[4] = 32'h00000020;								// nop;
	
	instruction[5] = 32'b100011_00000_01011_00000_00000_000100; // lw t10,0(0)
	instruction[6] = 32'h00000020;								// nop;
	instruction[7] = 32'h00000020;								// nop;

	instruction[8] = 32'b001000_00000_01001_00000_00000_000001; // addi,t9,1
	instruction[9] = 32'h00000020;								// nop;
	instruction[10] = 32'h00000020;								// nop;
	instruction[11] = 32'h00000020;								// nop;
	
	instruction[12] = 32'b000000_01011_01001_01000_00000_101010;// slt t8,t11,t9=1
	instruction[13] = 32'h00000020;								// nop;
	instruction[14] = 32'h00000020;								// nop;
	instruction[15] = 32'h00000020;								// nop;
	instruction[16] = 32'h00000020;								// nop;
	
	instruction[19] = 32'h00000020;// beq t8,zero => jump to gcd
	instruction[18] = 32'h00000020;								// nop;
	instruction[17] = 32'b000100_01000_00000_00000_00000_001011;// beq t8,zero => jump to gcd
	//instruction[18] = 32'h00000020;								// nop;
	
	instruction[20] = 32'h00000020;								// nop;
	instruction[21] = 32'h00000020;								// nop;
	
	instruction[22] = 32'b101011_00000_01010_00000_00000_001100;// store to mem 2
	instruction[23] = 32'h00000020;								// nop;
	instruction[24] = 32'h00000020;								// nop;
	instruction[25] = 32'h00000020;								// nop;
	instruction[26] = 32'h00000020;								// nop;
	
	instruction[27] = 32'b000000_11111_00000_00000_00000_001000;// jr r31
	instruction[28] = 32'h00000020;								// nop;
	instruction[29] = 32'h00000020;								// nop;
	instruction[30] = 32'h00000020;								// nop;
	instruction[31] = 32'h00000020;								// nop;
	
	// gcd starts	
		// start swap
	instruction[32] = 32'b000000_01010_01011_01000_00000_101010; // SLT
	instruction[33] = 32'h00000020;								// nop;
	instruction[34] = 32'h00000020;								// nop;
	instruction[35] = 32'h00000020;								// nop;
	instruction[36] = 32'h00000020;								// nop;
	
	instruction[37] = 32'b000100_01000_00000_00000_00000_010000;// beq t8,zero => jump to gcd
	instruction[38] = 32'h00000020;								// nop;
	instruction[39] = 32'h00000020;								// nop;
	instruction[40] = 32'h00000020;								// nop;
	instruction[41] = 32'h00000020;								// nop;



	instruction[42] = 32'b101011_00000_01010_00000_00000_001100;// store t10 to mem[3]
	instruction[43] = 32'h00000020;								// nop;
	instruction[44] = 32'h00000020;								// nop;
	instruction[45] = 32'h00000020;								// nop;
	instruction[46] = 32'h00000020;								// nop;
	
	instruction[47] = 32'b001000_01011_01010_00000_00000_000000;// addi t10 ,t11,0
	instruction[48] = 32'h00000020;								// nop;
	instruction[49] = 32'h00000020;								// nop;
	instruction[50] = 32'h00000020;								// nop;
	instruction[51] = 32'h00000020;								// nop;

	instruction[52] = 32'b100011_00000_01011_00000_00000_001100;//lw t11,1(0);
	instruction[53] = 32'h00000020;								// nop;
	instruction[54] = 32'h00000020;								// nop;
	instruction[55] = 32'h00000020;								// nop;
	instruction[56] = 32'h00000020;								// nop;
		// end swaping

	instruction[57] = 32'b000000_01010_01011_01010_00000_100010; // sub $t10,$t10.$t11
	instruction[58] = 32'h00000020;								// nop;
	instruction[59] = 32'h00000020;								// nop;
	instruction[60] = 32'h00000020;								// nop;

	instruction[61] = 32'b000011_00000_00000_00000_00000_001011; // jal address not input
	instruction[62] = 32'h00000020;								// nop;
	instruction[63] = 32'h00000020;								// nop;
	instruction[64] = 32'h00000020;	
	instruction[65] = 32'h00000020;	
	
	instruction[66] = 32'h00000020;
	instruction[67] = 32'h00000020;
	instruction[68] = 32'h00000020;
	instruction[69] = 32'h00000030;
	instruction[70] = 32'h00000030;
	for(i=71;i< 255; i = i +1)
		instruction[i] = 32'h00000030;
end



reg [`IMSIZE-1:0] addr_reg;

// if memory can use, then direct output

assign dout = instruction[addr_reg] ;

// for outside write instruction
always @(posedge clk) begin
	
	addr_reg <= addr[`IMSIZE-1:0];
	if(wea == 1) begin
		instruction[addr[`IMSIZE-1:0]] <= din;
	end
end

endmodule