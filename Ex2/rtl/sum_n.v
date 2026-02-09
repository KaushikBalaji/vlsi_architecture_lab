
module 	sum_n(input clk, input reset, input wire[3:0] num, 
		output reg[7:0] sum);
	
	reg[3:0] counter_out;
	
	always @(posedge clk) begin
		if(reset) begin
			counter_out <= 4'b1;
			sum <= 8'b0;
		end
		else begin
			if(counter_out<=num) begin
				sum <= sum + counter_out;
				counter_out <= counter_out+1;
			end
			else begin
				counter_out <= counter_out;
				sum <= sum;
			end
		end
	end
	
endmodule
