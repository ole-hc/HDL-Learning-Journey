`default_nettype none

module pwm #(
    CYCLES_ON=1,
    CYCLES_OFF=1
)(
    input wire clk,
    input wire rstn,
    input wire en,
    output logic out
);
    if (CYCLES_OFF <= 0 || CYCLES_ON <= 0) begin
        $error("PWM: Faulty initiation values - have to be greater than 0");
    end

    localparam N = CYCLES_ON + CYCLES_OFF;
    logic [$clog2(N) - 1:0] counter;

    always_ff @(posedge clk) begin
        if (!rstn) begin
            out <= 0;
            counter <= 0;
        end

        else if (en) begin
            if (counter < CYCLES_ON) begin
                counter <= counter + 1;
                out <= 1;
            end

            else if (counter < N - 1) begin
                counter <= counter + 1;
                out <= 0;
            end

            else begin
                counter <= 0;
                out <= 0;
            end
        end
    end

endmodule

`default_nettype wire