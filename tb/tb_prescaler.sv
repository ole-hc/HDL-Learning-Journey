module tb_prescaler ();
    localparam DIV_FACTOR = 20;
    
    logic clk = 0, resetn = 0, en = 0, out; 

    prescaler #(.PRESCALE_FACTOR(DIV_FACTOR)) dut (.*);

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_prescaler);
    end

    // scoreboard
    int cycles = 0;
    bit out_prev_active = 0;
    always @(negedge clk) begin
        if (!resetn) begin
            cycles <= 0;
            out_prev_active <= 0;         
        end
        else if (en)            
            cycles <= cycles + 1;
        if (out) begin
            if (out_prev_active)
                $fatal(2, "Out active for multiple cycles");
            else begin
                out_prev_active <= 1;
                cycles <= 0;
            end
        end
        if (cycles >= DIV_FACTOR)
            $fatal(2, "Watchdog ERROR. No output signal detected in N=%d Clk cycles", DIV_FACTOR);
    end

    // stimulus
    always #10 clk = ~clk;

    initial begin
        #15 resetn = 1;
        #35 en = 1;

        repeat(3) @(negedge out);
        repeat(20) @(negedge clk);
        en = 0;
        repeat(20) @(negedge clk);
        en = 1;
        repeat(30) @(negedge clk);
        resetn = 0;
        repeat(2) @(negedge clk);
        resetn = 1;
        repeat(3) @(posedge out);

        $display("PASS");
        $finish;
    end

endmodule 