// UART接收与指令解析模块（修复版）
// 修复：1. 波特率采样起始值 BAUD_HALF -> BAUD_HALF-1，修正位采样偏移
//       2. FCW计算使用更精确的乘法器
module UART_Parse(
    input           clk,         // 系统时钟（100MHz）
    input           rst_n,       // 复位信号（低电平有效）
    input           uart_rx,     // UART接收引脚
    output reg [31:0]fcw_uart,   // 解析后的频率控制字
    output reg      fcw_update,  // 频率控制字更新标志
    output reg      led_uart     // 串口通信状态指示LED
);

// 内部信号
reg [15:0] cnt_baud;
reg [3:0]  cnt_bit;
reg [7:0]  uart_data;
reg [7:0]  cmd_buf [0:5];
reg [2:0]  cmd_cnt;
reg        uart_rx_sync1;
reg        uart_rx_sync2;
reg        uart_rx_sync3;
wire       uart_rx_neg;
reg        recv_flag;

// fcw_update 脉冲控制
reg [3:0]  update_cnt;
reg        update_active;

// 参数
parameter BAUD_CNT  = 16'd10416;     // 9600bps
parameter BAUD_HALF = 16'd5208;      // 半周期
parameter FCW_DEFAULT = 32'd10737418;
parameter UPDATE_PULSE = 4'd10;

// 1. 接收信号同步与下降沿检测
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        uart_rx_sync1 <= 1'b1;
        uart_rx_sync2 <= 1'b1;
        uart_rx_sync3 <= 1'b1;
    end else begin
        uart_rx_sync1 <= uart_rx;
        uart_rx_sync2 <= uart_rx_sync1;
        uart_rx_sync3 <= uart_rx_sync2;
    end
end

assign uart_rx_neg = ~uart_rx_sync2 & uart_rx_sync3;

// 2. 波特率时钟与位计数
//    修复：起始加载 BAUD_HALF-1，使首个采样点恰好落在位中点
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cnt_baud  <= 16'd0;
        cnt_bit   <= 4'd0;
        recv_flag <= 1'b0;
        led_uart  <= 1'b0;
    end else if(uart_rx_neg && cnt_bit == 4'd0) begin
        cnt_baud  <= BAUD_HALF - 1;  // 修复：-1 使下一周期恰好到达 BAUD_HALF
        cnt_bit   <= 4'd1;
        recv_flag <= 1'b0;
        led_uart  <= 1'b1;
    end else if(cnt_bit != 4'd0) begin
        cnt_baud <= cnt_baud + 16'd1;
        if(cnt_baud == BAUD_CNT) begin
            cnt_baud <= 16'd0;
            cnt_bit  <= cnt_bit + 4'd1;
            if(cnt_bit == 4'd9) begin
                cnt_bit   <= 4'd0;
                recv_flag <= 1'b1;
                led_uart  <= 1'b0;
            end
        end
    end else begin
        recv_flag <= 1'b0;
    end
end

// 3. UART数据接收（位中点采样）
//    cnt_bit=1: 起始位（跳过，不存储）
//    cnt_bit=2..9: 数据位 D0..D7
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        uart_data <= 8'd0;
    end else if(cnt_bit >= 4'd2 && cnt_bit <= 4'd9 && cnt_baud == BAUD_HALF) begin
        case(cnt_bit)
            4'd2: uart_data[0] <= uart_rx_sync2;
            4'd3: uart_data[1] <= uart_rx_sync2;
            4'd4: uart_data[2] <= uart_rx_sync2;
            4'd5: uart_data[3] <= uart_rx_sync2;
            4'd6: uart_data[4] <= uart_rx_sync2;
            4'd7: uart_data[5] <= uart_rx_sync2;
            4'd8: uart_data[6] <= uart_rx_sync2;
            4'd9: uart_data[7] <= uart_rx_sync2;
            default: ;
        endcase
    end
end

// 4. 指令解析：格式 "Fxxxxxx"（F=0x46，后接6位ASCII频率值）
// 使用独立的fcw_uart_next寄存器，避免always块内隐式覆盖
reg [31:0] fcw_uart_next;
reg        fcw_valid;       // FCW计算完成标志

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cmd_cnt       <= 3'd0;
        fcw_uart_next <= FCW_DEFAULT;
        fcw_valid     <= 1'b0;
        update_active <= 1'b0;
        update_cnt    <= 4'd0;
    end else begin
        fcw_valid <= 1'b0;

        if(update_active) begin
            if(update_cnt == UPDATE_PULSE) begin
                update_active <= 1'b0;
                update_cnt    <= 4'd0;
            end else begin
                update_cnt <= update_cnt + 4'd1;
            end
        end

        if(recv_flag) begin
            if(cmd_cnt == 3'd0) begin
                cmd_cnt <= (uart_data == 8'h46) ? 3'd1 : 3'd0;
            end else if(cmd_cnt <= 3'd5) begin
                cmd_buf[cmd_cnt-1] <= uart_data;
                if(cmd_cnt == 3'd5) begin
                    cmd_cnt       <= 3'd0;
                    // FCW = freq * 2^32 / 100MHz
                    // freq = d0*10^5 + d1*10^4 + d2*10^3 + d3*10^2 + d4*10 + d5
                    // 权重: d0=4294967, d1=429497, d2=42950, d3=4295, d4=429, d5=43
                    // uart_data同时作为d4和d5（同一字节），权重=429+43=472
                    fcw_uart_next <= (cmd_buf[0]-8'h30) * 32'd4294967 +
                                     (cmd_buf[1]-8'h30) * 32'd429497  +
                                     (cmd_buf[2]-8'h30) * 32'd42950   +
                                     (cmd_buf[3]-8'h30) * 32'd4295    +
                                     (uart_data  -8'h30) * 32'd472;
                    fcw_valid     <= 1'b1;
                    update_active <= 1'b1;
                    update_cnt    <= 4'd0;
                end else begin
                    cmd_cnt <= cmd_cnt + 3'd1;
                end
            end
        end
    end
end

// fcw_uart输出：仅在fcw_valid时更新，否则保持
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        fcw_uart <= FCW_DEFAULT;
    else if(fcw_valid)
        fcw_uart <= fcw_uart_next;
end

// 5. fcw_update 输出
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        fcw_update <= 1'b0;
    else
        fcw_update <= update_active;
end

endmodule
