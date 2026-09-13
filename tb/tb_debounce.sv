`default_nettype none

module tb_debounce ();
    localparam int TB_CLK_FREQUENCY_HZ = 1;
    localparam int TB_DEBOUNCE_PERIOD_MS = 20000;
    localparam int CYCLES = 20;

    logic clk = 0;
    logic rstn;
    logic signal = 0;
    wire debounced_signal;

    debounce #(
        .CLK_FREQUENCY_HZ(TB_CLK_FREQUENCY_HZ), 
        .DEBOUNCE_PERIOD_MS(TB_DEBOUNCE_PERIOD_MS)
    ) dut (.*);

    initial begin
        $dumpfile("debounce.vcd");
        $dumpvars(0, tb_debounce);

        // Watchdog
        #1_000_000;
        $fatal(2, "Watchdog Timeout");
    end

    // stimulus 
    task automatic apply_reset();
        rstn = 0;
        repeat(2) @(negedge clk);
        rstn = 1;
    endtask 

    always #10 clk = ~clk;

    initial begin
        apply_reset();

        //change to 1
        signal = 1;
        for (int i = 0; i < CYCLES; i++) begin
            @(negedge clk);
            if (debounced_signal !== 1'b0)
                $fatal(2, "Signal Changed too early: Expected %0d - Actual %0d | Signal=%0d", CYCLES, i, signal);
        end
        @(negedge clk);
        if (debounced_signal !== 1'b1)
            $fatal(2, "Signal did not change after expected cycle: Expected %0d | Signal=%0d", CYCLES, signal);
        repeat(200) @(negedge clk);

        // change to 0
        signal = 0;
        for (int i = 0; i < CYCLES; i++) begin
            @(negedge clk);
            if (debounced_signal !== 1'b1)
                $fatal(2, "Signal Changed too early: Expected %0d - Actual %0d | Signal=%0d", CYCLES, i, signal);
        end
        @(negedge clk);
        if (debounced_signal !== 1'b0)
            $fatal(2, "Signal did not change after expected cycle: Expected %0d | Signal=%0d", CYCLES, signal);
        repeat(200) @(negedge clk);

        $display("PASS");
        $finish;
    end

endmodule

`default_nettype wire