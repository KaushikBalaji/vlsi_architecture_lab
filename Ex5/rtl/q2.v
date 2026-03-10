module cordic_pipelined (
    input clk,
    input rst,
    input cordic_mode, 

    input signed [15:0] x_in,
    input signed [15:0] y_in,
    input signed [15:0] theta_in,

    output signed [15:0] x_out,
    output signed [15:0] y_out,
    output signed [15:0] theta_out
);


    // Pipeline registers - 16 registers
    reg signed [15:0] x_pipe [1:16];
    reg signed [15:0] y_pipe [1:16];
    reg signed [15:0] z_pipe [1:16];

//    wire [15:0] atan_lut [0:15];
//    assign atan_lut[0]=16'd12868; 
//    assign atan_lut[1]=16'd7596;
//    assign atan_lut[2]=16'd4014;  
//    assign atan_lut[3]=16'd2037;
//    assign atan_lut[4]=16'd1023;  
//    assign atan_lut[5]=16'd512;
//    assign atan_lut[6]=16'd256;   
//    assign atan_lut[7]=16'd128;
//    assign atan_lut[8]=16'd64;    
//    assign atan_lut[9]=16'd32;
//    assign atan_lut[10]=16'd16;   
//    assign atan_lut[11]=16'd8;
//    assign atan_lut[12]=16'd4;    
//    assign atan_lut[13]=16'd2;
//    assign atan_lut[14]=16'd1;    
//    assign atan_lut[15]=16'd0;

reg [15:0] atan_lut [0:15];
    initial begin
        $readmemh("atan_lut.mem", atan_lut); 
    end

    genvar i;
    
    generate
        for (i = 0; i < 16; i = i + 1) begin : cordic_stage
            wire signed [15:0] x_curr, y_curr, z_curr;
            wire signed [15:0] x_shift, y_shift;
            wire rotate_positive;

            // Stage 0 takes inputs directly; subsequent stages take from registers
            assign x_curr = (i == 0) ? x_in : x_pipe[i];
            assign y_curr = (i == 0) ? y_in : y_pipe[i];
            assign z_curr = (i == 0) ? theta_in : z_pipe[i];

            assign x_shift = x_curr >>> i;
            assign y_shift = y_curr >>> i;

            assign rotate_positive = (cordic_mode) ? y_curr[15] : ~z_curr[15];

            always @(posedge clk) begin
                if (rst) begin
                    x_pipe[i+1] <= 0;
                    y_pipe[i+1] <= 0;
                    z_pipe[i+1] <= 0;
                end else begin
                    if (rotate_positive) begin
                        x_pipe[i+1] <= x_curr - y_shift;
                        y_pipe[i+1] <= y_curr + x_shift;
                        z_pipe[i+1] <= z_curr - atan_lut[i];
                    end else begin
                        x_pipe[i+1] <= x_curr + y_shift;
                        y_pipe[i+1] <= y_curr - x_shift;
                        z_pipe[i+1] <= z_curr + atan_lut[i];
                    end
                end
            end
        end
    endgenerate

    assign x_out = x_pipe[16];
    assign y_out = y_pipe[16];
    assign theta_out = z_pipe[16];

endmodule