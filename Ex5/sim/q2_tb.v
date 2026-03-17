`timescale 1ns / 1ps

module tb_cordic_pipelined;

    parameter N = 16;

    // Inputs
    reg clk;
    reg rst;
    reg cordic_mode;
    reg signed [N-1:0] x_in;
    reg signed [N-1:0] y_in;
    reg signed [N-1:0] theta_in;

    // Outputs
    wire signed [N-1:0] x_out;
    wire signed [N-1:0] y_out;
    wire signed [N-1:0] theta_out;

    // Instantiate the Unit Under Test (UUT)
    cordic_pipelined #(.N(N)) uut (
        .clk(clk),
        .rst(rst),
        .cordic_mode(cordic_mode),
        .x_in(x_in),
        .y_in(y_in),
        .theta_in(theta_in),
        .x_out(x_out),
        .y_out(y_out),
        .theta_out(theta_out)
    );

    always #5 clk = ~clk;


    // Task to apply inputs, wait for pipeline, and check results
    task run_test;
        input mode;
        input signed [15:0] xi, yi, zi;
        input signed [15:0] exp_x, exp_y, exp_z;
        input [8*35:1] test_name;
        
        reg signed [15:0] diff_x, diff_y, diff_z;
        begin
            @(negedge clk);
            cordic_mode = mode;
            x_in = xi;
            y_in = yi;
            theta_in = zi;

            repeat(16) @(negedge clk);
            
            diff_x = (x_out > exp_x) ? (x_out - exp_x) : (exp_x - x_out);
            diff_y = (y_out > exp_y) ? (y_out - exp_y) : (exp_y - y_out);
            diff_z = (theta_out > exp_z) ? (theta_out - exp_z) : (exp_z - theta_out);

            if (diff_x <= 20 && diff_y <= 20 && diff_z <= 20) begin
                $display("[PASS] %s", test_name);
                $display("Expected : X=%d, Y=%d, Theta=%d", exp_x, exp_y, exp_z);
                $display("Got      : X=%d, Y=%d, Theta=%d", x_out, y_out, theta_out);

            end else begin
                $display("[FAIL] %s", test_name);
                $display("       Expected : X=%d, Y=%d, Theta=%d", exp_x, exp_y, exp_z);
                $display("       Got      : X=%d, Y=%d, Theta=%d", x_out, y_out, theta_out);
            end
        end
    endtask

    initial begin
        clk = 0;
        rst = 1;
        cordic_mode = 0;
        x_in = 0;
        y_in = 0;
        theta_in = 0;

        #100;
        @(negedge clk) rst = 0;

        // Format: Q2.14
        
        // Test 1: Rotation Mode
        // Initial Vector : (0.5, 0.5) => (8192, 8192)
        // Rotation Angle : 30 degrees (pi/6 rad) ≈ 0.5236 => 8579
        // Expected X_out = 1.64676 * (0.5*cos(30) - 0.5*sin(30)) ≈ 0.30137 => 4938
        // Expected Y_out = 1.64676 * (0.5*sin(30) + 0.5*cos(30)) ≈ 1.12476 => 18428
        run_test(0, 16'd8192, 16'd8192, 16'd8579, 16'd4938, 16'd18428, 16'd0, "Rotation: (0.5,0.5) by 30 degrees");
        
        // Test 2: Rotation Mode
        // Initial Vector : (0.5, 0.25) => (8192, 4096)
        // Rotation Angle : 60 degrees (pi/3 rad) ≈ 1.0476 => 17164
        // Expected X_out = 1.64676 * (0.5*cos(60) - 0.25*sin(60)) ≈ 0.0335 => 904
        // Expected Y_out = 1.64676 * (0.5*sin(60) + 0.25*cos(60)) ≈ 0.558 => 15056

        run_test(0, 16'd8192, 16'd4096, 16'd17164, 16'd904, 16'd15056, 16'd0, "Rotation: (0.5,0.25) by 60 degrees");

        // Test 3: Vectoring Mode
        // Initial Vector : (0.8, 0.6) => (13107, 9830)
        // Expected Magnitude = sqrt(0.8^2 + 0.6^2) = 1.0
        // Expected X_out = 1.64676 * 1.0 = 1.64676 => 26980
        // Expected Z_out = atan(0.6/0.8) = 36.87 degrees ≈ 0.6435 rad => 10543
        run_test(1, 16'd13107, 16'd9830, 16'd0, 16'd26980, 16'd0, 16'd10543, "Vectoring: (0.8,0.6)");
        
        #50;
        $finish;
    end

endmodule