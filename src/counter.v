module counter(
    input clk,
    input start,
    input [7:0] m_time,
    output done
);
    reg [7:0] count = 0;
    assign done = start && count >= m_time;

    always @(posedge clk) begin
       if(start == 0) begin
           count <= 0;
       end
       else count <= done ? count : count + 1;
    end

endmodule
