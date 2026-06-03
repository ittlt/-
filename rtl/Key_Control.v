// 按键消抖与频率控制模块（简洁版 - 延时消抖）
module Key_Control(
    input           clk,
    input           rst_n,
    input [3:0]     key_in,
    output reg [31:0]fcw,
    output reg [1:0]wave_sel,
    output reg      led_key
);

reg [19:0] cnt [0:3];     // 每个按键独立消抖计数器
reg [3:0]  key_db;         // 消抖后的按键状态
reg [3:0]  key_db_prev;    // 上一拍的消抖值（边沿检测用）
integer i;

parameter FCW_DEFAULT = 32'd10737418;
parameter FCW_STEP    = 32'd107374;
parameter FCW_MIN     = 32'd10737;

// 消抖逻辑：
//   key_in[i] == key_db[i] → 计数器清零（稳定）
//   key_in[i] != key_db[i] → 计数器累加（抖动或真变化）
//   计数器满 → key_db[i] <= key_in[i]（确认变化）
always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        key_db      <= 4'b1111;
        key_db_prev <= 4'b1111;
        for(i=0; i<4; i=i+1) cnt[i] <= 20'd0;
    end else begin
        key_db_prev <= key_db;
        for(i=0; i<4; i=i+1) begin
            if(key_in[i] == key_db[i])
                cnt[i] <= 20'd0;
            else if(cnt[i] < 20'd1_000_000)
                cnt[i] <= cnt[i] + 20'd1;
            else
                key_db[i] <= key_in[i];
        end
    end
end

// 下降沿脉冲（key_db由1变0，单周期）
wire [3:0] key_fall = key_db_prev & (~key_db);

// 频率/波形控制
reg [31:0] fcw_reg;
reg [1:0]  wave_sel_reg;

always @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        fcw_reg      <= FCW_DEFAULT;
        wave_sel_reg <= 2'b00;
        led_key      <= 1'b0;
    end else begin
        led_key <= 1'b0;
        case(key_fall)
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
