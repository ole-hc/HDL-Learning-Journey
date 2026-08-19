`default_nettype none

module prescaler #(
    PRESCALE_FACTOR = 1000
) (
    input wire clk,
    input wire rstn,
    input wire en,
    output logic out
);
// PRESCALE_FACTOR >= 2

    localparam MAX_VALUE = PRESCALE_FACTOR - 1;

    logic [$clog2(PRESCALE_FACTOR) - 1:0] counter;
    always_ff @(posedge clk) begin 
        if (!rstn) begin
            counter <= 0;
        end
        else if (en) begin
            if (counter == MAX_VALUE)
                counter <= 0;
            else begin  
                counter <= counter + 1;
            end
        end 
    end

    assign out = (counter == MAX_VALUE) && en; 

endmodule
