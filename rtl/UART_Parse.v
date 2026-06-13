// UART接收与指令解析模块（带回传）
// 功能：接收"Fxxxxxx"指令，解析频率，回传'K'确认
module UART_Parse(
    input           clk,
    input           rst_n,
    input           uart_rx,
    output reg [31:0]fcw_uart,
    output reg      fcw_update,
    output reg      led_uart,
    output          uart_tx
);

// ========== 接收部分 ==========
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
parameter BAUD_CNT  = 16'd10416;
parameter BAUD_HALF = 16'd5208;
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
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cnt_baud  <= 16'd0;
        cnt_bit   <= 4'd0;
        recv_flag <= 1'b0;
        led_uart  <= 1'b0;
    end else if(uart_rx_neg && cnt_bit == 4'd0) begin
        cnt_baud  <= BAUD_HALF - 1;
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

// 3. UART数据接收
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

// 4. 指令解析
reg [31:0] fcw_uart_next;
reg        fcw_valid;
reg        tx_start;        // 发送启动脉冲

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        cmd_cnt       <= 3'd0;
        fcw_uart_next <= FCW_DEFAULT;
        fcw_valid     <= 1'b0;
        update_active <= 1'b0;
        update_cnt    <= 4'd0;
        tx_start      <= 1'b0;
    end else begin
        fcw_valid <= 1'b0;
        tx_start  <= 1'b0;

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
                    fcw_uart_next <= (cmd_buf[0]-8'h30) * 32'd4294967 +
                                     (cmd_buf[1]-8'h30) * 32'd429497  +
                                     (cmd_buf[2]-8'h30) * 32'd42950   +
                                     (cmd_buf[3]-8'h30) * 32'd4295    +
                                     (uart_data  -8'h30) * 32'd472;
                    fcw_valid     <= 1'b1;
                    update_active <= 1'b1;
                    update_cnt    <= 4'd0;
                    tx_start      <= 1'b1;   // 启动回传
                end else begin
                    cmd_cnt <= cmd_cnt + 3'd1;
                end
            end
        end
    end
end

// fcw_uart输出
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

// ========== 发送部分（回传'K'确认） ==========
reg [3:0]  tx_bit_cnt;
reg [15:0] tx_baud_cnt;
reg [7:0]  tx_data;
reg        tx_busy;
reg        tx_pin;

assign uart_tx = tx_pin;

// 发送状态机
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        tx_bit_cnt <= 4'd0;
        tx_baud_cnt <= 16'd0;
        tx_data    <= 8'd0;
        tx_busy    <= 1'b0;
        tx_pin     <= 1'b1;     // 空闲高
    end else if(tx_start && !tx_busy) begin
        // 启动发送：加载数据，发送起始位
        tx_data    <= 8'h4B;    // 'K' = 0x4B
        tx_bit_cnt <= 4'd0;
        tx_baud_cnt <= 16'd0;
        tx_busy    <= 1'b1;
        tx_pin     <= 1'b0;     // 起始位
    end else if(tx_busy) begin
        tx_baud_cnt <= tx_baud_cnt + 16'd1;
        if(tx_baud_cnt == BAUD_CNT - 1) begin
            tx_baud_cnt <= 16'd0;
            tx_bit_cnt  <= tx_bit_cnt + 4'd1;
            case(tx_bit_cnt)
                4'd0: tx_pin <= tx_data[0];  // D0
                4'd1: tx_pin <= tx_data[1];  // D1
                4'd2: tx_pin <= tx_data[2];  // D2
                4'd3: tx_pin <= tx_data[3];  // D3
                4'd4: tx_pin <= tx_data[4];  // D4
                4'd5: tx_pin <= tx_data[5];  // D5
                4'd6: tx_pin <= tx_data[6];  // D6
                4'd7: tx_pin <= tx_data[7];  // D7
                4'd8: begin tx_pin <= 1'b1; tx_busy <= 1'b0; end  // 停止位，发送完成
                default: ;
            endcase
        end
    end
end

endmodule
