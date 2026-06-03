// UART接收与指令解析模块
// 功能：实现UART异步接收（9600bps），解析PC端频率控制指令
// 修复：用计数器替代 #10 延迟，确保可综合
module UART_Parse(
    input           clk,         // 系统时钟（100MHz）
    input           rst_n,       // 复位信号（低电平有效）
    input           uart_rx,     // UART接收引脚
    output reg [31:0]fcw_uart,   // 解析后的频率控制字
    output reg      fcw_update,  // 频率控制字更新标志
    output reg      led_uart     // 串口通信状态指示LED
);

// 内部信号定义
reg [15:0] cnt_baud;       // 波特率计数器
reg [3:0]  cnt_bit;        // 位计数器
reg [7:0]  uart_data;      // 接收数据字节
reg [7:0]  cmd_buf [0:5];  // 指令缓存
reg [2:0]  cmd_cnt;        // 指令字节计数器
reg        uart_rx_sync1;  // 同步寄存器1
reg        uart_rx_sync2;  // 同步寄存器2
reg        uart_rx_sync3;  // 同步寄存器3
wire       uart_rx_neg;    // 下降沿检测
reg        recv_flag;      // 单字节接收完成标志

// fcw_update 脉冲宽度控制（替代 #10 延迟）
reg [3:0]  update_cnt;     // 更新脉冲计数器
reg        update_active;  // 更新脉冲活跃标志

// 参数定义
parameter BAUD_CNT  = 16'd10416;   // 9600bps
parameter BAUD_HALF = 16'd5208;    // 半周期
parameter FCW_DEFAULT = 32'd10737418;
parameter UPDATE_PULSE = 4'd10;     // fcw_update 保持10个时钟周期

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

// 2. 波特率时钟生成与位计数
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cnt_baud  <= 16'd0;
        cnt_bit   <= 4'd0;
        recv_flag <= 1'b0;
        led_uart  <= 1'b0;
    end else if(uart_rx_neg) begin
        cnt_baud  <= BAUD_HALF;
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

// 3. UART数据接收（位中间采样）
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        uart_data <= 8'd0;
    end else if(cnt_bit != 4'd0 && cnt_baud == BAUD_HALF) begin
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
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cmd_cnt     <= 3'd0;
        fcw_uart    <= FCW_DEFAULT;
        update_active <= 1'b0;
        update_cnt  <= 4'd0;
    end else begin
        // fcw_update 脉冲宽度控制
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
                if(uart_data == 8'h46) begin
                    cmd_cnt <= 3'd1;
                end else begin
                    cmd_cnt <= 3'd0;
                end
            end else if(cmd_cnt <= 3'd6) begin
                cmd_buf[cmd_cnt-1] <= uart_data;
                cmd_cnt <= cmd_cnt + 3'd1;
                if(cmd_cnt == 3'd6) begin
                    cmd_cnt <= 3'd0;
                    // ASCII转十进制频率值，计算FCW
                    // FCW = freq * 2^32 / 100MHz
                    fcw_uart <= ((cmd_buf[0]-8'h30)*100000 +
                                 (cmd_buf[1]-8'h30)*10000  +
                                 (cmd_buf[2]-8'h30)*1000   +
                                 (cmd_buf[3]-8'h30)*100    +
                                 (cmd_buf[4]-8'h30)*10     +
                                 (uart_data  -8'h30))      * 32'd43; // ≈ 2^32/100MHz ≈ 42.95
                    update_active <= 1'b1;
                    update_cnt    <= 4'd0;
                end
            end
        end
    end
end

// 5. fcw_update 输出：由 update_active 驱动
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        fcw_update <= 1'b0;
    else
        fcw_update <= update_active;
end

endmodule
