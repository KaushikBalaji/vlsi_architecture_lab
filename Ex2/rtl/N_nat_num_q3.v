// Q3
// control path with a 3 state FSM
// unconditional transition from DONE to IDLE after 1 clk cycle, 
// i.e., no ACK signal required

`timescale 1ns / 1ns

module N_nat_num #(parameter N=8) (
    input N_valid, clk, rst,
    input [N-1:0]N_in,
    output sum_valid,
    output [1:0] state,
    output i_eq_N,
    output [N-1:0] sum);

// port declarations
wire [N-1:0]N_mux_out;
wire [N-1:0]i_mux_out;
wire [N-1:0]sum_mux_out;

reg [N-1:0]N_reg;
reg [N-1:0]i_reg;
reg [N-1:0]sum_reg;

wire i_eq_N;
wire [N-1:0]adder_out;

// control path FSM
wire N_mux_sel, i_mux_sel, sum_mux_sel;

parameter IDLE = 2'b10;
parameter BUSY = 2'b01;
parameter DONE = 2'b11;

reg [1:0] curr_state;

assign state = curr_state;

always @(posedge clk) begin
    if (rst) begin
        curr_state <= IDLE;
    end
    else begin
        case (curr_state)
            IDLE: begin
                curr_state <= N_valid ? BUSY : IDLE;
            end
            
            BUSY: begin
            	curr_state <= i_eq_N ? DONE : BUSY;
            end
            
            DONE: begin
                curr_state <= IDLE;
            end
            
            default: curr_state <= IDLE;
        endcase
    end
end

// sum_valid logic 

assign sum_valid = (curr_state == DONE);

// Control signals
assign N_mux_sel = (curr_state == IDLE || curr_state == DONE) && N_valid;
assign i_mux_sel = (curr_state == IDLE || curr_state == DONE) && N_valid;
assign sum_mux_sel = (curr_state == IDLE || curr_state == DONE) && N_valid;

// end of FSM
// -----------------------------------------------------------------
// data path

// combinational logic

assign N_mux_out = N_mux_sel ? N_in : N_reg;
assign i_mux_out = i_mux_sel ? {{(N-1){1'b0}},1'b1} : (i_reg + 1);
assign sum_mux_out = sum_mux_sel ? {N{1'b0}} : adder_out;
assign adder_out = i_reg + sum_reg;
assign i_eq_N = (i_reg == N_reg);
assign sum = sum_reg;

// sequential logic

always @(posedge clk) begin
    if (rst) begin
        N_reg <= {N{1'b0}};
        i_reg <= {N{1'b0}};
        sum_reg <= {N{1'b0}};
    end
    else begin
        N_reg <= N_mux_out;
        i_reg <= i_mux_out;
        sum_reg <= sum_mux_out;
    end
end

endmodule
