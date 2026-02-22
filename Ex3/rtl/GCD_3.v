`timescale 1ns / 1ps
// GCD
module GCD_3 #(parameter N = 8)
              (input clk,
               input rst,
               input A_valid,
               input B_valid,
               input ACK,
               input [N-1:0] A_in,
               input [N-1:0] B_in,
               output B_eq_0,
               output A_lt_B,
               output [2:0] state,
               output [N-1:0] gcd,
               output gcd_valid
               );
    
    // ports used
    reg [N-1:0] A_mux_out, B_mux_out;
    reg [N-1:0] A_reg, B_reg;
    wire [N-1:0] adder_out;
    
    reg [1:0] A_mux_sel, B_mux_sel;
    
    assign A_lt_B = (A_reg < B_reg);
    assign B_eq_0 = (B_reg == 0);
    assign adder_out = (A_reg - B_reg);
    assign gcd_valid = (curr_state == DONE);
    assign gcd = A_reg;
    assign gcd_valid = (curr_state == DONE);
    
    localparam IDLE = 3'b000;
    localparam A_WAIT = 3'b001;
    localparam B_WAIT = 3'b010;
    localparam BUSY = 3'b011;
    localparam DONE = 3'b100;
    
    reg [2:0] curr_state, next_state;
    assign state = curr_state;
    
    // NEXT STATE LOGIC
    always @(*) begin
        case(curr_state)
            IDLE: begin
                next_state = (A_valid && B_valid) ? BUSY : (A_valid) ? B_WAIT : (B_valid) ? A_WAIT : IDLE;
            end
            
            A_WAIT: begin
                next_state = (A_valid) ? BUSY : A_WAIT;
            end
            
            B_WAIT: begin
                next_state = (B_valid) ? BUSY : B_WAIT;
            end
            
            BUSY: begin
                next_state = (B_eq_0) ? DONE : BUSY;
            end
            
            DONE: begin
                next_state = (ACK) ? IDLE : DONE;
            end
            
            default: begin
                next_state = IDLE;
            end
        endcase
    end
    
    // -------------------------
    // STATE REGISTER
    // -------------------------
    always @(posedge clk) begin
        if (rst)
            curr_state <= IDLE;
        else
            curr_state <= next_state;
    end
    
    
    // -------------------------
    // DATAPATH CONTROL (MUX SEL)
    // -------------------------
    always @(*) begin
        // default HOLD (like gcd_mod2)
        A_mux_sel = 2'b00;
        B_mux_sel = 2'b00;
        
        case(curr_state)
            
            IDLE: begin
                if (A_valid && B_valid) begin
                    A_mux_sel = 2'b01; // load A_in
                    B_mux_sel = 2'b01; // load B_in
                end
                else if (A_valid) begin
                    A_mux_sel = 2'b01; // load A_in
                    B_mux_sel = 2'b00; // hold B
                end
                else if (B_valid) begin
                    A_mux_sel = 2'b00; // hold A
                    B_mux_sel = 2'b01; // load B_in
                end
            end
            
            A_WAIT: begin
                if (A_valid) begin
                    A_mux_sel = 2'b01; // load A_in
                    B_mux_sel = 2'b00; // hold B
                end
            end
            
            B_WAIT: begin
                if (B_valid) begin
                    A_mux_sel = 2'b00; // hold A
                    B_mux_sel = 2'b01; // load B_in
                end
            end
            
            BUSY: begin
                if (A_lt_B) begin
                    A_mux_sel = 2'b11; // A = B
                    B_mux_sel = 2'b10; // B = A (swap)
                end
                else begin
                    A_mux_sel = 2'b10; // A = A-B
                    B_mux_sel = 2'b00; // hold B
                end
            end
            
            DONE: begin
                // HOLD values in DONE (important fix)
                A_mux_sel = 2'b00;
                B_mux_sel = 2'b00;
            end
            
            default: begin
                A_mux_sel = 2'b00;
                B_mux_sel = 2'b00;
            end
        endcase
    end
    
    
    // -------------------------
    // MUX OUTPUT SELECTION
    // -------------------------
    always @(*) begin
        A_mux_out = A_reg;
        B_mux_out = B_reg;
        
        case (A_mux_sel)
            2'b11: A_mux_out = B_reg;      // swap
            2'b10: A_mux_out = adder_out;   // subtract
            2'b01: A_mux_out = A_in;        // load input
            2'b00: A_mux_out = A_reg;       // hold
        endcase
        
        case (B_mux_sel)
            2'b10: B_mux_out   = A_reg;       // swap
            2'b01: B_mux_out   = B_in;        // load input
            2'b00: B_mux_out   = B_reg;       // hold
            default: B_mux_out = B_reg;
        endcase
    end
    
    
    // -------------------------
    // REGISTER UPDATE
    // -------------------------
    always @(posedge clk) begin
        if (rst) begin
            A_reg <= 0;
            B_reg <= 0;
        end
        else begin
            A_reg <= A_mux_out;
            B_reg <= B_mux_out;
        end
    end
    
    reg [8*5:1] state_string;   // 5-character string
    
    always @(*) begin
        case (curr_state)
            IDLE: state_string    = "IDLE";
            A_WAIT: state_string    = "AWAIT";
            B_WAIT: state_string    = "BWAIT";
            BUSY: state_string    = "BUSY";
            DONE: state_string    = "DONE";
            default: state_string = "UNKN";
        endcase
    end
    
endmodule
