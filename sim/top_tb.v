`define F_N 4
`timescale  1ns / 100ps  

module tb_top;

// top Parameters      
parameter PERIOD  = 10;


// top Inputs
reg   clk380hz                             = 0 ;
reg   clk10hz                              = 0 ;
reg   clk1hz                               = 0 ;
reg   rst                                  = 1 ;
reg   [2*`F_N - 1:0]  external             = 0 ;
reg   [  `F_N - 1:0]  internal             = 0 ;


always #(PERIOD/2) clk380hz = ~clk380hz;
always #(5*PERIOD) clk10hz = ~clk10hz;
always #(10*PERIOD) clk1hz = ~clk1hz;

    wire [7:0] curr_floor;
    wire [3:0] running_state;
    wire [3:0] door_state;
    wire [2:0] req;
    wire [2*`F_N-1:0] demand_state;
    wire [3:0] state_dataBus;
    wire [15:0] number_dataBus;
    wire [15:0] signal_dataBus;
    wire posL, segL;
    wire posH, segH;

    request Request(
        .clk380hz(clk380hz), .clk10hz(clk10hz), .clk1hz(clk1hz),
        .rst(rst),
        .curr_floor(curr_floor),
        .running_state(running_state),
        .door_state(door_state),
        .floor_in(internal),
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

    num_segMsg    numbers(clk380hz, number_dataBus, posL, segL);
    signal_segMsg signals(clk380hz, signal_dataBus, posH, segH);

    assign number_dataBus = {state_dataBus[3:0], curr_floor[3:0]+1, 8'hff};
    assign signal_dataBus = {running_state[3:0], door_state[3:0], 8'b0};

initial
begin
    #PERIOD rst = 0;
    #(5*PERIOD) external[6] = 1;
    #(5*PERIOD) external[5] = 1;
end

endmodule