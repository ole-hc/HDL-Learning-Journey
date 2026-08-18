`default_nettype none

module ledCounter #(
    PRESCALE_FACTOR = 100_000_000
) (
    input CLK,
    input [4:0] BTN,
    output [7:0] LED
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
    
    counter8bit counter (
        .clk(CLK),
        .rstn(board_reset),
        .en(scaled_pulse),
        .out(LED[7:0])
    );

endmodule