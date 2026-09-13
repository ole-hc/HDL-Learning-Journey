`default_nettype none

module debounce #(
    parameter int CLK_FREQUENCY_HZ=100_000_000,
    parameter int DEBOUNCE_PERIOD_MS=20
) (
    input wire clk,
    input wire rstn,
    input wire signal,
    output logic debounced_signal
);

    if (CLK_FREQUENCY_HZ < 1)
        $fatal("Faulty configuration for specified clk period: < 1");
    if (DEBOUNCE_PERIOD_MS < 1)
        $fatal("Faulty configuration for specified debounce duration: < 1");
    if (CLK_FREQUENCY_HZ * DEBOUNCE_PERIOD_MS < 1000)
        $fatal("CLK_FREQUENCY_HZ is too slow to reach DEBOUNCE_PERIOD_MS");

    localparam longint DEBOUNCE_PERIOD_CYCLES = (DEBOUNCE_PERIOD_MS * CLK_FREQUENCY_HZ) / 1000;
    logic [$clog2(DEBOUNCE_PERIOD_CYCLES - 1): 0] debounce_counter;

    always_ff @(posedge clk) begin
        if (!rstn) begin
            debounce_counter <= 0;
            debounced_signal <= 0;
        end

        else begin
            if (debounced_signal != signal)
                debounce_counter <= debounce_counter + 1;
            else 
                debounce_counter <= 0;

            if (debounce_counter >= DEBOUNCE_PERIOD_CYCLES) begin
                debounced_signal <= signal;
                debounce_counter <= 0;
            end
        end 
    end

endmodule

`default_nettype wire