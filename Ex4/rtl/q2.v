`timescale 1ns / 1ns

module q2 #(parameter N = 8)
(
    input clk,
    input N_valid,
    input rst,
    input ack,
    input [N-1:0] N_in,
    output reg sum_valid,
    output [N-1:0] sum
);

reg [N-1:0] sum_reg;
reg [N-1:0] i_reg;
reg [N-1:0] j_reg;

assign sum = sum_reg;

wire [N-1:0] adder_out;
assign adder_out = sum_reg + i_reg;

wire i_eq_0 = (i_reg == 0);
wire j_eq_0 = (j_reg == 0);

localparam IDLE = 2'b00;
localparam OUTER_LOOP = 2'b01;
localparam INNER_LOOP = 2'b10;
localparam DONE = 2'b11;

reg [1:0] state;

// FSM block
always @(posedge clk) begin
    if (rst)
        state <= IDLE;
    else begin
        case(state)
            IDLE:
                state <= N_valid ? OUTER_LOOP : IDLE;

            OUTER_LOOP:
                state <= i_eq_0 ? DONE : INNER_LOOP;

            INNER_LOOP:
                state <= j_eq_0 ? OUTER_LOOP : INNER_LOOP;

            DONE:
                state <= ack ? IDLE : DONE;
        endcase
    end
end


// Sequential Logic
always @(posedge clk) begin
    if (rst) begin
        sum_reg <= 0;
        i_reg <= 0;
        j_reg <= 0;
        sum_valid <= 0;
    end
    else begin
        case(state)

            IDLE: begin
                sum_valid <= 0;
                if (N_valid) begin
                    sum_reg <= 0;
                    i_reg <= N_in;
                end
            end

            OUTER_LOOP: begin
                if (!i_eq_0)
                    j_reg <= i_reg;
            end

            INNER_LOOP: begin
                if (j_eq_0)
                    i_reg <= i_reg - 1;
                else begin
                    sum_reg <= adder_out;
                    j_reg <= j_reg - 1;
                end
            end

            DONE: begin
                sum_valid <= 1;
            end

        endcase
    end
end

reg [8*5:1] state_string;

always @(*) begin
    case (state)
        IDLE: state_string = "IDLE ";
        OUTER_LOOP: state_string = "OUTER";
        INNER_LOOP: state_string = "INNER";
        DONE: state_string = "DONE  ";
    endcase
end

endmodule
