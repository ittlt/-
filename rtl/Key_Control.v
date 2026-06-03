// 按键消抖与频率控制模块
// 功能：实现4个按键的消抖处理，生成频率控制字与波形选择信号
module Key_Control(
    input           clk,         // 系统时钟（100MHz）
    input           rst_n,       // 复位信号（低电平有效）
    input [3:0]     key_in,      // 按键输入（Freq+、Freq-、Wave_Sel、Confirm）
    output reg [31:0]fcw,        // 输出频率控制字
    output reg [1:0]wave_sel,    // 输出波形选择信号
    output reg      led_key      // 按键有效指示LED
);

// 内部信号定义
reg [19:0] cnt_debounce;   // 消抖计数器（20ms @ 100MHz）
reg [3:0]  key_sync;       // 按键同步信号
reg [3:0]  key_delay1;     // 按键延迟信号1
reg [3:0]  key_delay2;     // 按键延迟信号2
wire [3:0] key_edge;       // 按键下降沿检测
reg [1:0]  wave_sel_reg;   // 波形选择寄存器
reg [31:0] fcw_reg;        // 频率控制字寄存器

// 参数定义
parameter FCW_DEFAULT = 32'd10737418;  // 默认100kHz
parameter FCW_STEP    = 32'd107374;   // 步进1kHz
parameter FCW_MIN     = 32'd10737;    // 最低100Hz

// 1. 按键同步与消抖处理
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        key_sync     <= 4'b1111;
        key_delay1   <= 4'b1111;
        key_delay2   <= 4'b1111;
        cnt_debounce <= 20'd0;
    end else begin
        key_sync   <= key_in;
        key_delay1 <= key_sync;
        key_delay2 <= key_delay1;
        if(key_delay1 != key_delay2) begin
            cnt_debounce <= 20'd0;
        end else begin
            cnt_debounce <= cnt_debounce + 20'd1;
        end
    end
end

// 2. 按键下降沿检测
assign key_edge = key_delay2 & (~key_delay1) & (cnt_debounce == 20'd1_000_000);

// 3. 频率控制字与波形选择逻辑
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        fcw_reg     <= FCW_DEFAULT;
        wave_sel_reg <= 2'b00;
        led_key     <= 1'b0;
    end else begin
        led_key <= 1'b0;
        case(key_edge)
            4'b0001: begin  // Freq+
                fcw_reg <= fcw_reg + FCW_STEP;
                led_key <= 1'b1;
            end
            4'b0010: begin  // Freq-
                if(fcw_reg >= FCW_MIN + FCW_STEP) begin
                    fcw_reg <= fcw_reg - FCW_STEP;
                end
                led_key <= 1'b1;
            end
            4'b0100: begin  // Wave_Sel
                if(wave_sel_reg == 2'b10)
                    wave_sel_reg <= 2'b00;
                else
                    wave_sel_reg <= wave_sel_reg + 2'd1;
                led_key <= 1'b1;
            end
            4'b1000: begin  // Confirm
                led_key <= 1'b1;
            end
            default: begin
                fcw_reg      <= fcw_reg;
                wave_sel_reg <= wave_sel_reg;
            end
        endcase
    end
end

// 4. 输出赋值
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        fcw     <= FCW_DEFAULT;
        wave_sel <= 2'b00;
    end else begin
        fcw     <= fcw_reg;
        wave_sel <= wave_sel_reg;
    end
end

endmodule
