// test bench for both Q1 & Q2
`timescale 1ns/1ns

module tb_only_datapath #(parameter N=8);

reg N_valid;
reg [N-1:0]N_in;
reg clk;
reg rst;
//wire state;
wire [1:0] state;
wire [N-1:0]sum;
wire sum_valid;
wire i_eq_N;

// instantiation of DUT

N_nat_num #(.N(N)) u0 (
    .clk(clk),.N_in(N_in),
    .N_valid(N_valid), .rst(rst),
    .state(state),
//    .i_eq_1(i_eq_N),
	.i_eq_N(i_eq_N),
    .sum(sum), .sum_valid(sum_valid) 
    );
    
// clock
initial clk = 1;
always #5 clk = ~clk;


initial begin
N_in = 8'd10;

N_valid = 0;
rst = 1;
#10;
rst = 0;
#5;            
N_valid = 1;
#10;           
N_valid = 0;
#40;
N_valid = 1;
#10;
N_valid = 0;

end


initial begin
    $monitor("Time=%0t||N_in=%d||N_valid=%b||sum=%d||state=%b||sum_valid=%b||i_eq_N=%b", 
             $time, N_in, N_valid, sum, state, sum_valid,i_eq_N);
    #250 $finish;
end

endmodule
