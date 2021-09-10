`include "./global.vh"
module control (
    input clk380hz,
    input clk10hz,
    input clk1hz,
    input rst,                      //高电平复位
    input      [2:0] req,           //请求
    output     [7:0] curr_floor,    //当前楼层
    output reg [3:0] running_state, //运行状态
    output reg [3:0] door_state,    //门开关状态
    output     [3:0] state          //状态机状态
);

    //状态机参数
    parameter INIT       = 4'd0,
              UP         = 4'd1,     //上行
              DOWN       = 4'd2,     //下行
              UP_OPEN    = 4'd3,     //上行开门
              UP_CLOSE   = 4'd4,     //上行关门
              DOWN_OPEN  = 4'd5,     //下行开门
              DOWN_CLOSE = 4'd6;     //下行关门

    reg [3:0] curr = INIT, next;
    reg [7:0] curr_pos = 0;         //当前楼层，从0开始计数
    assign curr_floor = curr_pos;   //楼层显示
    assign state = curr;

    //指令
    wire go_up = req[2];
    wire go_down = req[1];
    wire open_door = req[0];

    //计时器
    reg cd_start = 0;
    wire cd_done;
    reg ce_start = 0;
    wire ce_done;
    counter c_door(clk1hz, cd_start, `OPEN_TIME, cd_done);
    counter c_elev(clk1hz, ce_start, `MOVE_TIME, ce_done);

    //计时模块的输入驱动always块
    always @(posedge clk10hz or posedge rst) begin
        if(rst == 1) begin
            {ce_start, cd_start, curr_pos} <= 0;
        end
        else case (curr)
            UP: begin
                if(ce_done == 1) begin                                              //如果计时完成
                    curr_pos <= curr_pos == `F_N - 1 ? `F_N - 1 : curr_pos + 1'b1;  //则向上移动一层
                    ce_start <= 0;                                                  //且复位开始信号
                end
                else ce_start <= 1;                                                 //否则将开始计时信号置为1
            end
            DOWN: begin
                if(ce_done == 1) begin
                    curr_pos <= curr_pos == 0 ? 0 : curr_pos - 1'b1;
                    ce_start <= 0;
                end
                else ce_start <= 1;
            end
            UP_OPEN: begin
                cd_start <= ~cd_done;
            end
            DOWN_OPEN: begin
                cd_start <= ~cd_done;
            end
            default: begin
                ce_start <= 0;
                cd_start <= 0;
            end
        endcase     
    end


    //状态转换的always #1
    always @(posedge clk10hz or posedge rst) begin
        curr <= rst == 1 ? INIT : next;
    end

    //状态转换的always #2
    always @(*) begin
        case (curr)
            INIT: begin
                next = req > 0 ? UP_CLOSE : INIT;
            end
            UP_OPEN: begin
                next = cd_done == 1 ? UP_CLOSE : UP_OPEN;//计时完成则关门
            end
            UP_CLOSE: begin
                if(open_door == 1)      next = UP_OPEN;  //每一层判断是否开门
                else if(go_up == 1)     next = UP;       //优先向上
                else if(go_down == 1)   next = DOWN;     //否则向下
                else                    next = UP_CLOSE; //再否则保持关门状态
            end
            UP: begin
                next = ce_done == 1 ? UP_CLOSE : UP;     //计时完成则进行判断
            end
            DOWN_OPEN: begin
                next = cd_done == 1 ? DOWN_CLOSE : DOWN_OPEN;
            end
            DOWN_CLOSE: begin
                if(open_door == 1)      next = DOWN_OPEN;
                else if(go_down == 1)   next = DOWN;
                else if(go_up == 1)     next = UP;
                else                    next = DOWN_CLOSE;
            end
            DOWN: begin
                next = ce_done == 1 ? DOWN_CLOSE : DOWN;
            end
            default: next = INIT;
        endcase
    end

    //状态转换的always #3
    always @(*) begin
        case(curr)
            INIT: 
                {running_state, door_state} = 
                {`RS_UP, `DS_CLOSE};
            UP_OPEN:
                {running_state, door_state} = 
                {`RS_UP, `DS_OPEN};
            UP_CLOSE:
                {running_state, door_state} = 
                {`RS_UP, `DS_CLOSE};
            UP:
                {running_state, door_state} = 
                {`RS_UP, `DS_CLOSE};
            DOWN_OPEN:
                {running_state, door_state} = 
                {`RS_DOWN, `DS_OPEN};
            DOWN_CLOSE:
                {running_state, door_state} = 
                {`RS_DOWN, `DS_CLOSE};
            DOWN:
                {running_state, door_state} = 
                {`RS_DOWN, `DS_CLOSE};
            default:
                {running_state, door_state} = 
                {`RS_UP, `DS_CLOSE};
        endcase
    end

endmodule