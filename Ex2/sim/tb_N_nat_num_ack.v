`timescale 1ns/1ns
module tb_only_datapath #(parameter N=16);
reg N_valid;
reg [N-1:0]N_in;
reg clk;
reg rst;
reg ACK;
wire [1:0] state;
wire i_eq_N;
wire [N-1:0]sum;
wire sum_valid;

// instantiation of DUT
N_nat_num #(.N(N)) u0 (
    .clk(clk), .N_in(N_in),
    .N_valid(N_valid), .rst(rst),
    .ACK(ACK),
    .i_eq_1(i_eq_N),
    .state(state),
    .sum(sum), .sum_valid(sum_valid) 
);

// clock
initial clk = 1;
always #5 clk = ~clk;

initial begin
    N_in = 8'd4;
    N_valid = 0;
    ACK = 0;
    rst = 1;
    #10;
    rst = 0;
    #5;            
    N_valid = 1;
    #10;
    N_valid = 0;
    #250; // waiting for computation to finish

    ACK = 1;       
    #10;
    ACK = 0;       
end

initial begin
    $monitor("Time=%0t||N_in=%d||N_valid=%b||ACK=%b||sum=%d||sum_valid=%b", 
             $time, N_in, N_valid, ACK, sum, sum_valid);
    #400 $finish;
end
endmodule
