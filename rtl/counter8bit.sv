module counter8bit (
    input clk,
    input rstn,
    input en,
    output logic [7:0] out
);

    always_ff @(posedge clk, negedge rstn) begin
        if (!rstn)
            out <= 0;
        else if (en) begin
            out <= out + 1;            
        end
    end

endmodule 