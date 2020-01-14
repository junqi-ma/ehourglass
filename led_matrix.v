module led_matrix (clk_out,clk,cnt,r_col,g_col,row,rst,sw1,stop);
input clk,clk_out,rst,sw1,stop;
//clk为1kzh，clkout为自己选择的信号，sw1为重力信号，stop为停止信号

output reg[7:0]r_col,g_col,row;
//输出行列信号

input [4:0]cnt; 
//输入的奇偶控制信号，奇为左边掉沙子，偶为右边掉沙子

reg [2:0] row_cnt;
//行扫描计数

reg [9:0] row_l;
reg [9:0] row_r;
//左右移位寄存器，用来拼接获得列输出


//初始化，移位寄存器全部置满
initial 
	begin
	row_cnt=3'b000;
	row_l = 10'b11_1111_1111;
	row_r = 10'b11_1111_1111;
	end



//根据cnt的奇偶（cnt[0]为1或0）来选择左右移位
always @(posedge clk_out or posedge rst) 
 if (rst) begin
   row_l = 10'b11_1111_1111;
	row_r = 10'b11_1111_1111;
	end
 else begin
 if(stop==0)begin  //stop为高电平不移位
	 if (!cnt[0]) begin
	  if(sw1==1) row_l = row_l<<1'b1;  //sw1为1左移
	  else if(sw1==0) begin  
			row_l = row_l>>1'b1;         //sw1为0右移并补1
			row_l[9] = 1'b1;
		 end
	 end
	 else if (cnt[0]) begin
	  if(sw1==1) row_r = row_r>>1'b1;  //sw1为1右移
	  else if(sw1==0) begin				  
			row_r = row_r<<1'b1;			  //sw1为0右移并补1
			row_r[0]= 1'b1;
		 end
	 end
	end
 end


always @(posedge clk) //行扫描输出，位信号为移位寄存器拼接
begin
 row_cnt =row_cnt + 1;
 begin
  case(row_cnt)
	3'b000: begin 
			row=8'b1111_1110; 
			r_col = {row_l[3:0],row_r[9:6]}; //左寄存器最低4位（右边）和右寄存器最高4位（左边）
			g_col = {~row_l[3:0],~row_r[9:6]};//红色反过来
			  end
	3'b001: begin 
			row=8'b1111_1101; 
			r_col = {1'b0,row_l[6:4],row_r[5:3],1'b0};//左寄存器次低3位，右寄存器次高3位
			g_col = {1'b0,~row_l[6:4],~row_r[5:3],1'b0};
			  end
  	3'b010: begin 
			row=8'b1111_1011; 
			r_col = {2'b00,row_l[8:7],row_r[2:1],2'b00};//左寄存器次高2位，右寄存器次低2位
			g_col = {2'b00,~row_l[8:7],~row_r[2:1],2'b00};
			  end
	3'b011: begin 
			row=8'b1111_0111; 
			r_col = {3'b000,row_l[9],row_r[0],3'b000};//左寄存器最高1位，右寄存器最低1位
			g_col = {3'b000,~row_l[9],~row_r[0],3'b000};
			  end
	3'b100: begin 
			row=8'b1110_1111; 
			r_col = {3'b000,~row_l[9],~row_r[0],3'b000};//下面就是把上面的都颠倒过来即可
			g_col = {3'b000,row_l[9],row_r[0],3'b000};
			  end
	3'b101: begin 
			row=8'b1101_1111; 
			r_col = {2'b00,~row_l[8:7],~row_r[2:1],2'b00}; 
			g_col = {2'b00,row_l[8:7],row_r[2:1],2'b00};
			  end
	3'b110: begin 
			row=8'b1011_1111; 
			r_col = {1'b0,~row_l[6:4],~row_r[5:3],1'b0}; 
			g_col = {1'b0,row_l[6:4],row_r[5:3],1'b0};
			  end
	3'b111: begin 
			row=8'b0111_1111; 
			r_col = {~row_l[3:0],~row_r[9:6]}; 
			g_col = {row_l[3:0],row_r[9:6]};
			  end
	default:  ;
	endcase
 end
end


endmodule
