//当开关状态与之前不同时，相应位置输出一个时钟周期的高电平信号（用开关模拟按钮）
module key_input #(parameter W = 8) (
    input clk,
    input [W - 1:0] keys,
    output reg [W - 1: 0] key_press = 0
);

reg [W - 1: 0] prev = 0;

always @(posedge clk) begin
    key_press <= prev ^ keys;
    prev <= keys;
end

endmodule
