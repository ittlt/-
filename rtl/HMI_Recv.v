//////////////////////Function//////////////////
//串口屏接收数据解�??
///////////////Time�??2019.7.21////////////

module HMI_Recv(
input wire clk,
input wire HMI_RX,
input wire rst_n,
output reg [31:0] HMI_Num,	//合并后的数�?�输�??(0~999999)
output reg HMI_Done		//接收完成脉冲
);

wire [7:0]Data_RX;
wire Wrsig;

reg [7:0] i;
reg wrsigbuf;
reg wrsigrise;
reg [7:0] dig [0:5];	//临时存储6个ASCII数字

HMI_UARX U1
(
	.sys_clk (clk),
	.sys_rst_n (rst_n),
	.uart_rxd (HMI_RX),
	.uart_done (Wrsig),
	.uart_data (Data_RX)
);

always @(posedge clk)
begin
   wrsigbuf <= Wrsig;
   wrsigrise <= (~wrsigbuf) & Wrsig;
end

always@(posedge clk)begin
if(wrsigrise)begin
case(i)

0:if(Data_RX==8'h46) i<=1;//起始�?? 'F'
1:begin dig[0]<=Data_RX; i<=2; end	//�??1位数�??
2:begin dig[1]<=Data_RX; i<=3; end	//�??2位数�??
3:begin dig[2]<=Data_RX; i<=4; end	//�??3位数�??
4:begin dig[3]<=Data_RX; i<=5; end	//�??4位数�??
5:begin dig[4]<=Data_RX; i<=6; end	//�??5位数�??
6:begin dig[5]<=Data_RX; i<=7; end	//�??6位数�??
7:i<=8;  //等待dig[5]稳定
8:if(Data_RX==8'h0D || Data_RX==8'h0A) begin  //回车或换行都可以结束
	i<=9;
	HMI_Num <= (dig[0]-8'h30)*32'd4294967 + (dig[1]-8'h30)*32'd429497 +
	           (dig[2]-8'h30)*32'd42950    + (dig[3]-8'h30)*32'd4295 +
	           (dig[4]-8'h30)*32'd429       + (dig[5]-8'h30) * 32'd42;
	HMI_Done<=1'b1;
	end
9:begin
	HMI_Done<=1'b1;
	i<=10;
	end
10:begin//结束??
	i<=0;
	HMI_Done<=1'b0;
	end
default:i<=i+1;

endcase
end
end


endmodule
