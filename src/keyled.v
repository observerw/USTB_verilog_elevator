module keyled (
    input clk,
    input key_in,
    output reg key_out = 0
);
reg [31:0] counter_low, counter_high;
parameter standerd_time = 500000;

always@(posedge clk) begin   
        if(key_in == 1'b1)
            counter_high <= counter_high + 1;
        else
            counter_high <= 0;  
    end
    
always@(posedge clk) begin
    if(key_in == 1'b0)
        counter_low <= counter_low + 1;
    else
        counter_low <= 0; 
end

always@(posedge clk) begin
    if(counter_low == standerd_time)
        key_out <= 0;
    else if(counter_high == standerd_time)
        key_out <= 1;
end

endmodule
