module divide(clk,rst,clkout_1hz,clkout,sw,clkout_1khz);
input clk,rst;//clk输入1mhz
input [1:0] sw;//选择的速度
output clkout,clkout_1hz,clkout_1khz;//输出两个时钟信号
reg clkout_half_hz,clkout_1hz,clkout_2hz,clkout_4hz,clkout,clkout_1khz;//一共四种时钟信号

reg [6:0] cnt1;
reg [8:0] cnt;

initial 
begin
clkout_half_hz = 0;
clkout_1hz = 0;
clkout_2hz = 0;
clkout_4hz = 0;
clkout_1khz = 0;
end

always @(sw or clkout_half_hz or clkout_1hz or clkout_2hz or clkout_4hz)//MUX选择时钟信号输出
begin
	case(sw)
	 2'b00:clkout = clkout_half_hz;
	 2'b01:clkout = clkout_1hz;
	 2'b10:clkout = clkout_2hz;
	 2'b11:clkout = clkout_4hz;
	default:;
	endcase
end


always @(posedge clk or posedge rst)//1000分频得到1khz
begin
	if(rst) cnt = 0;
	else begin
	if(cnt == 500) begin clkout_1khz = ~clkout_1khz;cnt = 0;end
	else cnt = cnt + 1;
	end
end
	
always @(posedge clkout_1khz or posedge rst)//250分频得到4hz
begin
	if(rst) cnt1 = 0;
	else begin
	if(cnt1 == 125) begin clkout_4hz = ~clkout_4hz;cnt1 = 0;end
	else cnt1 = cnt1 + 1;
	end
end
	
always @(posedge clkout_4hz or posedge rst)//2分频得到2hz
begin
	if(rst) clkout_2hz = 0;
	else clkout_2hz = ~clkout_2hz;
end
	
always @(posedge clkout_2hz or posedge rst)//2分频得到1hz
begin
	if(rst) clkout_1hz = 0;
	else clkout_1hz = ~clkout_1hz;
end

always @(posedge clkout_1hz or posedge rst)//2分频得到0.5hz
begin
	if(rst) clkout_half_hz = 0;
	else clkout_half_hz = ~clkout_half_hz;

end


endmodule
