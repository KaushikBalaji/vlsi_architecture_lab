`timescale 1ns/1ps

module tb_cordic_vectoring;

reg clk;
reg rst;
reg operands_valid;

reg [15:0] x_in;
reg [15:0] y_in;
reg [15:0] theta_in;

wire [15:0] x_out;
wire [15:0] y_out;
wire valid_out;

cordic_vectoring DUT (
    .clk(clk),
    .rst(rst),
    .operands_valid(operands_valid),
    .x_in(x_in),
    .y_in(y_in),
    .theta_in(theta_in),
    .x_out(x_out),
    .y_out(y_out),
    .valid_out(valid_out)
);

////////////////////////////////////
// clock
////////////////////////////////////

initial clk = 0;
always #5 clk = ~clk;

////////////////////////////////////
// test
////////////////////////////////////

integer expected_mag;
integer error;

initial begin

    rst = 1;
    operands_valid = 0;

    #20;
    rst = 0;

    // Vectoring test
    // Input vector (1,1)

    x_in = 16'd16384;  // 1.0
    y_in = 16'd16384;  // 1.0
    theta_in = 0;

    operands_valid = 1;
    #10;
    operands_valid = 0;

    // wait for result
    wait(valid_out);

    $display("x_out (scaled magnitude) = %d", x_out);
    $display("y_out (should be ~0)     = %d", y_out);

    // expected scaled magnitude
    expected_mag = 14071;

    error = x_out - expected_mag;
    if(error < 0) error = -error;

    if(error < 200)
        $display("MAGNITUDE TEST PASS");
    else
        $display("MAGNITUDE TEST FAIL");

    if(y_out < 100 && y_out > -100)
        $display("Y ZEROING PASS");
    else
        $display("Y ZEROING FAIL");

    #20;
    $finish;

end

endmodule