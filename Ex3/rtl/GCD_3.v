`timescale 1ns / 1ps
// GCD
module GCD_3 #(parameter N = 8) (
	input clk, input rst, 
	input A_valid, input B_valid, 
	input ACK,
	input [N-1:0] A_in, input [N-1:0] B_in,
	output B_eq_0, output A_lt_B,
	output [2:0] state, output[N-1:0] gcd
	);
	
	// ports used
	reg [N-1:0] A_mux_out, B_mux_out;
	reg[N-1:0] A_reg, B_reg;
	wire[N-1:0] adder_out;
	reg[1:0] A_mux_sel,  B_mux_sel;
	
	assign A_lt_B = (A_reg < B_reg);
	assign B_eq_0 = (B_reg == 0);
	assign adder_out = (A_reg - B_reg);
	assign gcd = A_reg;
	
	parameter IDLE = 3'b000;
	parameter A_WAIT = 3'b001;
	parameter B_WAIT = 3'b010;
	parameter BUSY = 3'b011;
	parameter DONE = 3'b100;
	
	reg[2:0] curr_state;
	assign state = curr_state;
	
	// MUX output selection
	always @(*) begin
		A_mux_out = A_reg;
		B_mux_out = B_reg;
		
		case (A_mux_sel)
			2'b11: A_mux_out = B_reg;
			2'b10: A_mux_out = adder_out;
			2'b00: A_mux_out = A_reg;
			2'b01: A_mux_out = A_in;
		endcase
	
		case (B_mux_sel)
			2'b00: B_mux_out = B_reg;
			2'b10: B_mux_out = A_reg;
			2'b01: B_mux_out = B_in;
		endcase
	end
	
	always @(*) begin
		A_mux_sel = 2'b00; B_mux_sel = 2'b00;
		
		case (curr_state)
			IDLE:
				if (A_valid && B_valid) begin
					A_mux_sel = 2'b01;
					B_mux_sel = 2'b01;	// get both values if A and B Valids come at same time
				end	
				else if (A_valid) begin
					A_mux_sel = 2'b01;
					B_mux_sel = 2'b00;	// When only A_valid is present, get A_in and keep B reg as same value
				end
				else if (B_valid) begin
					A_mux_sel = 2'b00;
					B_mux_sel = 2'b01;
				end
				else begin
					A_mux_sel = 2'b00;
					B_mux_sel = 2'b00;
				end

			A_WAIT:
				if (A_valid) begin
					A_mux_sel = 2'b01;
					B_mux_sel = 2'b00;
				end					

			B_WAIT:
				if (B_valid) begin
					A_mux_sel = 2'b00;
					B_mux_sel = 2'b01;
				end
				
			BUSY: begin
				if (B_eq_0) begin
					A_mux_sel = 2'b00;
					B_mux_sel = 2'b00;	// retain the register values
			    	end
				else if (A_lt_B) begin
					A_mux_sel = 2'b11; 
					B_mux_sel = 2'b10;	// swap register values
				end
				else begin
					A_mux_sel = 2'b10;
					B_mux_sel = 2'b00;	// A-B given to A, and B retains value
				end
			end		
		endcase
	end
	
	always @(posedge clk) begin
		if(rst) begin
			A_reg <= {N{1'b0}};
			B_reg <= {N{1'b0}};
		end
		else begin		
			A_reg <= A_mux_out;
			B_reg <= B_mux_out;	
		end
	end	
	
	
	// FSM
	always @(posedge clk) begin
		if (rst)
			curr_state <= IDLE;
		else begin
			case (curr_state)
				IDLE:
					if(A_valid && B_valid)
						curr_state <= BUSY;
					else if (A_valid)
						curr_state <= B_WAIT;
					else if (B_valid)
						curr_state <= A_WAIT;
					else
						curr_state <= IDLE;

				A_WAIT:
					curr_state <= A_valid ? BUSY : A_WAIT;

				B_WAIT:
					curr_state <= B_valid ? BUSY : B_WAIT;

				BUSY:
					curr_state <= B_eq_0 ? DONE : BUSY;

				DONE:
					curr_state <= ACK ? IDLE : DONE;
			endcase
		end
	end

endmodule

