`timescale 1ns/1ps

module tb_cordic_pipeline;

    parameter N = 16;
    reg clk, rst, cordic_mode;
    reg signed [15:0] x_in, y_in, theta_in;
    wire signed [15:0] x_out, y_out;

    cordic_pipelined #(.N(N)) DUT (
        .clk(clk), .rst(rst),
        .cordic_mode(cordic_mode),
        .x_in(x_in), .y_in(y_in), .theta_in(theta_in),
        .x_out(x_out), .y_out(y_out)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    // Fixed Task: No strings, hardcoded threshold
    task verify_result;
        input signed [N-1:0] exp_x;
        input signed [N-1:0] exp_y;
        begin
            if (abs(x_out - exp_x) <= 100 && abs(y_out - exp_y) <= 100)
                $display("[PASS] Expected (%d, %d), Got (%d, %d)", exp_x, exp_y, x_out, y_out);
            else
                $display("[FAIL] Expected (%d, %d), Got (%d, %d)", exp_x, exp_y, x_out, y_out);
            #10;
        end
    endtask

    function integer abs(input integer val);
        abs = (val < 0) ? -val : val;
    endfunction

    initial begin
        rst = 1; x_in = 0; y_in = 0; theta_in = 0;
        #20 rst = 0;

        // TEST 1: Rotation 45 degrees
        $display("Feeding Test 1: Rotation 45deg");
        cordic_mode = 0;
        x_in = 16'd9949; y_in = 16'd0; theta_in = 16'd12868;
        
        // Wait 16 clock cycles for the data to reach the output
        repeat(16) @(posedge clk); 
        #1; // Settling time
        verify_result(16'd11585, 16'd11585);
        
        
        // TEST 2: Rotation 60 degrees (Distinct change for waveform)
        // 60 degrees in your LUT scale = 60 * (12868 / 45) = 17157
        // Expected X: 16384 * cos(60) = 8192
        // Expected Y: 16384 * sin(60) = 14189
        $display("Feeding Test 2: Rotation 60deg");
        cordic_mode = 0;
        x_in = 16'd9949; y_in = 16'd0; theta_in = 16'd17157;
        
        repeat(16) @(posedge clk); 
        #1; // Settling time
        verify_result(16'd8192, 16'd14189);

        // TEST 3: Vectoring (2000, 2000)
        $display("Feeding Test 3: Vectoring (2000, 2000)");
        cordic_mode = 1;
        x_in = 16'd2000; y_in = 16'd2000; theta_in = 16'd0;
        
        repeat(16) @(posedge clk);
        #1;
        verify_result(16'd4658, 16'd0);

        #50;
        $finish;
    end
endmodule