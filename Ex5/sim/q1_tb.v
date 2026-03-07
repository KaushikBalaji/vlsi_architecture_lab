`timescale 1ns/1ps

module tb_cordic_rotation;

reg clk;
reg rst;
reg operands_valid;

reg [15:0] x_in;
reg [15:0] y_in;
reg [15:0] theta_in;

wire [15:0] x_out;
wire [15:0] y_out;
wire valid_out;
wire done;

cordic_rotation DUT (
    .clk(clk),
    .rst(rst),
    .operands_valid(operands_valid),
    .x_in(x_in),
    .y_in(y_in),
    .theta_in(theta_in),
    .x_out(x_out),
    .y_out(y_out),
    .done(done),
    .valid_out(valid_out)
);

/////////////////////////////////////////////////
// clock
/////////////////////////////////////////////////

initial clk = 0;
always #5 clk = ~clk;

/////////////////////////////////////////////////
// test
/////////////////////////////////////////////////

integer expected;
integer error;

initial begin

    rst = 1;
    operands_valid = 0;

    #20;
    rst = 0;

    // Test: 45 degree rotation
    x_in = 16'd9949;      // K scaling
    y_in = 16'd0;
    theta_in = 16'd12868; // pi/4

    operands_valid = 1;
    #10;
    operands_valid = 0;

    // wait for result
    wait(valid_out);

    $display("x_out = %d", x_out);
    $display("y_out = %d", y_out);

    expected = 11585;

    error = x_out - expected;
    if(error < 0) error = -error;

    if(error < 100)
        $display("COS TEST PASS");
    else
        $display("COS TEST FAIL");

    error = y_out - expected;
    if(error < 0) error = -error;

    if(error < 100)
        $display("SIN TEST PASS");
    else
        $display("SIN TEST FAIL");

    #20;
    $finish;

end

endmodule