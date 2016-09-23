`define DM_MAX 128
`define DMSIZE 8
`timescale 1ns/1ps

module DATA_MEMORY(
	rst2,
	clk,
	wea,
	addr,
	sw_regaddr,
	sw_addr,
	MDM_MemWrite,
	din,

	res1,
	dout
);

input clk, wea, rst2, MDM_MemWrite;
input [`DMSIZE-1:0] addr;
input [31:0]sw_regaddr, din, sw_addr;

output [31:0] dout,res1;
reg [31:0]count;

reg [`DMSIZE-1:0] addr_reg;
reg [1:0]M_wea;
reg [31:0] res;
reg [31:0] data [0:`DM_MAX-1];

// DM_MAX = how many memory space can use

assign dout = data[addr_reg];
assign res1 = res; 

always @(posedge clk) begin
   	res <= data[2];
end

initial begin
	count 		<= 32'd0; 
	M_wea 		<= wea;
end

always @(posedge clk) begin
	if(rst2) begin // Never Used
		count 		<= 0; 
    M_wea 		<= wea;
    end
    else begin // lw and sw
     	if(count < 32'd2 && wea) begin // wrtie first two data to Mem
        
     		if(din[31:0] == 8'd0) begin
     		 data[0] <= 32'd0;
         data[1] <= 32'd0;
	 			 data[count +4] <= {24'd0,din};
     		end
     		else begin
     		 data[count] <= {24'd0,din};
			   data[count +4] <= {24'd0,din};
     		end
        count <= count + 32'd1;
    	end
    	
    	else if(MDM_MemWrite) begin
    		data[sw_addr] <= sw_regaddr;
    	end
    	else begin
    		M_wea 		<= wea;
    		addr_reg 	<= addr[`DMSIZE-1:0];
			if(count != 32'd368435457)
	    	  count <= count + 32'd1;
			else begin
          count <= 32'd0;
			end
    	end
	end	
end

endmodule