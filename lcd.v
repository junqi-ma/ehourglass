module lcd(clk_LCD,rst,en,RS,RW,data,stop,speed);
input      clk_LCD;  // 1000Hz
input       rst,stop;//
input [1:0] speed;   //下落速度
output    en,RS,RW;  //输出
output   reg [7:0]  data;
reg               RS,en_sel;

reg     [2:0]   disp_count;//显示计数

reg     [2:0]   state;//共有6个状态
parameter   clear_lcd  = 3'b0000, //清屏并光标复位
		  set_disp_mode  = 3'b0001, //设置显示模式：8位2行5x7点阵   
	  disp_on           = 3'b0010,//显示器开、光标不显示、光标不允许闪烁
			shift_down    = 3'b0011, //文字不动，光标自动右移 
	  write_data_first  = 3'b0101,//写入第一行显示的数据
				  idle     = 3'b0111;//空闲状态   


assign  RW = 1'b0;                    //RW=0时对LCD模块执行写操作
assign  en = en_sel ? clk_LCD : 1'b0;
   

reg [7:0]    data_first_line     [13:0];  //first line show data

reg [1:0] speed_pre,speed_now;//当speed改变时产生一个脉冲信号
always @(posedge clk_LCD)
begin
	speed_now <= speed;
	speed_pre <= speed_now;
end

assign pulse = (speed_now==speed_pre)? 0:1;


always @(posedge clk_LCD )
begin
if(stop)begin	 //开机界面时显示Welcome
   data_first_line[0] <= 8'h57;
   data_first_line[1] <= 8'h65;
   data_first_line[2] <= 8'h7c;
   data_first_line[3] <= 8'h63;
   data_first_line[4] <= 8'h6f;
   data_first_line[5] <= 8'h6d;
   data_first_line[6] <= 8'h65;
   end
else if(!stop)begin	//下漏时显示速度
   data_first_line[0] = 8'h53;
   data_first_line[1] = 8'h50;
   data_first_line[2] = 8'h45;
   data_first_line[3] = 8'h45;
   data_first_line[4] = 8'h44;
   data_first_line[5] = 8'h3a;  
	case(speed)				//根据当前速度选择最后一个数字
	0:data_first_line[6] = 8'h31;
	1:data_first_line[6] = 8'h32;
	2:data_first_line[6] = 8'h33;
	3:data_first_line[6] = 8'h34;
	default:;
	endcase
   end
end

always @(posedge clk_LCD or posedge rst)
begin
   if(rst)
     begin
         state         <= clear_lcd;   //复位：清屏并光标复位  
         RS            <= 1'b0;        //复位：RS=0时为写指令；                      
         data        <= 8'b0;         //复位：使DB8总线输出全0
         en_sel       <= 1'b1;       //复位：开启夜晶使能信号
         disp_count <= 5'b0;
     end
   else
     case(state)
     clear_lcd:                              //初始化LCD模块
            begin         //清屏并光标复位
               state  <= set_disp_mode;
               data  <= 8'h01;               
            end
     set_disp_mode:       //设置显示模式：8位2行5x8点阵 
            begin
               state  <= disp_on;
               data  <= 8'h38;                              
            end
     disp_on:           //显示器开、光标不显示、光标不允许闪烁
            begin
               state  <= shift_down;
               data  <= 8'h0c;                           
            end
     shift_down:       //文字不动，光标自动右移 
           begin
               state  <= write_data_first;
               data  <= 8'h06;                         
           end
     write_data_first:             //显示第一行                         
           begin
               if(disp_count == 7)                      
                   begin
                       data    <= 8'hc2;               
                       RS     <= 1'b0;
                       disp_count   <= 4'b0;
                       state    <= idle;        
                   end
               else
                   begin
                       data    <= data_first_line[disp_count];
                       RS     <= 1'b1;                  
                       disp_count   <= disp_count + 1'b1;
                       state    <= write_data_first;
                   end
           end

     idle:           //写完进入空闲状态
           begin
               if(pulse)state <= clear_lcd; //如果sw改变则刷新一次
					else state <= idle;
           end
     default:  state <= clear_lcd;//若state为其他值，则将state置为Clear_Lcd
     endcase
end
endmodule