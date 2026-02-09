// Q4
// Down-counter instead of up-counter
// control path with a 3 state FSM
 
`timescale 1ns / 1ns
module N_nat_num #(parameter N=8) (
    input N_valid, clk, rst,
    input [N-1:0]N_in,
    output sum_valid,
    output [1:0] state,
    output i_eq_1,
    output [N-1:0] sum);

// port declarations
reg [N-1:0]i_mux_out;      
reg [N-1:0]sum_mux_out;    

reg [N-1:0]i_reg;
reg [N-1:0]sum_reg;

wire i_eq_1;               
wire [N-1:0]adder_out;

// control path FSM
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
                if (N_valid) 
                    curr_state <= BUSY;
                else 
                    curr_state <= IDLE;
            end
            
            BUSY: begin
                if (i_eq_1)        
                    curr_state <= DONE;
                else 
                    curr_state <= BUSY;
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

// end of FSM
// -----------------------------------------------------------------
// data path

// combinational logic

always @(*) begin
    case (curr_state)
        IDLE: begin
                i_mux_out = N_in;              
                sum_mux_out = {N{1'b0}};          
            end
        end
         
        BUSY: begin
            i_mux_out = i_reg - 1;             
            sum_mux_out = adder_out;           
        end
        
        DONE: begin
            i_mux_out = i_reg;                
            sum_mux_out = sum_reg;             
        end
        
        default: begin
            i_mux_out = i_reg;
            sum_mux_out = sum_reg;
        end
    endcase
end

assign adder_out = i_reg + sum_reg;
assign i_eq_1 = (i_reg == {{(N-1){1'b0}}, 1'b1});  
assign sum = sum_reg;

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

endmodule
