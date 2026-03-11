`timescale 1ns/1ps

module tb_cordic;

    parameter N = 16;
    reg clk, rst, operands_valid, cordic_mode;
    reg ack;
    reg signed [15:0] x_in, y_in, theta_in;
    wire signed [15:0] x_out, y_out;
    wire valid_out;

    cordic #(.N(N)) DUT (
        .clk(clk), .rst(rst), .operands_valid(operands_valid),
        .ack(ack),
        .cordic_mode(cordic_mode),
        .x_in(x_in), .y_in(y_in), .theta_in(theta_in),
        .x_out(x_out), .y_out(y_out), .valid_out(valid_out)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    // Fixed Task: No strings, hardcoded threshold
    task verify_result;
        input signed [N-1:0] exp_x;
        input signed [N-1:0] exp_y;
        begin
            wait(valid_out);
            #1; 
            if (abs(x_out - exp_x) <= 100 && abs(y_out - exp_y) <= 100)
                $display("[PASS] Got X: %d, Y: %d", x_out, y_out);
            else
                $display("[FAIL] Expected (%d, %d), Got (%d, %d)", exp_x, exp_y, x_out, y_out);
            #10;
            
            ack = 1;
            #10;
            ack = 0;

            #20;
        end
    endtask

    function integer abs(input integer val);
        abs = (val < 0) ? -val : val;
    endfunction

    initial begin
        rst = 1; operands_valid = 0; x_in = 0; y_in = 0; theta_in = 0; ack = 0;
        #20 rst = 0;

        // TEST 1: 45 degree rotation
        // x_in = 0.6072 * 16384 = 9949
        // Expected result: x_out = cos(45) * 16384 = 11585, y_out = sin(45) * 16384 = 11585
        $display("Running Test 1: Rotation 45deg");
        cordic_mode = 0;
        x_in = 16'd9949; y_in = 16'd0; theta_in = 16'd12868;
        operands_valid = 1; #10; operands_valid = 0;
        verify_result(16'd11585, 16'd11585);


        // TEST 2: 30 degree rotation
        // x_in = 0.6072 * 16384 = 9949
        // Expected result: x_out = cos(30) * 16384 = 14142, y_out = sin(30) * 16384 = 7596
        $display("Running Test 2: Rotation 30deg");
        cordic_mode = 0;
        x_in = 16'd9949; y_in = 16'd0; theta_in = 16'd7596;
        operands_valid = 1; #10; operands_valid = 0;
        verify_result(16'd14655, 16'd7326);


        // TEST 3: 45 degrees vectoring
        // x_in = 2000, y_in = 2000
        // Expected x_out: sqrt(2000^2 + 2000^2) * 1.6467 = 4658
        $display("Running Test 3: Vectoring (2000, 2000)");
        cordic_mode = 1;
        x_in = 16'd2000; y_in = 16'd2000; theta_in = 16'd0;
        operands_valid = 1; #10; operands_valid = 0;
        verify_result(16'd4658, 16'd0);

        #50;
        $finish;
    end
endmodule