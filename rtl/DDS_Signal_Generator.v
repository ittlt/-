// 系统顶层模块：整合各功能模块，实现完整DDS信号发生器功能
module DDS_Signal_Generator(
    input           clk_50mhz,   // 50MHz系统时钟输入
    input           rst_n,       // 复位信号（低电平有效）
    input [3:0]     key_in,      // 按键输入
    input           uart_rx,     // UART接收引脚
    output [7:0]    dds_out,     // DDS数字信号输出
    output          dac_rst,     // DAC复位控制
    output          led_key,     // 按键状态指示LED
    output          led_uart,    // 串口状态指示LED
    output          led_sys      // 系统工作状态指示LED
);

// 内部信号定义
wire        clk_100mhz;
wire [31:0] fcw_key;
wire [31:0] fcw_uart;
wire [1:0]  wave_sel;
wire        fcw_update;
reg  [31:0] fcw_sel;

// 1. PLL模块实例化（50MHz -> 100MHz）
pll_50m_to_100m pll_inst(
    .inclk0(clk_50mhz),
    .c0(clk_100mhz),
    .locked(led_sys)
);

// 2. DAC复位控制
assign dac_rst = rst_n;

// 3. 按键控制模块实例化
Key_Control key_ctrl_inst(
    .clk(clk_100mhz),
    .rst_n(rst_n),
    .key_in(key_in),
    .fcw(fcw_key),
    .wave_sel(wave_sel),
    .led_key(led_key)
);

// 4. UART接收与解析模块实例化
UART_Parse uart_parse_inst(
    .clk(clk_100mhz),
    .rst_n(rst_n),
    .uart_rx(uart_rx),
    .fcw_uart(fcw_uart),
    .fcw_update(fcw_update),
    .led_uart(led_uart)
);

// 5. 频率控制字选择逻辑（串口优先）
always @(posedge clk_100mhz or negedge rst_n) begin
    if(!rst_n) begin
        fcw_sel <= 32'd10737418;
    end else if(fcw_update) begin
        fcw_sel <= fcw_uart;
    end else begin
        fcw_sel <= fcw_key;
    end
end

// 6. DDS核心模块实例化
DDS_Core dds_core_inst(
    .clk(clk_100mhz),
    .rst_n(rst_n),
    .fcw(fcw_sel),
    .wave_sel(wave_sel),
    .dds_out(dds_out)
);

endmodule
