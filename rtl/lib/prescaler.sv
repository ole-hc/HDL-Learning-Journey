module prescaler #(
    PRESCALE_FACTOR = 1000
) (
    input clk,
    input resetn,
    input en,
    output out
);
    localparam MAX_VALUE = PRESCALE_FACTOR - 1;

    logic [$clog2(MAX_VALUE) - 1:0] counter;
    always_ff @(posedge clk) begin 
        if (!resetn || counter == MAX_VALUE) 
            counter <= 0;
        else if (en) 
            counter <= counter + 1;
    end

    assign out = (counter === MAX_VALUE) ? 1 : 0; 

endmodule
