`timescale 1ns / 1ps

module tb;

    reg clk;
    reg reset;
    reg signed [15:0] x_in;
    wire signed [15:0] y_out;

    fir_4tap dut (
        .clk   (clk),
        .reset (reset),
        .x_in  (x_in),
        .y_out (y_out)
    );
    
    reg [15:0] inputs [0:255];
    integer i;
    
    initial begin
    	$readmemh("input.txt", inputs);
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
    $display("time\t x_in\t y_out");
    $monitor("%0t\t %d\t %d", $time, x_in, y_out);
end


endmodule
