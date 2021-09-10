//状态码显示
`include "./global.vh"
module signal_segMsg (
    input clk380hz,
    input [15:0] dataBus,
    output reg [3:0] pos,
    output reg [7:0] seg 
);
    reg [2:0] posC;
    reg [3:0] dataP;
    always @(posedge clk380hz) begin
        case (posC)
            0: begin
                pos <= 4'b0001;
                dataP <= dataBus[3:0];
            end
            1: begin
                pos <= 4'b0010;
                dataP <= dataBus[7:4];
            end
            2: begin
                pos <= 4'b0100;
                dataP <= dataBus[11:8];
            end
            3: begin
                pos <= 4'b1000;
                dataP <= dataBus[15:12];
            end
        endcase
        posC = posC + 1;
    end

    always @(dataP) begin
        case (dataP)
            `RS_UP:    seg = 8'b0110_0011;
            `RS_DOWN:  seg = 8'b0101_1100;
            `RS_STOP:  seg = 8'b0100_0000;
            `DS_OPEN:  seg = 8'b0011_0110;
            `DS_CLOSE: seg = 8'b0111_1111;
            `INVALID:  seg = 8'b0100_0000;
            default:   seg = 8'b0100_0000;
        endcase
    end
endmodule