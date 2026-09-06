`default_nettype none

module lights_fsm #(
    PHASE_TIME_S=5
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

typedef enum logic[1:0] {
    INIT = 2'b00,
    CAR_GREEN = 2'b01,
    PED_GREEN = 2'b10,
    STOP = 2'b11
} lights_state_t;

lights_state_t current_state;
lights_state_t next_state;

// sequential state logic
logic[$clog2(PHASE_TIME_S) - 1:0] timer = 0;
bit tick;
always_ff @(posedge clk) begin 
    if (!rstn)
        current_state <= INIT;

    else if(en) begin
        if (current_state != INIT)
            timer <= timer + 1;
        if (timer >= PHASE_TIME_S - 1) begin
            timer <= 1'b0;
        end
        current_state <= next_state;
    end
end
assign tick = (timer >= PHASE_TIME_S - 1) ? 1 : 0;

// combinatorial next phase logic
bit restart_cycle = 0;
always_comb begin 
    case (current_state)
        INIT: begin 
            setLedsStop();
            next_state = CAR_GREEN;
        end

        CAR_GREEN: begin
            setLedsCarGreen();
            next_state = CAR_GREEN;
            restart_cycle = 0;
            if (tick)
                next_state = STOP;
        end

        PED_GREEN: begin
            setLedsPedGreen();
            next_state = PED_GREEN;
            restart_cycle = 1;
            if (tick)
                next_state = STOP;
        end

        STOP: begin
            setLedsStop();
            next_state = STOP;
            if (tick) begin   
                if (restart_cycle == 0)
                    next_state = PED_GREEN;
                else 
                    next_state = CAR_GREEN;
            end 
        end

        default: next_state = INIT; 
    endcase
end

// output logic
task automatic setLedsStop();
    lights = {2'b10, 2'b10, 2'b10, 2'b10};
endtask //automatic

task automatic setLedsCarGreen();
    lights = {2'b01, 2'b10, 2'b01, 2'b10};
endtask

task automatic setLedsPedGreen();
    lights = {2'b10, 2'b01, 2'b10, 2'b01};
endtask
endmodule;

`default_nettype wire
