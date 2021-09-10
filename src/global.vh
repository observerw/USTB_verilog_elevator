`ifndef __GLOBAL_VH__
`define __GLOBAL_VH__ 0

//常数
//时间常数
`define OPEN_TIME 8'd5    //开门持续时间 
`define MOVE_TIME 8'd1    //层间移动时间

//元参数
`define F_N 4     //楼层数量

//状态码，留出部分位长用于拓展
//运行状态
`define RS_UP   4'b0000
`define RS_DOWN 4'b0001
`define RS_STOP 4'b0010

//门开关状态
`define DS_OPEN  4'b0011
`define DS_CLOSE 4'b0100

`define INVALID 4'b1111

`endif