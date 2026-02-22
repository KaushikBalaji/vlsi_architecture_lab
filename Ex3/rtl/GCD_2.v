`timescale 1ns / 1ps
// GCD
module GCD_2 #(parameter N = 8) (
	input clk, input rst, input operands_valid, input ACK,
	input [N-1:0] A_in, input [N-1:0] B_in,
	output B_eq_0, output A_lt_B,
	output [1:0] state, output[N-1:0] gcd,
	output gcd_valid
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
	assign gcd_valid = (curr_state == DONE);
	
	parameter IDLE = 2'b00;
	parameter BUSY = 2'b01;
	parameter DONE = 2'b10;
	
	reg[1:0] curr_state;
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
				if (operands_valid) begin
					A_mux_sel = 2'b01; 
					B_mux_sel = 2'b01;	// get new inputs
				end
				
			BUSY: begin
				if (B_eq_0) begin
					A_mux_sel = 2'b00;
					B_mux_sel = 2'b00;	// retain the register values
			    	end
				else if (A_lt_B) begin
					A_mux_sel = 2'b11; 
					B_mux_sel = 2'b10;	// swap nos
				end
				else begin
					A_mux_sel = 2'b10;
					B_mux_sel = 2'b00;
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
	
//	enb_reg #(.N(N)) AREG (.clk(clk), .rst(rst), .en(A_en), .d());
	
	
	
	// FSM
	always @(posedge clk) begin
		if (rst)
			curr_state <= IDLE;
		else begin
			case (curr_state)
				IDLE:
					curr_state <= operands_valid ? BUSY : IDLE;
				BUSY:
					curr_state <= B_eq_0 ? DONE : BUSY;
				DONE:
					curr_state <= ACK ? IDLE : DONE;
			endcase
		end
	end
	
	reg [8*5:1] state_string;   // 5-character string

	always @(*) begin
	    case (curr_state)
		IDLE: state_string = "IDLE ";
		BUSY: state_string = "BUSY ";
		DONE: state_string = "DONE ";
		default: state_string = "UNKN ";
	    endcase
	end
endmodule
