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
        .gcd(gcd)
    );

    // Clock generation (10ns period)
    always #5 clk = ~clk;

    initial begin
        // init
        clk = 0;
        rst = 1;
        A_valid = 0;
        B_valid = 0;
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
        A_valid = 1;
        #10;
        A_valid = 0;
        
        #20;
        B_valid = 1;
        #10;
        B_valid = 0;
        

        // wait until DONE
        wait(state == 3'b100);

        $display("GCD Done! A=%0d B=%0d => gcd=%0d", A_in, B_in, gcd);

        // send ACK
        #30;
        ACK = 1;
        #10;
        ACK = 0;
	
//	#20;
//	A_in = 39;
//	B_in = 17;
	
//	operands_valid = 1;
//	#10;
//	operands_valid = 0;
	
//	wait(state == 2'b10);
//	$display("GCD Done! A=%0d B=%0d => gcd=%0d", A_in, B_in, gcd);
	
//	 // send ACK
//        #30;
//        ACK = 1;
//        #10;
//        ACK = 0;
	
	
        #50;
        $finish;
    end

endmodule
