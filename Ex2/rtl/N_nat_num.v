// computes the sum of first N natural numbers
`timescale 1ns / 1ns

module N_nat_num #(parameter N=8) (
 input clk, N_valid, rst,
 input [N-1:0]N_in, 
 output i_eq_N,
 output reg sum_valid,
 output [N-1:0]sum );

// port declarations

wire [N-1:0]N_mux_out;
wire [N-1:0]i_mux_out;
wire [N-1:0]sum_mux_out;

reg [N-1:0]N_reg;
reg [N-1:0]i_reg;
reg [N-1:0]sum_reg;

wire i_eq_N;
wire [N-1:0]adder_out;

// combinational logic

assign N_mux_out = N_valid ? N_in : N_reg;
assign i_mux_out = N_valid ? {{(N-1){1'b0}},1'b1} : (i_reg + 1);
assign sum_mux_out = N_valid ? {N{1'b0}} : adder_out;

assign adder_out = i_reg + sum_reg;
assign i_eq_N = (i_reg==N_reg);

assign sum = sum_reg;

// sequential logic

always @(posedge clk) begin
	if (rst) begin
		N_reg <= {N{1'b0}};
		i_reg <= {N{1'b0}};
		sum_reg <= {N{1'b0}};
		sum_valid <= 1'b0;
	end
	else begin
		N_reg <= N_mux_out;
		i_reg <= i_mux_out;
		sum_reg <= sum_mux_out;
		sum_valid <= (i_eq_N & (!N_valid));
	end
end

endmodule

