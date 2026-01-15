`timescale 1ns / 1ps

module tb_adder_roundoff;
	reg clk;
    reg reset;
    reg signed [15:0] x_in;
    wire signed [15:0] y_out;

    fir_4tap_adder_roundoff dut (
        .clk   (clk),
        .reset (reset),
        .x_in  (x_in),
        .y_out (y_out)
    );
    
    reg [15:0] inputs [0:255];
    reg [15:0] matlab_out [0:255];
    integer i;
    integer j;
    
    initial begin
    	$readmemh("input.txt", inputs);
    	$readmemh("matlab_hexout_2.txt", matlab_out);
    end

    always #5 clk = ~clk;

    initial begin
        clk   = 0;
        reset = 1;
        x_in  = 0;

        #20;
        reset = 0;


//        #10 x_in = 16'sh016C;
//        #10 x_in = 16'sh04DA;
//        #10 x_in = 16'shFA05;
//        #10 x_in = 16'sh0248;
//        #10 x_in = 16'sh00D8;
        
        for(i=0; i<256; i=i+1) begin
        	@(posedge clk);
        	x_in <= inputs[i];
        end
        
        @(posedge clk);
         x_in <= 0;

        #100;
        $finish;
    end
    

    initial begin
	    $display("time\tidx\tx_in(hex)\ty_out(hex)\tmatlab(hex)\tMATCH");
	    $display("---------------------------------------------------------------");
	
	    @(negedge reset);
	
	    for (j= 0; j < 256; j = j + 1) begin
		@(posedge clk);
	
		// Skip first few samples (delay line not full)
		
		    if (y_out === matlab_out[j-2])
			$display("%0t\t%0d\t%04h\t\t%04h\t\t%04h\t\tYES", $time, j, x_in, y_out, matlab_out[j-2]);
		    else
			$display("%0t\t%0d\t%04h\t\t%04h\t\t%04h\t\tNO", $time, j, x_in, y_out, matlab_out[j-2]);
		
	    end
	end
	

endmodule
