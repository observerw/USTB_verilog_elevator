`timescale  1ns / 1ps 

module tb_control;    

// control Parameters 
parameter PERIOD = 10;
parameter INIT  = 0;  

// control Inputs
reg   clk10hz                              = 0 ;
reg   clk1hz                               = 0 ;
reg   rst                                  = 1 ;
reg   [2:0]  req                           = 0 ;

// control Outputs
wire  [7:0]  curr_floor                    ;
wire  [3:0]  running_state                 ;
wire  [3:0]  door_state                    ;
wire  [3:0]  state                         ;

always #(PERIOD/2) clk10hz = ~clk10hz;
always #(5*PERIOD) clk1hz = ~clk1hz;

control u_control (
    .clk10hz                 ( clk10hz              ),
    .clk1hz                  ( clk1hz               ),
    .rst                     ( rst                  ),
    .req                     ( req            [2:0] ),

    .curr_floor              ( curr_floor     [7:0] ),
    .running_state           ( running_state  [3:0] ),
    .door_state              ( door_state     [3:0] ),
    .state                   ( state          [3:0] )
);

initial
begin
    #PERIOD rst = 0;
    req = 3'b100;
    #(5*PERIOD) req = 3'b001;
    #(10*PERIOD) req = 3'b000;end

endmodule