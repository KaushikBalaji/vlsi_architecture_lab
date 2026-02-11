// Q6
// independent control path
`timescale 1ns / 1ns
module controlpath (
    input clk, rst,
    input N_valid, ACK,
    input i_eq_1,                    // status from datapath
    output reg [1:0] i_mux_sel,      // control to datapath
    output reg [1:0] sum_mux_sel,    // control to datapath
    output sum_valid
);

parameter IDLE = 2'b10;
parameter BUSY = 2'b01;
parameter DONE = 2'b11;

reg [1:0] state;

always @(posedge clk) begin
    if (rst) begin
        state <= IDLE;
    end
    else begin
        case (state)
            IDLE: begin
                if (N_valid) 
                    state <= BUSY;
                else 
                    state <= IDLE;
            end
            
            BUSY: begin
                if (i_eq_1)        
                    state <= DONE;
                else 
                    state <= BUSY;
            end
            
            DONE: begin
                if (ACK)              
                    state <= IDLE;
                else
                    state <= DONE;
            end
            
            default: state <= IDLE;
        endcase
    end
end

// sum_valid logic 
assign sum_valid = (state == DONE);

// mux select lines 
always @(*) begin
    if ((state == IDLE) && (N_valid == 1'b1)) begin
        i_mux_sel = 2'b00;      
        sum_mux_sel = 2'b00;    
    end
    else if (state == BUSY) begin
        i_mux_sel = 2'b01;      
        sum_mux_sel = 2'b01;    
    end
    else begin  // DONE or IDLE without N_valid
        i_mux_sel = 2'b10;      
        sum_mux_sel = 2'b10;    
    end
end

endmodule
