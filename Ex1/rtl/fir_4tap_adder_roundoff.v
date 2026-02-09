`timescale 1ns / 1ps

module fir_4tap_adder_roundoff #(parameter integer W=16) (
	input clk, input reset,
	input signed [W-1:0] x_in,
	output reg signed [W-1:0] y_out
    );
    
    localparam signed [W-1:0] h0 = 868;
    localparam signed [W-1:0] h1 = 15516;
    localparam signed [W-1:0] h2 = 15516;
    localparam signed [W-1:0] h3 = 868;
    
    reg signed [W-1:0] x1, x2, x3;
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
    

    // Rounded off after every adder stages, W=16
    
    wire signed [(2*W)-1:0] mul_out0 = (h0 * x_in);
    wire signed [(2*W)-1:0] mul_out1 = (h1 * x1);
    wire signed [(2*W)-1:0] mul_out2 = (h2 * x2);
    wire signed [(2*W)-1:0] mul_out3 = (h3 * x3);
    
    wire signed [(2*W):0] add_out0 = (mul_out0 + mul_out1);
    wire signed [W-1:0] add_out0_rounded = (add_out0 + (1 <<< (W-2))) >>> (W-1);
    
    wire signed [(2*W):0] add_out1 = (add_out0_rounded <<< (W-1)) + mul_out2;
    wire signed [W-1:0] add_out1_rounded = (add_out1 + (1 <<< (W-2))) >>> (W-1);
    
    wire signed [(2*W):0] add_out2 = (add_out1_rounded <<< (W-1)) + mul_out3;
    wire signed [W-1:0] add_out2_rounded = (add_out2 + (1 <<< (W-2))) >>> (W-1);
    
    
    
    always @(posedge clk) begin
    	if(reset) begin
    		y_out <= 0;
    	end
    	else begin
	    	y_out <= add_out2_rounded;
    	end
    end
    
endmodule
