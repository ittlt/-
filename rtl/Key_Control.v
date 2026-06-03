// 按键消抖与频率控制模块（v7 - 三阶段架构）
// 同步 → 下降沿检测 → 消抖计数 → 功能控制
module Key_Control(
    input           clk,
    input           rst_n,
    input [3:0]     key_in,
    output reg [31:0]fcw,
    output reg [1:0]wave_sel,
    output reg      led_key
);

reg [3:0]  key_sync1, key_sync2;  // 两级同步
wire [3:0] key_edge;               // 原始下降沿（同步后的）
reg [19:0] cnt [0:3];              // 每个按键独立消抖计数器
reg [3:0]  key_valid;              // 消抖确认后的有效按键
reg [3:0]  key_valid_prev;         // 用于边沿检测

integer i;

parameter FCW_DEFAULT = 32'd10737418;
parameter FCW_STEP    = 32'd107374;
parameter FCW_MIN     = 32'd10737;

// 第一级：两级同步（消除亚稳态）
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        key_sync1 <= 4'b1111;
        key_sync2 <= 4'b1111;
    end else begin
        key_sync1 <= key_in;
        key_sync2 <= key_sync1;
    end
end

// 第二级：下降沿检测（key_sync2 由1变0 → 单周期脉冲）
assign key_edge = (~key_sync1) & key_sync2;

// 第三级：消抖（沿触发计数，稳定10ms后确认）
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        for(i=0; i<4; i=i+1) cnt[i] <= 20'd0;
        key_valid      <= 4'b1111;
        key_valid_prev <= 4'b1111;
    end else begin
        key_valid_prev <= key_valid;
        for(i=0; i<4; i=i+1) begin
            if(key_edge[i]) begin
                // 检测到下降沿，启动消抖计数
                cnt[i] <= 20'd1;
            end else if(cnt[i] != 20'd0) begin
                if(key_sync2[i] == 1'b1) begin
                    // 按键弹起（抖动），取消计数
                    cnt[i] <= 20'd0;
                end else if(cnt[i] < 20'd1_000_000) begin
                    // 按键保持低电平，继续计数
                    cnt[i] <= cnt[i] + 20'd1;
                end else begin
                    // 消抖确认
                    cnt[i] <= 20'd0;
                    key_valid[i] <= 1'b0;
                end
            end
        end
    end
end

// 第四级：下降沿脉冲（key_valid 由1变0 → 单周期脉冲）
wire [3:0] key_press = key_valid_prev & (~key_valid);

// 功能控制
reg [31:0] fcw_reg;
reg [1:0]  wave_sel_reg;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        fcw_reg      <= FCW_DEFAULT;
        wave_sel_reg <= 2'b00;
        led_key      <= 1'b0;
    end else begin
        led_key <= 1'b0;
        case(key_press)
            4'b0001: begin fcw_reg <= fcw_reg + FCW_STEP; led_key <= 1'b1; end
            4'b0010: begin
                if(fcw_reg >= FCW_MIN + FCW_STEP) fcw_reg <= fcw_reg - FCW_STEP;
                led_key <= 1'b1;
            end
            4'b0100: begin
                wave_sel_reg <= (wave_sel_reg == 2'b10) ? 2'b00 : wave_sel_reg + 2'd1;
                led_key <= 1'b1;
            end
            4'b1000: led_key <= 1'b1;
            default: begin fcw_reg <= fcw_reg; wave_sel_reg <= wave_sel_reg; end
        endcase
    end
end

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin fcw <= FCW_DEFAULT; wave_sel <= 2'b00; end
    else begin fcw <= fcw_reg; wave_sel <= wave_sel_reg; end
end

endmodule
