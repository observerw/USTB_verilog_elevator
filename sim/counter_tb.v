`timescale  1ns / 1ps  

module tb_counter;     

// counter Parameters  
parameter PERIOD  = 10;


// counter Inputs
reg   clk                                  = 0 ;
reg   start                                = 0 ;
reg st = 0;
reg   [7:0]  m_time                        = 8'd10 ;
reg [7:0] fuck = 0;

// counter Outputs
wire  done                                 ;


always #(PERIOD/2) clk = ~clk;

counter  u_counter (
    .clk                     ( clk           ),
    .start                   ( start         ),
    .m_time                  ( m_time  [7:0] ),

    .done                    ( done          )
);

initial
begin
    #PERIOD st = 1;
    #(20*PERIOD) st = 1;
end

always @(posedge clk) begin
    if(st == 1) start = 1;
    else begin
        start = 0;
        st = 0;
    end
end

always @(*) begin
    if(done == 1) begin
        fuck = fuck + 1;
        start = 0;
    end
    else begin
        start = 1;
    end
end

endmodule