module clkDiv (
    input clk100mhz,
    output clk380hz,
    output clk10hz,
    output reg clk1hz = 0
);
    reg [25:0] count = 0;
    reg [27:0] count_1hz = 0;

    assign clk380hz = count[17];
    assign clk10hz  = count[23];
    
    always@(posedge clk100mhz) begin
        count <= count + 1;

        if(count_1hz == 50_000_000) begin
            clk1hz <= ~clk1hz;
            count_1hz <= 0;
        end
        else count_1hz <= count_1hz + 1;
    end 
endmodule