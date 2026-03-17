module cordic #(parameter N = 16) (
    input clk,
    input rst,
    input operands_valid,
    input cordic_mode,
    input ack,

    input signed [N-1:0] x_in,
    input signed [N-1:0] y_in,
    input signed [N-1:0] theta_in,

    output signed [N-1:0] x_out,
    output signed [N-1:0] y_out,
    output signed [N-1:0] theta_out,
    output valid_out
);

localparam IDLE = 2'b00;
localparam BUSY = 2'b01;
localparam DONE = 2'b10;

reg [1:0] state, next_state;
reg signed [N-1:0] x_reg, y_reg, theta_reg;
reg [3:0] i_reg;

// Combinational wires for shifting
wire signed [N-1:0] x_shift, y_shift;
reg signed [N-1:0] x_add_out, y_add_out, theta_add_out;

reg [15:0] atan_lut [0:15];
initial begin
    $readmemh("atan_lut.mem", atan_lut); 
end

// Shifters - IMPORTANT: Ensure barrel_shifter uses Arithmetic Shift (>>>)
barrel_shifter bsx(.data_in(x_reg), .shift(i_reg), .data_out(x_shift));
barrel_shifter bsy(.data_in(y_reg), .shift(i_reg), .data_out(y_shift));

assign x_out = x_reg;
assign y_out = y_reg;
assign theta_out = theta_reg;
assign valid_out = (state == DONE);

wire decision_bit;
// Mode 1: Vectoring (Y sign), Mode 0: Rotation (Theta sign)
assign decision_bit = (cordic_mode) ? y_reg[N-1] : ~theta_reg[N-1];

// Combinational Math Logic
always @(*) begin
    if (decision_bit) begin
        x_add_out = x_reg - y_shift;
        y_add_out = y_reg + x_shift;
        theta_add_out = theta_reg - atan_lut[i_reg];
    end else begin
        x_add_out = x_reg + y_shift;
        y_add_out = y_reg - x_shift;
        theta_add_out = theta_reg + atan_lut[i_reg];
    end
end

// Unified Register Update Block (NO CONFLICTS)
always @(posedge clk) begin
    if (rst) begin
        x_reg <= 0;
        y_reg <= 0;
        theta_reg <= 0;
    end else begin
        case (state)
            IDLE: begin
                if (operands_valid) begin
                    x_reg     <= x_in;
                    y_reg     <= y_in;
                    theta_reg <= theta_in;
                end
            end
            BUSY: begin
                x_reg     <= x_add_out;
                y_reg     <= y_add_out;
                theta_reg <= theta_add_out;
            end
            // In DONE state, registers hold their values automatically
        endcase
    end
end

// FSM State Transition
always @(*) begin
    case(state)
        IDLE:    next_state = operands_valid ? BUSY : IDLE;
        BUSY:    next_state = (i_reg == 4'd15) ? DONE : BUSY;
        DONE:    next_state = ack ? IDLE : DONE;
        default: next_state = IDLE;
    endcase
end

always @(posedge clk) begin
    if(rst) state <= IDLE;
    else    state <= next_state;
end

// Counter Logic
always @(posedge clk) begin
    if(rst)
        i_reg <= 0;
    else if(state == BUSY)
        i_reg <= i_reg + 1;
    else
        i_reg <= 0;
end

endmodule