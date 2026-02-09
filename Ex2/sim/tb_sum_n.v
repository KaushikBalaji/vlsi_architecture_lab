`timescale 1ns/1ps

module tb_sum_n;

	reg clk, reset;
	reg [3:0] num;
        wire [7:0] sum;

	initial clk = 0;
	always #5 clk = ~clk;

	sum_n dut (	.clk(clk), 
			.reset(reset), 
			.num(num), 
			.sum(sum)
		);
	
	initial begin
		reset = 1; num = 0; #10;
		reset = 0; num = 6; #200;
		reset = 1; #10;
		reset = 0; num = 5; #200;

		$finish;
	end

	initial begin
		$monitor("Time = %0t | reset = %b | Sum = %d", $time, reset, sum);
	end


endmodule
