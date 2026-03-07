module barrel_shifter(
    input  signed [15:0] data_in,
    input  [3:0] shift,
    output signed [15:0] data_out
);

    wire signed [15:0] s1;
    wire signed [15:0] s2;
    wire signed [15:0] s3;

    assign s1 = shift[0] ? {data_in[15],data_in[15:1]} : data_in;
    assign s2 = shift[1] ? {{2{s1[15]}},s1[15:2]} : s1;
    assign s3 = shift[2] ? {{4{s2[15]}},s2[15:4]} : s2;
    assign data_out = shift[3] ? {{8{s3[15]}},s3[15:8]} : s3;

endmodule