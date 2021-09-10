`include "./global.vh"
module request(
    input clk380hz,
    input clk10hz,
    input clk1hz,
    input rst,
    //control传过来的状态参数
    input [7:0] curr_floor,
    input [3:0] running_state,
    input [3:0] door_state,
    //输入参数
    input  [`F_N-1:0] floor_in,          //按钮
    input  [`F_N-1:0] up_in,             //开关
    input  [`F_N-1:0] down_in,           //（通过开关代替按钮）
    output [2*`F_N-1:0] demand_state,    //信号显示
    output [2:0] req                     //发给control的请求
);

    //需求寄存器，没完成的需求都在这里
    reg [`F_N-1:0] floor = 0,//内部各层
                      up = 0,//外部上行，最高层不能向上
                    down = 0;//外部下行，最底层不能向下
    //需求显示
    assign demand_state = {up[`F_N-1:0], down[`F_N-1:0]};

    //增加需求
    wire [`F_N-1:0] floor_add, up_add, down_add;

    //通过异或来将真实开关转换为模拟按键输入
    key_input #(`F_N) ki_up    (clk10hz, {1'b0, up_in[`F_N-2:0]}, up_add);
    key_input #(`F_N) ki_down  (clk10hz, {down_in[`F_N-1:1], 1'b0}, down_add);

    always @(posedge clk380hz) begin
         if(rst == 1) {floor, up, down} <= 0;
         else begin
              //开关状态改变时触发更新需求
               begin
                    floor <= floor | floor_in;
                    up    <= up    | up_add;
                    down  <= down  | down_add;
               end
               //需求完成则对应位置复位
               if(door_state == `DS_OPEN) begin
                    floor[curr_floor] <= 0;
                    up   [curr_floor] <= 0;
                    down [curr_floor] <= 0;
               end  
         end
    end
  
    //需求寄存器拓展
    wire [3*`F_N-1:0] w_floor, w_up, w_down;
    wire [7:0] w_curr_floor;
 
    //这里采取一种hacky的方式：将需求寄存器的前后均进行扩展，使得其宽度为原来的三倍
    //然后在判断请求时可以直接片选`F_N宽的信号，通过判断其中是否有1来确定是否有请求
    //采取这样的方式是为了保证扩展性，但不推荐
    assign w_floor = {{`F_N{1'b0}}, floor[`F_N-1:0], {`F_N{1'b0}}},
           w_up    = {{(`F_N+1){1'b0}}, up[`F_N-2:0], {`F_N{1'b0}}},
           w_down  = {{`F_N{1'b0}}, down[`F_N-1:1], {(`F_N+1){1'b0}}};
    assign w_curr_floor = curr_floor + `F_N;
    
    //运行过程中条件判断
    wire up_req,      //向上移动请求
         down_req,    //向下移动请求
         go_up,       //是否真要向上
         go_down,     //向下
         open_door;   //是否开门

    //根据需求寄存器判断各种请求
    //向上请求信号（不一定收到请求就向上，需要根据下面go_up信号判断）
    assign up_req =                curr_floor != `F_N - 1 &&   //不在最顶层（最顶层不可能有向上请求）
                    w_floor[(w_curr_floor + 1) +: `F_N] > 0 || //电梯内部选择当前位置之上的楼层
                       w_up[(w_curr_floor + 1) +: `F_N] > 0 || //电梯外部有当前楼层之上的楼层的向上请求
                     w_down[(w_curr_floor + 1) +: `F_N] > 0;   //电梯外部有当前楼层之上的楼层的向下请求

    //向下请求
    assign down_req =                     curr_floor != 0 &&
                    w_floor[(w_curr_floor - 1) -: `F_N] > 0 ||
                       w_up[(w_curr_floor - 1) -: `F_N] > 0 ||
                     w_down[(w_curr_floor - 1) -: `F_N] > 0;

    //真的向上的信号
    assign go_up = (running_state == `RS_UP && up_req) ||               //正常的向上请求
                   (running_state == `RS_DOWN && !down_req && up_req);  //或没有向下请求时的向上请求

    //真的向下的信号
    assign go_down = (running_state == `RS_DOWN && down_req) ||
                     (running_state == `RS_UP  && !up_req && down_req);

    //开门信号
    assign open_door = floor[curr_floor] == 1 ||                                         //到达指定楼层
                       (                                                                 //或
                            curr_floor != `F_N-1 &&                                      //不在最顶层
                            ((running_state == `RS_UP && up[curr_floor] == 1) ||         //且当前层有向上请求，且电梯运行状态向上
                            (!up_req && (down[curr_floor] == 1 || up[curr_floor] == 1))) //或者没有向上请求了（保持运动状态的优先级高于距离最近），但当前层有请求
                       ) ||
                       (
                            curr_floor != 0 &&
                            ((running_state == `RS_DOWN && down[curr_floor] == 1) ||
                            (!down_req && (down[curr_floor] == 1 || up[curr_floor] == 1)))
                       );

     assign req = rst == 1 ? 0 : {go_up, go_down, open_door};

endmodule
