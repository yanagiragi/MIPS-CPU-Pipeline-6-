`timescale 1ns / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    20:43:21 10/12/2014 
// Design Name: 
// Module Name:    top 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module top(
	 	input clk,
		input rst,
	 	input i0,
	 	input i1,
	 	input i2,
	 	input i3,
	 	input i4,
		input i5,
	 	input i6,
		input i7,
		input i8,
		input i9,
		input i10,
	 	input i11,
	 	input i12,
	 	input i13,
		input i14,
	 	input i15,
		
	/*	output o1,
		output o2,
		output o3,
		output o4,
		output o5,
		output o6,
		output o7,
		output o8,*/

		output  ca,
		output  cb,
		output  cc,
		output  cd,
		output  ce,
		output  cf,
		output  cg,
	
    	output a,
    	output b,
    	output c,
    	output d,
    	output e,
    	output f,
	   output g,
		output h,
		output i,
		output j,
		output k,
		output l,
		output m,
		output n,
		output o,
		
		
		output an0,
		output an1,
		output an2,
		output an3,
		output an4,
		output an5,
		output an6,
		output an7,

		output bbsy
);

reg [2:0] count_div8;
reg [31:0] count;
reg [7:0] answer ;
reg [7:0] an ;

reg [6:0] seg [0:9];
//reg Product_Valid;
//reg Product_Valid;

wire [31:0] dout;
wire [31:0] data;
wire [31:0] datain;
//wire Product_Valid;
reg [31:0]dout2;

assign bbsy=bsy;
assign datain=(count == 31'd0)?{{24'b0},i15,i14,i13,i12,i11,i10,i9,i8}:{{24'b0},i7,i6,i5,i4,i3,i2,i1,i0}; 
//input{1,2} -> data memory

assign CLK_1M = count_div8[2];
assign start_run = (count == 32'd3 && !rst) ? 1'b1 : 1'b0;	 
assign {o,n,m,l,k,j,i,h,g,f,e,d,c,b,a}=count[28:14];//dout[7:0];
assign wen = (count==32'd0);

//assign {o8,o7,o6,o5,o4,o3,o2,o1} = dout;
assign {cg,cf,ce,cd,cc,cb,ca} = answer;
assign {an7,an6,an5,an4,an3,an2,an1,an0} = an;
reg [31:0]starts,ends;

CPU cpu (
  .clk(CLK_1M),
  .rst(rst),
  .wen(wen),
  .start(start_run),
  .haddr(count),
  .hdin(datain),
  .bsy(bsy),
  //.Product_Valid(Product_Valid),
  .dout(dout)
);

/*always @(posedge clk or posedge rst) begin
	//$display("rst %b",rst);
	//$display("datain = %b",datain);
	//$display("Input1 is %d, Input2 is %d",{24'd0,datain[15:8]},{24'd0,datain[7:0]});
end*/
	

always@ (posedge clk or posedge rst)begin
	if(rst) begin 
		starts <= {{24'b0},i7,i6,i5,i4,i3,i2,i1,i0}; 
		ends <= {{24'b0},i15,i14,i13,i12,i11,i10,i9,i8}; 
		seg[0] = 7'b1000000;//h40;//8'hc0;
		seg[1] = 7'b1111001;//h79;//8'hf9;
		seg[2] = 7'b0100100;//h24;//8'ha4;
		seg[3] = 7'b0110000;//h30;//8'hb0;
		seg[4] = 7'b0011001;//h19;//8'h99;
		seg[5] = 7'b0010010;//h12;//8'h92;
		seg[6] = 7'b0000010;//h02;//8'h82;
		seg[7] = 7'b1111000;//h78;//8'hf8;
		seg[8] = 7'b0000000;//h00;//8'h80;
		seg[9] = 7'b0010000;//h10;//8'h90;	
		//Product_Valid <= 0;
		//dout2 <= 32'd0;
	end
	//else if(dout || !dout) begin
		//dout2 <= dout;
		$display("dout in top = %d",dout);
		$display("datain in top = %d",datain);
	//	Product_Valid <= 1;
	//end
		
end 

always@(posedge clk)
begin
	if(rst)
		count_div8 <= 3'b000;
	else if (count_div8 == 3'b111)
		count_div8 <= 3'b000;
	else begin 
		count_div8 <= count_div8 + 3'b001;
		//$display("%d",dout);
		//$display("an = %d",an);
	end
end

always@(posedge CLK_1M)	
begin
	if(rst) begin
			count <= 32'd0;
			//Product_Valid <= 1;
	end
	else
	begin
			$display("Top Count: %d",count);
			//8388608
			if(count < 32'd368435457 && !bsy) //b01001
				count <= count + 32'd1;/*count <= count + 32'd43775457;*/
			else if ( count < 32'd368435457	 && bsy)
				count <= count;
			else if ( count >= 32'd368435457 && !bsy)
				count <= 32'd0;	
			else
				count <= 32'd0;
			/*
			if(count < 32'd8388608 && !bsy) //b01001
				count <= count + 32'd1;
			else if ( count < 32'd8388608 && bsy)
				count <= count;
			else
				count <= 32'b0;	*/
	end
end

always @(posedge clk or posedge rst)
begin
	if(rst)begin 
		an <=8'b11111111;
		answer <= 'b1111111;

	end 

	else /*if(Product_Valid == 1'b1 ) */begin
		//$display("answer = %b",answer);
		
			if(count[15:13] == 3'd0 )begin
				answer <= seg[ dout % 10] ; 			 	//fisrt
				an <=8'b11111110;
			end 
			else if(count[15:13] == 3'd1)begin
				answer <= seg[(dout % 100)/10] ;   			// second 7 segment
				an <=8'b11111101;
			end 
			else if(count[15:13] == 3'd2)begin
				answer <= seg[(dout % 1000)/100] ;			// third 7 segment
				an <=8'b11111011;
			end 
			else if(count[15:13] == 3'd3)begin
				answer <= seg[(dout % 10000) / 1000] ;		// forth 7 segment
				an <=8'b11110111;
			end 
			else if(count[15:13] == 3'd4)begin
				answer <= seg[(dout % 100000) / 10000] ;	// fifth 7 segment
				an <=8'b11101111;
			end 
			else if(count[15:13] == 3'd5)begin
				answer <= seg[(dout % 1000000) / 100000];	// sixth 7 segment
				an <=8'b11011111;
			end 
			else if(count[15:13] == 3'd6)begin
				answer <= seg[(dout % 10000000) / 1000000];	 // seventh 7 segment
				an <=8'b10111111;
			end 
			else if(count[15:13] == 3'd7)begin
				answer <= seg[(dout % 100000000) /10000000]; // final (eighth) 7 segment
				an <=8'b01111111;
			end 
			else begin
				answer <= 7'b1111111;
				an <=8'b11111111;
			end
		end // end of else
end 

endmodule