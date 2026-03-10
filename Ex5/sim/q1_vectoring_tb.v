`timescale 1ns / 1ps

module tb_cordic_vectoring();

    reg clk;
    reg rst;
    reg operands_valid;
    reg [15:0] x_in, y_in, theta_in;
    
    wire [15:0] x_out, y_out;
    wire valid_out;

    // Instantiate UUT
    cordic_vectoring uut (
        .clk(clk), .rst(rst), .operands_valid(operands_valid), 
        .x_in(x_in), .y_in(y_in), .theta_in(theta_in), 
        .x_out(x_out), .y_out(y_out), .valid_out(valid_out)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Task for self-testing
    task check_results;
        input [15:0] expected_x_min; // Minimum expected magnitude
        input [15:0] expected_x_max; // Maximum expected magnitude
        begin
            wait(valid_out);
            #1; // Small delay to let signals settle
            
            // In vectoring mode, y_out should be very close to 0
            if (y_out > 16'h0005 && y_out < 16'hFFF0) begin
                $display("FAIL: y_out did not converge to zero. Value: %d", $signed(y_out));
            end else if (x_out < expected_x_min || x_out > expected_x_max) begin
                $display("FAIL: x_out (Magnitude) out of expected range. Got: %d", x_out);
            end else begin
                $display("PASS: x_out=%d, y_out=%d", $signed(x_out), $signed(y_out));
            end
        end
    endtask

    initial begin
        // Initialize
        clk = 0; rst = 1; operands_valid = 0;
        x_in = 0; y_in = 0; theta_in = 0;

        #20 rst = 0; #10;

        // --- Test Case 1: 45 Degrees ---
        // Vector (2000, 2000). Expected Mag approx 2000 * 1.414 * 1.647 = 4657
        $display("Running Test 1: (2000, 2000)...");
        x_in = 16'd2000; y_in = 16'd2000; theta_in = 0;
        operands_valid = 1; #10; operands_valid = 0;
        check_results(4650, 4665); 

        #50;

        // --- Test Case 2: Negative Y ---
        // Vector (3000, -3000). Expected Mag approx 3000 * 1.414 * 1.647 = 6985
        $display("Running Test 2: (3000, -3000)...");
        x_in = 16'd3000; y_in = -16'd3000; theta_in = 0;
        operands_valid = 1; #10; operands_valid = 0;
        check_results(6980, 6995);

        #100;
        $display("Simulation Complete.");
        $finish;
    end
      
endmodule