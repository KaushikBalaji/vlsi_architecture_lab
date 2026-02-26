`timescale 1ns / 1ns

module q1 #(parameter N = 8)
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
	reg [N-1:0] acc_reg;
	reg [N-1:0] i_reg;
	reg [N-1:0] j_reg;
	
	assign sum = sum_reg;
	
	// ----------------------------
	// Combinational Datapath
	// ----------------------------
	
	wire [N-1:0] acc_adder;
	wire [N-1:0] sum_adder;
	
	assign acc_adder = acc_reg + i_reg;
	assign sum_adder = sum_reg + acc_reg;
	
	wire i_eq_0;
	wire j_eq_0;
	
	assign i_eq_0 = (i_reg == 0);
	assign j_eq_0 = (j_reg == 0);
	
	// ----------------------------
	// FSM States
	// ----------------------------
	
	localparam IDLE = 2'b00;
	localparam OUTER_LOOP = 2'b01;
	localparam INNER_LOOP = 2'b10;
	localparam DONE = 2'b11;
	
	reg [1:0] state;
	
	always @(posedge clk) begin
		if (rst)
			state <= IDLE;
		else begin
			case(state)
				IDLE: state <= N_valid ? OUTER_LOOP : IDLE;
				
				OUTER_LOOP: state <= i_eq_0 ? DONE : INNER_LOOP;
				
				INNER_LOOP: state <= j_eq_0 ? OUTER_LOOP : INNER_LOOP;
				
				DONE: state <= ack ? IDLE : DONE;
			
			endcase
		end
	end
	
	// ----------------------------
	// Sequential Logic
	// ----------------------------
	
	always @(posedge clk) begin
		if (rst) begin
			sum_reg <= 0;
			acc_reg <= 0;
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
					if (!i_eq_0) begin
						acc_reg <= 0;
						j_reg <= i_reg;
					end
				end
				
				INNER_LOOP: begin
					if (j_eq_0) begin
						sum_reg <= sum_adder;
						i_reg <= i_reg - 1;
					end
					else begin
						acc_reg <= acc_adder;
						j_reg <= j_reg - 1;
					end
				end
				
				DONE: begin
					sum_valid <= 1;	
				end
			
			endcase
		end
	end
	
	
	reg [8*6:1] state_string;
	
	always @(*) begin
		case(state)
			IDLE: state_string = "IDLE  ";
			OUTER_LOOP: state_string = "OUTER";
			INNER_LOOP: state_string = "INNER";
			DONE: state_string = "DONE  ";
		endcase
	end

endmodule
