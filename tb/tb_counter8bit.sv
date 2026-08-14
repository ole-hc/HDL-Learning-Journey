module tb_counter8bit ();

    logic clk;
    logic rstn;
    logic en;
    logic [7:0] out;

    task automatic reset_stimulus();
        rstn = 0;
        repeat(2) @(negedge clk);
        rstn = 1;
    endtask //automatic
    
    counter8bit dut (.*);

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_counter8bit);
    end

    always #10 clk = ~clk;

    // reference model 
    logic [7:0] expected;
    always_ff @(posedge clk, negedge rstn) begin
        if (!rstn) expected <= '0;
        else if (en) expected <= expected + 1'b1;
    end

    // scoreboard
    always @(negedge clk) begin
        if (out !== expected)
            $fatal (2, "Reference Model and DUT mismatch: RM: %b | DUT: %b", out, expected); 
    end

    // stimulus
    initial begin
        {rstn, clk, en} = '0;
        en = 1;

        reset_stimulus();
        repeat(300) @(negedge clk);
        en = 0;
        repeat(2) @(negedge clk);
        en = 1;
        repeat(10) @(negedge clk);
        reset_stimulus();
        repeat(20) @(negedge clk);

        $display("PASS");
        $finish;
    end

endmodule 
