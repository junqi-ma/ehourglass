module seg_led (num,seg_led,seg_leds,clk);

input [5:0] num;//输入要显示的数字(0-60s)
input clk;//1k时钟输入
output reg [8:0] seg_led;//段选
output reg [1:0] seg_leds;//数码管选择
reg [7:0] seg [9:0];//储存数字图案

initial
begin
	seg[0] = 8'b11111100;  //设置段选数字                                        
	seg[1] = 8'b01100000;                                        
	seg[2] = 8'b11011010;                                          
	seg[3] = 8'b11110010;                                           
	seg[4] = 8'b01100110;                                           
	seg[5] = 8'b10110110;                                          
	seg[6] = 8'b10111110;                                          
	seg[7] = 8'b11100100;                                          
	seg[8] = 8'b11111110;                                          
	seg[9] = 8'b11110110; 
	seg_leds = 2'b01;
	seg_led = 8'b11111100;
end

always @ (posedge clk)//数码管段第二位显示十位，第一位显示个位
begin
seg_leds = ~seg_leds;

if(seg_leds == 2'b10) seg_led = seg[num / 10];//第2位时显示十位

else if (seg_leds == 2'b01) seg_led = seg[num - 10*(num/10)];//第一位时显示个位

end

endmodule
