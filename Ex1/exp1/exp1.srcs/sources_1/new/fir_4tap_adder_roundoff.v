`timescale 1ns / 1ps

module fir_4tap_adder_roundoff(
	input clk, input reset,
	input signed [15:0] x_in,
	output reg signed [15:0] y_out
    );
    
    localparam signed [15:0] h0 = 16'sd868;
    localparam signed [15:0] h1 = 16'sd15516;
    localparam signed [15:0] h2 = 16'sd15516;
    localparam signed [15:0] h3 = 16'sd868;
    
    reg signed [15:0] x1, x2, x3;
    always @(posedge clk) begin
    	if(reset) begin
    		x1 <= 0;
    		x2 <= 0;
    		x3 <= 0;
    	end
    	else begin
    		x1 <= x_in;
    		x2 <= x1;
    		x3 <= x2;
    	end
    end
    
    
    wire signed [31:0] mul_out0 = (h0 * x_in);
    wire signed [31:0] mul_out1 = (h1 * x1);
    wire signed [31:0] mul_out2 = (h2 * x2);
    wire signed [31:0] mul_out3 = (h3 * x3);
    
    wire signed [32:0] add_out0 = (mul_out0 + mul_out1);
    wire signed [15:0] add_out0_rounded = (add_out0 + 32'sd16384) >>> 15;
    
    wire signed [32:0] add_out1 = (add_out0_rounded <<< 15) + mul_out2;
    wire signed [15:0] add_out1_rounded = (add_out1 + 32'sd16384) >>> 15;
    
    wire signed [32:0] add_out2 = (add_out1_rounded <<< 15) + mul_out3;
    wire signed [15:0] add_out2_rounded = (add_out2 + 32'sd16384) >>> 15;
    
    
    
    always @(posedge clk) begin
    	if(reset) begin
    		y_out <= 0;
    	end
    	else begin
	    	y_out <= add_out2_rounded;
    	end
    end
    
endmodule
