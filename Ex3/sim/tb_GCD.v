`timescale 1ns / 1ps

module tb_GCD;
	parameter N = 8;
	reg clk;
	reg rst;
	reg operands_valid;
	reg ACK;
	reg [N-1:0] A_in;
	reg [N-1:0] B_in;
	wire B_eq_0;
	wire A_lt_B;
	wire [1:0] state;
	wire [N-1:0] gcd;
	wire gcd_valid;
	
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

	GCD_2 #(N) dut (
		.clk(clk),
		.rst(rst),
		.operands_valid(operands_valid),
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
	
	initial begin
		// init
		clk = 0;
		rst = 1;
		operands_valid = 0;
		ACK = 0;
		A_in = 0;
		B_in = 0;
		
		// reset pulse
		#20;
		rst = 0;
		
		// apply inputs
		#10;
		A_in = 48;
		B_in = 18;
		
		// pulse operands_valid
		operands_valid = 1;
		#10;
		operands_valid = 0;
		
		
		// wait until DONE
		wait(state == 2'b10);
		if (gcd == ref_gcd(A_in, B_in))
			$display("PASS ✅  A=%0d B=%0d  GCD=%0d", A_in, B_in, gcd);
		else
			$display("FAIL ❌  A=%0d B=%0d  Expected=%0d  Got=%0d",
			      A_in, B_in, ref_gcd(A_in, B_in), gcd);
		
		// send ACK
		#30;
		ACK = 1;
		#10;
		ACK = 0;
		#20;
		A_in = 39;
		B_in = 17;
		
		operands_valid = 1;
		#10;
		operands_valid = 0;
		
		wait(state == 2'b10);
		if (gcd == ref_gcd(A_in, B_in))
			$display("PASS ✅  A=%0d B=%0d  GCD=%0d", A_in, B_in, gcd);
		else
			$display("FAIL ❌  A=%0d B=%0d  Expected=%0d  Got=%0d",
			      A_in, B_in, ref_gcd(A_in, B_in), gcd);
		
		 // send ACK
		#30;
		ACK = 1;
		#10;
		ACK = 0;
		#50;
		$finish;
	end
endmodule
