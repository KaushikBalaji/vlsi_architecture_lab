module cordic_pipelined #(parameter N = 16) (
    input clk,
    input rst,
    input cordic_mode, 

    input signed [N-1:0] x_in,
    input signed [N-1:0] y_in,
    input signed [N-1:0] theta_in,

    output signed [N-1:0] x_out,
    output signed [N-1:0] y_out,
    output signed [N-1:0] theta_out
);


    // Pipeline registers - 16 registers
    reg signed [N-1:0] x_pipe [1:16];
    reg signed [N-1:0] y_pipe [1:16];
    reg signed [N-1:0] z_pipe [1:16];

    reg [N-1:0] atan_lut [0:15];
    initial begin
        $readmemh("atan_lut.mem", atan_lut); 
    end

    genvar i;
    
    generate
        for (i = 0; i < 16; i = i + 1) begin : cordic_stage
            wire signed [N-1:0] x_curr, y_curr, z_curr;
            wire signed [N-1:0] x_shift, y_shift;
            wire rotate_positive;

            // Stage 0 takes inputs directly; subsequent stages take from registers
            assign x_curr = (i == 0) ? x_in : x_pipe[i];
            assign y_curr = (i == 0) ? y_in : y_pipe[i];
            assign z_curr = (i == 0) ? theta_in : z_pipe[i];

            assign x_shift = x_curr >>> i;
            assign y_shift = y_curr >>> i;

            assign rotate_positive = (cordic_mode) ? y_curr[N-1] : ~z_curr[N-1];

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