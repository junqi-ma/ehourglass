module counter (clk,cnt,rst,stop);

input clk,rst,stop;//stop为停止信号

parameter N = 5;//可选位数，最多不超过6位（模值最大为60）
output reg [N:0] cnt;

always @ (posedge clk or posedge rst)

	if (rst) begin
		cnt <= 0;
	end
	
	else begin 
	if (stop ==0) begin //停止时不计时
			if (cnt == 60) cnt <= 0; 
			else cnt <= cnt + 1;
		end
		else
			cnt <= cnt;
	end
	
endmodule
