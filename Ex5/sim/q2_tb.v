`timescale 1ns / 1ps

module tb_cordic_pipelined;

    parameter N = 16;
    parameter LATENCY = 18;
    parameter NUM_TESTS = 5;

    reg clk;
    reg rst;
    reg cordic_mode;
    reg signed [N-1:0] x_in, y_in, theta_in;

    wire signed [N-1:0] x_out, y_out, theta_out;

    // DUT
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

    // ================================
    // Test Vectors (Streaming Inputs)
    // ================================
    reg mode     [0:NUM_TESTS-1];
    reg signed [15:0] xi [0:NUM_TESTS-1];
    reg signed [15:0] yi [0:NUM_TESTS-1];
    reg signed [15:0] zi [0:NUM_TESTS-1];

    reg signed [15:0] exp_x [0:NUM_TESTS-1];
    reg signed [15:0] exp_y [0:NUM_TESTS-1];
    reg signed [15:0] exp_z [0:NUM_TESTS-1];

    integer i;

    initial begin
        mode[0]=0; xi[0]=8192; yi[0]=8192; zi[0]=8579;  // 0.5, 0.5, 30 degree
        exp_x[0]=4938; exp_y[0]=18428; exp_z[0]=0;

        mode[1]=0; xi[1]=8192; yi[1]=4096; zi[1]=17164; // 0.5, 0.25, 60 degree
        exp_x[1]=904; exp_y[1]=15056; exp_z[1]=0;

        mode[2]=1; xi[2]=13107; yi[2]=9830; zi[2]=0;    // 0.8, 0.6, 0
        exp_x[2]=26980; exp_y[2]=0; exp_z[2]=10543;

        // Add 2 more tests
        mode[3]=0; xi[3]=8192; yi[3]=0; zi[3]=8579;     // 0.5, 0, 30 degree
        exp_x[3]=11683; exp_y[3]=6744; exp_z[3]=0;

        mode[4]=1; xi[4]=10000; yi[4]=5000; zi[4]=0;    // 0.6, 0.3, 0
        exp_x[4]=18414; exp_y[4]=0; exp_z[4]=7599;
    end

    // ================================
    // Clock + Reset
    // ================================
    initial begin
        clk = 0;
        rst = 1;
        x_in = 0; y_in = 0; theta_in = 0;
        cordic_mode = 0;

        #50;
        @(negedge clk) rst = 0;
    end

    // ================================
    // STREAM INPUTS
    // ================================
    initial begin
        @(negedge rst);

        for (i = 0; i < NUM_TESTS; i = i + 1) begin
            @(negedge clk);
            cordic_mode = mode[i];
            x_in = xi[i];
            y_in = yi[i];
            theta_in = zi[i];

            $display("[IN ] Cycle %0d -> X=%d Y=%d Z=%d Mode=%0d",
                     i, xi[i], yi[i], zi[i], mode[i]);
        end
    end

    // ================================
    // CHECK OUTPUT STREAM
    // ================================
    integer out_idx = 0;
    integer cycle = 0;

    always @(negedge clk) begin
        if (!rst) begin
            cycle = cycle + 1;

            // Start checking after latency
            if (cycle >= LATENCY && out_idx < NUM_TESTS) begin
                check_output(out_idx);
                out_idx = out_idx + 1;
            end
        end
    end

    // ================================
    // CHECK TASK
    // ================================
    task check_output;
        input integer idx;

        reg signed [15:0] dx, dy, dz;
        begin
            dx = (x_out > exp_x[idx]) ? (x_out - exp_x[idx]) : (exp_x[idx] - x_out);
            dy = (y_out > exp_y[idx]) ? (y_out - exp_y[idx]) : (exp_y[idx] - y_out);
            dz = (theta_out > exp_z[idx]) ? (theta_out - exp_z[idx]) : (exp_z[idx] - theta_out);

            $display("[OUT] Cycle %0d -> X=%d Y=%d Z=%d",
                     cycle, x_out, y_out, theta_out);

            if (dx <= 20 && dy <= 20 && dz <= 20) begin
                $display("[PASS] Test %0d\n", idx);
            end else begin
                $display("[FAIL] Test %0d", idx);
                $display("Expected X=%d Y=%d Z=%d\n",
                         exp_x[idx], exp_y[idx], exp_z[idx]);
            end
        end
    endtask

    initial begin
        #500;
        $finish;
    end

endmodule