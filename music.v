module music(beep,clk,rst,clkout);
input clk,clkout,rst;
output reg beep;


reg [10:0]count_end,count;

reg [3:0] seconds;

always @(posedge clk or posedge rst)
if (rst) begin count = 0;beep = 0;end
else begin
	if (seconds < 12) begin
		if (count == count_end) begin
		count <= 0;
		beep = ~beep;
		end
		else count = count + 1;
	end
	else beep = 0;
end



always @(posedge clkout or posedge rst)
if (rst) seconds = 0;
else begin
	case(seconds)
	0,1:count_end = 1517;
	2:count_end = 1275;
	3,4,5:count_end = 851;
	6,7:count_end = 956;
	8:count_end = 1275;
	9,10,11:count_end = 1432;
	default:seconds = 14;
	endcase
	seconds = seconds + 1;
	end

endmodule
