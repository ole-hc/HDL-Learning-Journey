module tb_prescaler ();
    localparam DIV_FACTOR = 4;
    
    logic clk = 0, rstn = 0, en = 0, out; 

    prescaler #(.PRESCALE_FACTOR(DIV_FACTOR)) dut (.*);

    initial begin
        $dumpfile("prescaler.vcd");
        $dumpvars(0, tb_prescaler);
    end

    localparam int EXPECTED_LOW = DIV_FACTOR - 1;
    int cycles = 0;
    always @(posedge clk) begin
        if (!rstn)  
            cycles <= 0;
        else if (out) begin
            if (cycles != EXPECTED_LOW) 
                $fatal(2, "Wrong period: expected %0d, measured %0d", EXPECTED_LOW, cycles);
            cycles <= 0;
        end
        else if (en) begin
            if (cycles >= EXPECTED_LOW)
                $fatal(2, "No Out Pulse after %0d active Cycles", cycles);
            cycles <= cycles + 1; 
        end
    end

    // watchdog
    initial begin
        #1_000_000;
        $fatal(2, "Timeout");
    end

    // stimulus
    always #10 clk = ~clk;

    initial begin
        #15 rstn = 1;
        #35 en = 1;

        repeat(3) @(negedge out);
        repeat(20) @(negedge clk);
        en = 0;
        repeat(20) @(negedge clk);
        en = 1;
        repeat(30) @(negedge clk);
        rstn = 0;
        repeat(2) @(negedge clk);
        rstn = 1;
        repeat(3) @(posedge out);

        $display("PASS");
        $finish;
    end

endmodule 