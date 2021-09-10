`timescale  1ns / 1ps  

module tb_key_input;

// key_input Parameters
parameter PERIOD  = 10, W = 4;


// key_input Inputs
reg   clk                                  = 0 ;
reg   [W - 1:0]  keys                      = 0 ;

// key_input Outputs
wire  [W - 1: 0]  key_press                ;


initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

key_input #(W)  u_key_input (
    .clk                     ( clk                   ),
    .keys                    ( keys       [W - 1:0]  ),

    .key_press               ( key_press  [W - 1: 0] )
);

initial
begin
    #PERIOD keys = 4'b0010;
    #(5*PERIOD) keys = 4'b0000;
end

endmodule