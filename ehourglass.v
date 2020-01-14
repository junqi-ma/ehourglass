module ehourglass(sw1,btn0,rst,clk,speed,beep,r_col,g_col,row,seg_led,seg_led_d,
				lcd_rs,lcd_rw,lcd_e,d);

input sw1,btn0,rst,clk;//sw1为重力信号，btn0为暂停信号
input [1:0]speed;//速度选择信号

output  lcd_rs,lcd_rw,lcd_e;//lcd的管脚
output  [7:0] d;

output beep;

output [7:0]r_col,g_col,row;//点阵显示输出

output [8:0]seg_led;//数码管段输出
output [7:0]seg_led_d;
wire [1:0]seg_leds;
assign seg_led_d={6'b111111,seg_leds};

wire clk_1hz,clkout,clk_1khz;//1hz和选中的时钟信号

wire [5:0] cnt_matrix,cnt_clock;
wire btn0_pulse;
reg stop;

always @(posedge clk or posedge rst)//控制系统的停止与开启
begin
if (rst) stop = 0;
else if (btn0_pulse) stop = ~stop;
end


divide  d1(
			.clk(clk),
			.rst(rst),
			.clkout_1hz(clk_1hz),
			.clkout(clkout),
			.sw(speed),
			.clkout_1khz(clk_1khz)
			);//分频的到1hz和另外一个被选中的时钟信号（控制速度用）
				 
counter ct(
			.clk(clk_1hz),
			.cnt(cnt_clock),
			.rst(rst),
			.stop(stop)
			);//按秒计时的计时器，用来显示时间
			
counter #(.N(0))cm(
			.clk(clkout),
			.cnt(cnt_matrix),
			.rst(rst),
			.stop(stop)
			);//一个1位计时器，相当于二分频，提供给点阵模块
			
seg_led s1(
			.num(cnt_clock),
			.seg_led(seg_led),
			.seg_leds(seg_leds),
			.clk(clk)
			);//数码管段输出，显示60s时间变化

debounce de1(
			  .clk(clk),
			  .rst(rst),
			  .key(btn0),
			  .key_pulse(btn0_pulse)
				);//消抖模块，给停止信号消抖

led_matrix l1(
			  .clk(clk),
			  .cnt(cnt_matrix),
			  .r_col(r_col),
			  .g_col(g_col),
			  .row(row),
			  .clk_out(clkout),
			  .sw1(sw1),
			  .stop(stop),
			  .rst(rst)
			    );//LED点阵输出

lcd 	lcd1(
			  .clk_LCD(clk_1khz),
			  .speed(speed),
			  .rst(rst),
			  .stop(stop),
			  .data(d),
			  .RS(lcd_rs),
			  .RW(lcd_rw),
			  .en(lcd_e)
				);	//LCD显示		 
				
music m1(
			.clk(clk),
			.clkout(clkout),
			.rst(rst),
			.beep(beep)
			);//音乐播放
				
endmodule
