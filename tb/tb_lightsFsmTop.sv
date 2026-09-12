`default_nettype none

module tb_lightsFsmTop ();
    localparam PRESCALE_PARAM = 1;
    localparam TB_PHASE_TIME_S = 5;
    localparam int N_STEPS = 5;

    logic CLK = 0;
    logic [4:0] BTN = 0;
    logic [7:0] LED;

    lightsFsmTop #(.PRESCALE_FACTOR(PRESCALE_PARAM)) dut (.*);

    initial begin
        $dumpfile("lightsFsmTop");
        $dumpvars(0, tb_lightsFsmTop);

        #1_000_000;
        $fatal(2, "Timeout Watchdog");
    end

    logic[7:0] expected_values [N_STEPS];
    int timeout_cycles [N_STEPS];
    initial begin
        expected_values[0] = {2'b10, 2'b10, 2'b10, 2'b10}; // INIT
        expected_values[1] = {2'b01, 2'b10, 2'b01, 2'b10}; // Car Green
        expected_values[2] = {2'b10, 2'b10, 2'b10, 2'b10}; // STOP
        expected_values[3] = {2'b10, 2'b01, 2'b10, 2'b01}; // Ped Green
        expected_values[4] = {2'b10, 2'b10, 2'b10, 2'b10}; // Stop

        timeout_cycles[0] = 1;
        timeout_cycles[1] = 5;
        timeout_cycles[2] = 5;
        timeout_cycles[3] = 5;
        timeout_cycles[4] = 5; 
    end

    // reference model
    int expected_index = 0;
    int tb_timer = 0;
 
    always @(posedge CLK) begin
        if (BTN[4] == 1'b1) begin
            expected_index <= 0;
            tb_timer <= 0;
        end
        else begin // en = 1'b1 in top module
            if (tb_timer >= timeout_cycles[expected_index] - 1) begin
                tb_timer <= 0;
                expected_index <= (expected_index >= N_STEPS - 1) ? 1 : expected_index + 1;
            end
            else begin
                tb_timer <= tb_timer + 1;
            end
        end
    end
 
    // Scoreboard 
    logic [7:0] expected_value;
    assign expected_value = expected_values[expected_index];
 
    always @(posedge CLK) begin
        if (expected_value !== LED)
            $fatal(1, "t=%0t Mismatch: DUT=%08b RM=%08b step=%0d",
                   $time, LED, expected_value, expected_index);
    end


    // stimulus
    always #10 CLK = ~CLK;
    
    task automatic apply_reset(input int cycles);
        BTN[4] = 1;
        repeat(2) @(negedge CLK);
        BTN[4] = 0;
    endtask
 
    initial begin
        apply_reset(3);
        repeat(2)   @(negedge CLK);
 
        repeat(200) @(negedge CLK);
 
        repeat(5)   @(negedge CLK);
        repeat(10)  @(negedge CLK);
 
        apply_reset(3);
        repeat(20)  @(negedge CLK);
 
        $display("PASS");
        $finish;
    end


endmodule

`default_nettype wire
