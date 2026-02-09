`timescale 1ns/1ns

module tb_only_datapath #(parameter N=4);

reg N_valid;
reg [N-1:0]N_in;
reg clk;
reg rst;

wire [N-1:0]sum;
wire sum_valid;

// instantiation of DUT

N_nat_num #(.N(N)) u0 (

    .clk(clk),.N_in(N_in),
    .N_valid(N_valid), .rst(rst),
    .sum(sum), .sum_valid(sum_valid) 
    );

// clock

initial clk = 1;
always #5 clk = ~clk;

initial begin

N_in = 8'd4;

N_valid = 0;
rst = 1;
#10;
N_valid = 1;
rst = 0;
#20;
N_valid = 0;

end

// 

initial begin
    $monitor("Time=%0t||N_in=%d||N_valid=%b||sum=%d||sum_valid=%b", 
             $time, N_in, N_valid, sum, sum_valid);
    #400 $finish;
end

endmodule
