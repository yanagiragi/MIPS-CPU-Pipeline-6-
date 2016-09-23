`define CYCLE_TIME 29010
`define INSTRUCTION_NUMBERS 29010
`timescale 1ns/1ps
//`include "top.v"

module test;
reg Clk, Rst;
reg [31:0] cycles;
//clock cycle time is 20ns, inverse Clk value per 10ns
initial Clk = 1'b1;
always #(`CYCLE_TIME/2) Clk = ~Clk;

//Rst signal
initial begin
	cycles = 32'b0;
	Rst = 1'b1;
end

top top(
	.clk(Clk),
	.rst(Rst),
	.i0(1'd0),//0
	.i1(1'd0),//1
	.i2(1'd1),//2
	.i3(1'd0),//3
	.i4(1'd0),//4
	.i5(1'd0),
	.i6(1'd0),
	.i7(1'd0),

	.i8(1'd0),//0
	.i9(1'd1),//1
	.i10(1'd0),//2
	.i11(1'd0),//3
	.i12(1'd0),
	.i13(1'd0),
	.i14(1'd0),
	.i15(1'd0)
);

//display all Register value and Data memory content
always @(posedge Clk) begin
	if(Rst) begin
		$display("start!");
		Rst = 1'b0;
	end
	else begin
		cycles <= cycles + 1;
		//$display("Now cycle: %d",cycles);
		if (cycles == `INSTRUCTION_NUMBERS) begin
			$display("End\n");
			$display("gcd(Mem[4],Mem[5]) = Mem[3]\n");
			$finish;
		end
	end
end

endmodule

