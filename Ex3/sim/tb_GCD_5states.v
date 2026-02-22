`timescale 1ns / 1ps

module tb_GCD_5states;

	parameter N = 8;
	
	reg clk;
	reg rst;
	reg A_valid;
	reg B_valid;
	reg ACK;
	reg [N-1:0] A_in;
	reg [N-1:0] B_in;
	
	wire B_eq_0;
	wire A_lt_B;
	wire [2:0] state;
	wire [N-1:0] gcd;
	
	GCD_3 #(N) dut (
	.clk(clk),
	.rst(rst),
	.A_valid(A_valid), 
	.B_valid(B_valid),
	.ACK(ACK),
	.A_in(A_in),
	.B_in(B_in),
	.B_eq_0(B_eq_0),
	.A_lt_B(A_lt_B),
	.state(state),
	.gcd(gcd),
	.gcd_valid(gcd_valid)
	);
	
	// Clock generation (10ns period)
	always #5 clk = ~clk;
	
	function [N-1:0] ref_gcd;
		input [N-1:0] a;
		input [N-1:0] b;
		reg [N-1:0] temp;
		begin
			while (b != 0) begin
			    temp = b;
			    b = a % b;
			    a = temp;
			end
			ref_gcd = a;
		end
	endfunction
	
	initial begin
		// init
		clk = 0;
		rst = 1;
		A_valid = 0;
		B_valid = 0;
		ACK = 0;
		A_in = 0;
		B_in = 0;
		
		repeat(2) @(posedge clk);
		rst = 0;
		
		// ---------------- TEST 1 ----------------
		@(posedge clk);
		A_in = 48;
		B_in = 18;
		
		@(posedge clk);
		A_valid = 1;
		@(posedge clk);
		A_valid = 0;
		
		repeat(2) @(posedge clk);
		B_valid = 1;
		@(posedge clk);
		B_valid = 0;
		
		wait(state == 3'b100);
		if (gcd == ref_gcd(A_in, B_in))
			$display("PASS ✅  A=%0d B=%0d  GCD=%0d", A_in, B_in, gcd);
		else
			$display("FAIL ❌  A=%0d B=%0d  Expected=%0d  Got=%0d",
			      A_in, B_in, ref_gcd(A_in, B_in), gcd);
		// ACK aligned
		repeat(2) @(posedge clk);
		ACK = 1;
		@(posedge clk);
		ACK = 0;
		
		// ---------------- TEST 2 ----------------
		@(posedge clk);
		rst = 1;
		repeat(2) @(posedge clk);
		rst = 0;
		
		@(posedge clk);
		A_in = 27;
		B_in = 9;
		
		@(posedge clk);
		B_valid = 1;
		@(posedge clk);
		B_valid = 0;
		
		repeat(2) @(posedge clk);
		A_valid = 1;
		@(posedge clk);
		A_valid = 0;
		
		wait(state == 3'b100);
		if (gcd == ref_gcd(A_in, B_in))
			$display("PASS ✅  A=%0d B=%0d  GCD=%0d", A_in, B_in, gcd);
		else
			$display("FAIL ❌  A=%0d B=%0d  Expected=%0d  Got=%0d",
			      A_in, B_in, ref_gcd(A_in, B_in), gcd);
		repeat(2) @(posedge clk);
		ACK = 1;
		@(posedge clk);
		ACK = 0;
		
		
		// ---------------- TEST 3 (both valids same time) ----------------
		@(posedge clk);
		rst = 1;
		repeat(2) @(posedge clk);
		rst = 0;
		
		@(posedge clk);
		A_in = 36;
		B_in = 24;
		
		// both valids same cycle
		@(posedge clk);
		A_valid = 1;
		B_valid = 1;
		
		@(posedge clk);
		A_valid = 0;
		B_valid = 0;
		
		wait(state == 3'b100);
		if (gcd == ref_gcd(A_in, B_in))
			$display("PASS ...  A=%0d B=%0d  GCD=%0d", A_in, B_in, gcd);
		else
			$display("FAIL ...  A=%0d B=%0d  Expected=%0d  Got=%0d",
			      A_in, B_in, ref_gcd(A_in, B_in), gcd);
		// ACK
		repeat(2) @(posedge clk);
		ACK = 1;
		@(posedge clk);
		ACK = 0;
		
		repeat(5) @(posedge clk);
		$finish;
	end
endmodule
