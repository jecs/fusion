module levels_state_machine(
    clock,
    reset,
    toggle,
    level,
    level_update
);

    input wire clock;
    input wire reset;
    input wire toggle;
    parameter DEFAULT_LEVEL = 4'd0;
    parameter MAX_LEVEL = 4'd10;
    output reg [3:0] level = DEFAULT_LEVEL;
    output reg level_update = 1'b0;

    parameter TOGGLE_LOW = 1'b0;
    parameter TOGGLE_HIGH = 1'b1;
    reg state = TOGGLE_LOW;

    always @(posedge clock) begin
        state <= (reset | ~toggle) ? TOGGLE_LOW : TOGGLE_HIGH;
        if(reset) begin
            level_update <= 1'b0;
            level <= 4'd0;
        end
        else if(state == TOGGLE_LOW && toggle) begin
            level_update <= 1'b1;
            level <= (level == MAX_LEVEL) ? 4'd0 : (level+4'd1);
        end
        else begin
            level_update <= 1'b0;
            level <= level;
        end
    end
endmodule
