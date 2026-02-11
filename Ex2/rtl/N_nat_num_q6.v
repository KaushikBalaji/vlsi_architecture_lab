// Q6
// Top-level module instantiating datapath and control path
`timescale 1ns / 1ns

module N_nat_num #(parameter N=8) (
    input N_valid, clk, rst, ACK,
    input [N-1:0] N_in,
    output sum_valid,
    output [N-1:0] sum
);

// Internal signals connecting control path and datapath
wire [1:0] i_mux_sel;
wire [1:0] sum_mux_sel;
wire i_eq_1;

// Instantiate control path
controlpath ctrl (
    .clk(clk),
    .rst(rst),
    .N_valid(N_valid),
    .ACK(ACK),
    .i_eq_1(i_eq_1),           // status FROM datapath
    .i_mux_sel(i_mux_sel),     // control TO datapath
    .sum_mux_sel(sum_mux_sel), // control TO datapath
    .sum_valid(sum_valid)
);

// Instantiate datapath
datapath #(.N(N)) dp (
    .clk(clk),
    .rst(rst),
    .N_in(N_in),
    .i_mux_sel(i_mux_sel),     // control FROM control path
    .sum_mux_sel(sum_mux_sel), // control FROM control path
    .sum(sum),
    .i_eq_1(i_eq_1)            // status TO control path
);

endmodule
