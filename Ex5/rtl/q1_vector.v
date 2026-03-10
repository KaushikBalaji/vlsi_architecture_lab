// `include "/barrel_shifter.v"


module cordic_vectoring (
    input clk, input rst, input operands_valid,
    input [15:0] x_in, input [15:0] y_in, input [15:0] theta_in,
    output [15:0] x_out, output [15:0] y_out,
    output valid_out
);

    parameter IDLE = 2'b00;
    parameter BUSY = 2'b01;
    parameter DONE = 2'b10;

    reg[1:0] state, next_state;
    reg signed [15:0] x_reg, y_reg, theta_reg;
    reg [3:0] i_reg;


    wire signed [15:0] x_mux_out, y_mux_out, theta_mux_out, x_shift, y_shift;
    reg signed [15:0] x_add_out, y_add_out, theta_add_out;


    // atan values assigned for address from LUT table
    wire[3:0] address;
    assign address = i_reg;

    reg signed [15:0] atan_lut_out;
    always @(*) begin
        case (address)
            4'd0: atan_lut_out = 16'd12868;
            4'd1: atan_lut_out = 16'd7596;
            4'd2: atan_lut_out = 16'd4014;
            4'd3: atan_lut_out = 16'd2037;
            4'd4: atan_lut_out = 16'd1023;
            4'd5: atan_lut_out = 16'd512;
            4'd6: atan_lut_out = 16'd256;
            4'd7: atan_lut_out = 16'd128;
            4'd8: atan_lut_out = 16'd64;
            4'd9: atan_lut_out = 16'd32;
            4'd10: atan_lut_out = 16'd16;
            4'd11: atan_lut_out = 16'd8;
            4'd12: atan_lut_out = 16'd4;
            4'd13: atan_lut_out = 16'd2;
            4'd14: atan_lut_out = 16'd1;
            4'd15: atan_lut_out = 16'd0;
        endcase    
    end

    // Barrel shifters
//    assign x_shift = x_reg >>> i_reg;
//    assign y_shift = y_reg >>> i_reg;

    barrel_shifter bsx(
        .data_in(x_reg),
        .shift(i_reg),
        .data_out(x_shift)
    );
    
    barrel_shifter bsy(
        .data_in(y_reg),
        .shift(i_reg),
        .data_out(y_shift)
    );

    // Muxes for x, y, and theta
    assign x_mux_out = (state == IDLE) ? x_in : (state == DONE) ? x_add_out : x_add_out;
    assign y_mux_out = (state == IDLE) ? y_in : y_add_out;
    assign theta_mux_out = (state == IDLE) ? theta_in : theta_add_out;

    assign valid_out = (state == DONE);

    assign x_out = x_reg;
    assign y_out = y_reg;


    always @(*) begin
        // when msb of y == 1, then theta is negative
        if(y_reg[15] == 0) begin
            x_add_out = x_reg + y_shift;
            y_add_out = y_reg - x_shift;
            theta_add_out = theta_reg + atan_lut_out;
        end else begin
            x_add_out = x_reg - y_shift;
            y_add_out = y_reg + x_shift;
            theta_add_out = theta_reg - atan_lut_out;
        end
    end


    // register update logic
    always @(posedge clk) begin
        if(rst) begin
            x_reg <= 0;
            y_reg <= 0;
            theta_reg <= 0;
        end else begin
            x_reg <= x_mux_out;
            y_reg <= y_mux_out;
            theta_reg <= theta_mux_out;
        end
    end

    // FSM next state change logic
    always @(*) begin
        case (state)
            IDLE: next_state = operands_valid ? BUSY : IDLE;
            BUSY: next_state = (i_reg == 4'd15) ? DONE : BUSY;
            DONE: next_state = IDLE;
            default: next_state = IDLE; 

        endcase
    end

    // state update logic
    always @(posedge clk) begin
        if(rst)
            state <= IDLE;
        else
            state <= next_state;
    end

    // counter iterations
    always @(posedge clk) begin
        if(rst)
            i_reg <= 0;
        else if(state == BUSY)
            i_reg <= i_reg + 1;
        else
            i_reg <= 0;
    end 



    
endmodule