// Q6
// independent data path

`timescale 1ns/1ns
module datapath #(parameter N=8) (
    input clk, rst,
    input [N-1:0]N_in,
    input [1:0] i_mux_sel, sum_mux_sel, // control signals
    output [N-1:0]sum,
    output i_eq_1 // status signal
);

// port declarations

reg [N-1:0]i_mux_out;      
reg [N-1:0]sum_mux_out;    
reg [N-1:0]i_reg;
reg [N-1:0]sum_reg;
              
wire [N-1:0]adder_out;

// combinational logic

always @(*) begin
    case (i_mux_sel)
        2'b00: i_mux_out = N_in;        // IDLE + N_valid asserted
        2'b01: i_mux_out = i_reg - 1;   // BUSY
        2'b10: i_mux_out = i_reg;       // DONE or IDLE without N_valid
        default: i_mux_out = i_reg;
    endcase
    
    case (sum_mux_sel)
        2'b00: sum_mux_out = {N{1'b0}};      // IDLE + N_valid asserted
        2'b01: sum_mux_out = adder_out;      // BUSY
        2'b10: sum_mux_out = sum_reg;        // DONE or IDLE without N_valid
        default: sum_mux_out = sum_reg;
    endcase
end

assign adder_out = i_reg + sum_reg;
assign i_eq_1 = (i_reg == {{(N-1){1'b0}}, 1'b1});  

// sequential logic

always @(posedge clk) begin
    if (rst) begin
        i_reg <= {N{1'b0}};
        sum_reg <= {N{1'b0}};
    end
    else begin
        i_reg <= i_mux_out;
        sum_reg <= sum_mux_out;
    end
end

assign sum = sum_reg; // final o/p taken from register

endmodule
