`default_nettype none

module tb_lights_fsm ();
    localparam TB_PHASE_TIME_S = 5;

    logic clk = 0;
    logic en = 0;
    logic rstn = 0;
    wire[7:0] lights;

    lights_fsm #(.PHASE_TIME_S(TB_PHASE_TIME_S)) dut (.*);

    initial begin
        $dumpfile("lights_fsm");
        $dumpvars(0, tb_lights_fsm);

        #1_000_000;
        $fatal(2, "Timeout Watchdog");
    end

    logic[7:0] expected_values [5]= '{
        {2'b10, 2'b10, 2'b10, 2'b10}, // INIT
        {2'b01, 2'b10, 2'b01, 2'b10}, // Car Green
        {2'b10, 2'b10, 2'b10, 2'b10}, // STOP
        {2'b10, 2'b01, 2'b10, 2'b01}, // Ped Green
        {2'b10, 2'b10, 2'b10, 2'b10}  // Stop
    };
    
    int timeout_cycles [5] = '{1, 5, 5, 5, 5};

    // reference model
    int expected_index = 0;
    int tb_timer = 0;
    bit tick = 0;
    always @(posedge clk) begin
        if (!rstn)
            expected_index <= 0;

        else if(en) begin
            tb_timer <= tb_timer + 1;
            tick <= 0;
            if (tb_timer >= timeout_cycles[expected_index] - 1) begin
                tick <= 1'b1;
                tb_timer <= 1'b0;
                expected_index <= expected_index + 1;
                if (expected_index >= 4)
                    expected_index <= 1;
            end
        end
    end

    // scoreboard
    logic[7:0] expected_value = 0;
    always @(posedge clk) begin
        expected_value <= expected_values[expected_index];
        if (expected_value != lights) 
            $fatal(2, "Expected_output and dut output mismatch: Expected_index=%0d", expected_index);
    end

    // stimulus
    always #10 clk = ~clk;
    
    initial begin
        rstn = 1;
        repeat(2) @(negedge clk);
        en = 1;
        
        repeat(200) @(negedge clk);
        en = 0;
        repeat(5) @(negedge clk);
        en = 1;
        repeat(10) @(negedge clk);
        rstn = 0;
        repeat(3) @(negedge clk);
        rstn = 1;
        repeat(20) @(negedge clk);

        $display("PASS");
    end

endmodule

`default_nettype wire