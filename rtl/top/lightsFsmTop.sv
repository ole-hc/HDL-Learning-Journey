`default_nettype none

module lightsFsmTop #(
    parameter int PRESCALE_FACTOR = 100_000_000
) (
    input wire CLK,
    input wire [4:0] BTN,
    output logic [7:0] LED
);

    logic board_reset;
    assign board_reset = ~BTN[4];

    logic scaled_pulse;
    prescaler #(.PRESCALE_FACTOR(PRESCALE_FACTOR)) clk_prescaler (
        .clk(CLK),
        .rstn(board_reset),
        .en(1'b1),
        .out(scaled_pulse)
    );

    lights_fsm #() lightsFsm (
        .clk(CLK),
        .en(scaled_pulse),
        .rstn(board_reset),
        .lights(LED[7:0])
    );

endmodule

`default_nettype wire