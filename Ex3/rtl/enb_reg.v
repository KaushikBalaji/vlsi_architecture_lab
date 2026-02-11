`timescale 1ns / 1ps
module enb_reg #(parameter N = 8)(
	input clk, input rst, input en, input[N-1:0] d, output reg[N-1:0] q );
	always @(posedge clk) begin
		if(rst)
			q <= 8'b0;
		else 
			if (en)
				q <= d;
	end
endmodule
