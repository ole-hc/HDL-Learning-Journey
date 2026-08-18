module tb_ledCounter ();
    localparam PRESCALE_PARAM = 10;

    logic CLK = 0;
    logic [4:0] BTN = 0;
    logic [7:0] LED;

    ledCounter #(.PRESCALE_FACTOR(PRESCALE_PARAM)) dut (.*);

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_ledCounter);
    end

    always #10 CLK = ~CLK;

    // reference model + scoreboard
    int cycles = 1;
    int previous_led_value = 0;
    always @(negedge CLK) begin
        cycles <= cycles + 1;
        
        if (BTN[4] == 1'b1) begin
            if (LED != 0)
                $fatal(2, "Counter != 0 on Reset");
            cycles <= 1;
            previous_led_value <= 0;
        end
        else if (cycles == PRESCALE_PARAM) begin
            if (LED != previous_led_value + 1)
                $fatal(2, "Counting error: After %0d cycles LED Output was %0d instead of expected %0d", cycles, LED, (previous_led_value + 1));
            previous_led_value <= LED;
            cycles <= 1;
        end
        else if (LED != previous_led_value)
            $fatal(2, "LED changed value too early");
    end

    task automatic applyReset();
        BTN[4] = 1;
        repeat(2) @(negedge CLK);
        BTN[4] = 0;   
    endtask //automatic

    // watchdog
    initial begin
        #1_000_000;
        $fatal(2, "Watchdog Timeout");
    end

    // stimulus
    initial begin
        applyReset();
        repeat(50) @(negedge CLK);
        applyReset();
        repeat(250) @(negedge CLK);
        
        $display("PASS");
        $finish;
    end

endmodule