module tb_pwm ();
    localparam DUT_CYCLES_ON = 10;
    localparam  DUT_CYCLES_OFF = 5;

    logic clk = 0;
    logic rstn = 0;
    logic en = 0;
    wire out;

    pwm #(.CYCLES_ON(DUT_CYCLES_ON), .CYCLES_OFF(DUT_CYCLES_OFF)) dut (.*);

    task automatic stim_reset();
        rstn = 0;
        repeat(2) @(negedge clk);
        rstn = 1;
    endtask //automatic

    initial begin
        $dumpfile("pwm.vcd");
        $dumpvars(0, tb_pwm);
    end

    // watchdog
    initial begin
        #1_000_000;
        $fatal(2, "Timeout");
    end

    localparam N = DUT_CYCLES_ON + DUT_CYCLES_OFF;
    bit [N-1:0] expected_values = {{DUT_CYCLES_OFF{1'b0}}, {DUT_CYCLES_ON{1'b1}}};

    int ref_index;
    logic expected_out;

    always @(posedge clk) begin
        if (!rstn) begin
            expected_out <= 1'b0;
            ref_index    <= 0;
        end
        else if (en) begin
            expected_out <= expected_values[ref_index];
            ref_index    <= (ref_index >= N-1) ? 0 : ref_index + 1;
        end
    end

    // ---- Scoreboard ----
    always @(posedge clk)
        if (out !== expected_out)
            $fatal(2, "t=%0t out=%0b expected=%0b index=%0d rstn=%0b en=%0b",
                   $time, out, expected_out, ref_index, rstn, en);

    // stimulus
    always #10 clk = ~clk;

    initial begin
        en = 1;
        stim_reset();

        repeat(3) @(negedge out);
        repeat(12) @(negedge clk);
        en = 0;
        repeat(20) @(negedge clk);
        en = 1;
        repeat(30) @(negedge clk);
        stim_reset();
        repeat(3) @(posedge out);

        $display("PASS");
        $finish;
    end

endmodule