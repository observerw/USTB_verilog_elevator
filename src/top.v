`include "./global.vh"
module top(
    input clk100mhz,
    input rst_in,                     //高电平异步复位
    input  [2*`F_N - 1:0] external,   //电梯外部按键
    input  [  `F_N - 1:0] internal,   //电梯内部按键
    output [2*`F_N-1:0] LED,          //需求LED指示
    output [3:0] posH,
    output [7:0] segH,
    output [3:0] posL,
    output [7:0] segL
);

    wire clk380hz, clk10hz, clk1hz;
    clkDiv cd(clk100mhz, clk380hz, clk10hz, clk1hz);

    wire [3:0] inter_keys;
    genvar i;
    generate
        for(i = 0; i < `F_N; i = i + 1) begin : KEYLED
            keyled led(clk100mhz, internal[i], inter_keys[i]);
        end
    endgenerate
    keyled rst_key(clk100mhz, rst_in, rst);

    wire [7:0] curr_floor;
    wire [3:0] running_state;
    wire [3:0] door_state;
    wire [2:0] req;
    wire [2*`F_N-1:0] demand_state;
    wire [3:0] state_dataBus;
    wire [15:0] number_dataBus;
    wire [15:0] signal_dataBus;

    request Request(
        .clk380hz(clk380hz), .clk10hz(clk10hz), .clk1hz(clk1hz),
        .rst(rst),
        .curr_floor(curr_floor),
        .running_state(running_state),
        .door_state(door_state),
        .floor_in(inter_keys),
        .up_in(external[2*`F_N-1:`F_N]),
        .down_in(external[`F_N-1:0]),
        .req(req),
        .demand_state(demand_state)     
    );

    control Control(
        .clk380hz(clk380hz), .clk10hz(clk10hz), .clk1hz(clk1hz),
        .rst(rst),
        .req(req),
        .curr_floor(curr_floor),
        .running_state(running_state),
        .door_state(door_state),
        .state(state_dataBus)
    );

    assign LED = demand_state;
    assign number_dataBus = {state_dataBus[3:0], curr_floor[3:0]+1, 8'hff};
    assign signal_dataBus = {running_state[3:0], door_state[3:0], `INVALID, `INVALID};
    num_segMsg    numbers(clk380hz, number_dataBus, posL, segL);
    signal_segMsg signals(clk380hz, signal_dataBus, posH, segH);

endmodule
