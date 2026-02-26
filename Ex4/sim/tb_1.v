`timescale 1ns / 1ns

module tb_1;

parameter N = 8;

reg clk;
reg rst;
reg N_valid;
reg ack;
reg [N-1:0] N_in;

wire sum_valid;
wire [N-1:0] sum;

// Instantiate DUT
q1 #(N) dut (
    .clk(clk),
    .rst(rst),
    .N_valid(N_valid),
    .ack(ack),
    .N_in(N_in),
    .sum_valid(sum_valid),
    .sum(sum)
);

// Clock generation (10ns period)
always #5 clk = ~clk;

initial begin
    clk = 0;
    rst = 1;
    N_valid = 0;
    ack = 0;
    N_in = 0;

    // Release reset
    #10 rst = 0;

    // Apply input N = 4
    #10;
    N_in = 4;
    N_valid = 1;
    #10;
    N_valid = 0;

    // Wait for result
    wait(sum_valid);

    $display("Sum of squares = %d", sum);

    // Send acknowledge
    #10 ack = 1;
    #10 ack = 0;

    #20;
    
    // Test 2
    rst = 1;
     #10 rst = 0;
     
     #10;
     N_in = 5;
     N_valid = 1;
     #10;
     N_valid = 0;
     
     wait(sum_valid);
     $display("Sum of squares = %d", sum);

    // Send acknowledge
    #10 ack = 1;
    #10 ack = 0;

    #20;
     
    
    
    $finish;
end

endmodule
