`define F_N 4
`timescale  1ns / 1ps  

module tb_request;     

// request Parameters  
parameter PERIOD  = 10;


// request Inputs
reg   clk380hz                             = 0 ;
reg   clk10hz                              = 0 ;
reg   rst                                  = 0 ;
reg   [7:0]  curr_floor                    = 0 ;
reg   [3:0]  running_state                 = 0 ;
reg   [3:0]  door_state                    = 4'b0100 ;
reg   [`F_N-1:0]  floor_in                 = 0 ;
reg   [`F_N-1:0]  up_in                    = 0 ;
reg   [`F_N-1:0]  down_in                  = 0 ;

// request Outputs
wire  [2:0]  req                           ;
wire  [7:0]  demand_state                  ;

always #(PERIOD/2)  clk380hz=~clk380hz;
always #(5*PERIOD)  clk10hz=~clk10hz;

// initial
// begin
//     #(PERIOD*2) rst  =  1;
// end

request  u_request (
    .clk380hz                ( clk380hz                  ),
    .clk10hz                 ( clk10hz                   ),
    .clk1hz                  ( clk1hz                    ),
    .rst                     ( rst                       ),
    .curr_floor              ( curr_floor     [7:0]      ),
    .running_state           ( running_state  [3:0]      ),
    .door_state              ( door_state     [3:0]      ),
    .floor_in                ( floor_in       [`F_N-1:0] ),
    .up_in                   ( up_in          [`F_N-1:0] ),
    .down_in                 ( down_in        [`F_N-1:0] ),

    .req                     ( req            [2:0]      ),
    .demand_state            ( demand_state   [7:0]      )
);

initial
begin
    #1000 up_in[2] = 1;
    #1000 down_in[1] = 1;
end

endmodule