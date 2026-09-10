`default_nettype none

module lights_fsm #(
    parameter int PHASE_TIME_S = 5
)(
    input wire clk,
    input wire en,
    input wire rstn,
    /*
        7 = Car1 Red 
        6 = Car1 Green
        5 = Ped1 Red
        4 = Ped1 Green
        3 = Car2 Red
        2 = Car2 Green
        1 = Ped1 Red
        0 = Ped2 Green
    */
    output logic[7:0] lights
);

if (PHASE_TIME_S < 2)
    $error("lights_fsm: PHASE_TIME_S muss >= 2 sein");

typedef enum logic[1:0] {
    INIT = 2'b00,
    CAR_GREEN = 2'b01,
    PED_GREEN = 2'b10,
    STOP = 2'b11
} lights_state_t;

localparam logic [7:0] LGT_ALL_RED   = {2'b10, 2'b10, 2'b10, 2'b10};
localparam logic [7:0] LGT_CAR_GREEN = {2'b01, 2'b10, 2'b01, 2'b10};
localparam logic [7:0] LGT_PED_GREEN = {2'b10, 2'b01, 2'b10, 2'b01};

localparam int T_WIDTH = $clog2(PHASE_TIME_S);

lights_state_t current_state;
lights_state_t next_state;
logic [T_WIDTH-1:0] timer;
logic restart_cycle, next_restart_cycle;
logic tick;

assign tick = (timer >= PHASE_TIME_S - 1);

// sequential state logic
always_ff @(posedge clk) begin 
    if (!rstn) begin
        current_state <= INIT;
        timer         <= '0;
        restart_cycle <= 1'b0;
    end

    else if (en) begin
        current_state <= next_state;
        restart_cycle <= next_restart_cycle;

        if (next_state != current_state)
            timer <= '0;
        else
            timer <= timer + 1'b1;
    end
end

// combinatorial next phase logic
always_comb begin
    next_state = current_state;
    next_restart_cycle = restart_cycle;

    unique case (current_state)
        INIT: begin
            next_state = CAR_GREEN;
        end

        CAR_GREEN: begin
            next_restart_cycle = 1'b0;
            if (tick)
                next_state = STOP;
        end

        PED_GREEN: begin
            next_restart_cycle = 1'b1;
            if (tick)
                next_state = STOP;
        end

        STOP: begin
            if (tick) begin
                if (restart_cycle)
                    next_state = CAR_GREEN;
                else
                    next_state = PED_GREEN;
            end
        end

        default: next_state = INIT;
    endcase
end


// output logic
always_comb begin
    unique case (current_state)
        CAR_GREEN:  lights = LGT_CAR_GREEN;
        PED_GREEN:  lights = LGT_PED_GREEN;
        INIT, STOP: lights = LGT_ALL_RED;
        default:    lights = LGT_ALL_RED;
    endcase
end

endmodule;

`default_nettype wire
