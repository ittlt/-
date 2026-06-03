// DDS信号发生器仿真测试平台
// 功能：验证DDS_Core、Key_Control、UART_Parse及顶层模块功能
`timescale 1ns / 1ps

module tb_DDS_Signal_Generator;

// 时钟与复位
reg         clk_50mhz;
reg         rst_n;

// 按键输入（低电平有效，上拉）
reg  [3:0]  key_in;

// UART信号
reg         uart_rx;

// 输出信号
wire [7:0]  dds_out;
wire        dac_rst;
wire        led_key;
wire        led_uart;
wire        led_sys;

// 时钟周期参数
parameter CLK_50M_PERIOD = 20;    // 50MHz = 20ns
parameter CLK_100M_PERIOD = 10;   // 100MHz = 10ns
parameter BAUD_PERIOD = 104167;   // 9600bps ≈ 104167ns

// 实例化顶层模块（使用仿真用PLL行为模型替代IP核）
DDS_Signal_Generator_sim u_dut(
    .clk_50mhz  (clk_50mhz),
    .rst_n      (rst_n),
    .key_in     (key_in),
    .uart_rx    (uart_rx),
    .dds_out    (dds_out),
    .dac_rst    (dac_rst),
    .led_key    (led_key),
    .led_uart   (led_uart),
    .led_sys    (led_sys)
);

// 1. 50MHz时钟生成
initial begin
    clk_50mhz = 1'b0;
    forever #(CLK_50M_PERIOD/2) clk_50mhz = ~clk_50mhz;
end

// 2. VCD波形输出
initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, tb_DDS_Signal_Generator);
end

// 3. 仿真主流程
initial begin
    // 初始化
    rst_n   = 1'b0;
    key_in  = 4'b1111;   // 按键未按下（高电平）
    uart_rx = 1'b1;      // UART空闲高电平

    // 复位保持200ns
    #200;
    rst_n = 1'b1;
    #100;

    // ========== 测试1：默认正弦波输出 ==========
    $display("[%0t] TEST1: 默认正弦波输出（等待2个完整波形周期）", $time);
    // 默认FCW=10737418，对应100kHz，周期=10us
    #20000;  // 等待20us观察正弦波

    // ========== 测试2：按键切换波形 - 方波 ==========
    $display("[%0t] TEST2: 按键切换至方波", $time);
    key_in[2] = 1'b0;    // Wave_Sel按键按下
    #25_000_000;          // 保持25ms（超过消抖时间20ms）
    key_in[2] = 1'b1;    // 释放按键
    #10000;               // 等待输出稳定
    #20000;               // 观察方波输出

    // ========== 测试3：按键切换波形 - 三角波 ==========
    $display("[%0t] TEST3: 按键切换至三角波", $time);
    key_in[2] = 1'b0;
    #25_000_000;
    key_in[2] = 1'b1;
    #10000;
    #20000;               // 观察三角波输出

    // ========== 测试4：按键增加频率 ==========
    $display("[%0t] TEST4: 按键Freq+增加频率", $time);
    key_in[0] = 1'b0;    // Freq+按键按下
    #25_000_000;
    key_in[0] = 1'b1;
    #10000;
    #20000;               // 观察频率变化

    // ========== 测试5：UART发送指令 "F200000" ==========
    $display("[%0t] TEST5: UART发送F200000指令", $time);
    uart_send_byte(8'h46);   // 'F'
    uart_send_byte(8'h32);   // '2'
    uart_send_byte(8'h30);   // '0'
    uart_send_byte(8'h30);   // '0'
    uart_send_byte(8'h30);   // '0'
    uart_send_byte(8'h30);   // '0'
    uart_send_byte(8'h30);   // '0'
    #50000;                   // 等待FCW更新

    // 观察新频率下的波形
    $display("[%0t] TEST5: 观察200kHz波形", $time);
    #50000;

    // ========== 测试6：复位测试 ==========
    $display("[%0t] TEST6: 复位测试", $time);
    rst_n = 1'b0;
    #200;
    rst_n = 1'b1;
    #20000;

    $display("[%0t] ====== 所有测试完成 ======", $time);
    $finish;
end

// UART发送单字节task（9600bps, 8N1）
task uart_send_byte;
    input [7:0] data;
    integer i;
    begin
        // 起始位
        uart_rx = 1'b0;
        #BAUD_PERIOD;

        // 8位数据位（LSB first）
        for(i = 0; i < 8; i = i + 1) begin
            uart_rx = data[i];
            #BAUD_PERIOD;
        end

        // 停止位
        uart_rx = 1'b1;
        #BAUD_PERIOD;

        // 字节间隔
        #BAUD_PERIOD;
    end
endtask

// 监控DDS输出变化
always @(posedge u_dut.clk_100mhz) begin
    if(rst_n && $time > 1000) begin
        // 每1000个周期打印一次（可按需注释）
        // $display("[%0t] dds_out=%0d, wave_sel=%02b", $time, dds_out, u_dut.wave_sel);
    end
end

endmodule

// ============================================================================
// 仿真用顶层模块（用行为级PLL替代Quartus IP核）
// ============================================================================
module DDS_Signal_Generator_sim(
    input           clk_50mhz,
    input           rst_n,
    input [3:0]     key_in,
    input           uart_rx,
    output [7:0]    dds_out,
    output          dac_rst,
    output          led_key,
    output          led_uart,
    output          led_sys
);

// 行为级PLL：50MHz -> 100MHz
reg clk_100mhz;
initial clk_100mhz = 1'b0;
always #(5) clk_100mhz = ~clk_100mhz;  // 100MHz, 周期10ns

// PLL锁定信号（仿真中始终为高）
assign led_sys = 1'b1;

// 内部信号
wire [31:0] fcw_key;
wire [31:0] fcw_uart;
wire [1:0]  wave_sel;
wire        fcw_update;
reg  [31:0] fcw_sel;

// DAC复位控制
assign dac_rst = rst_n;

// 按键控制模块
Key_Control key_ctrl_inst(
    .clk(clk_100mhz),
    .rst_n(rst_n),
    .key_in(key_in),
    .fcw(fcw_key),
    .wave_sel(wave_sel),
    .led_key(led_key)
);

// UART解析模块
UART_Parse uart_parse_inst(
    .clk(clk_100mhz),
    .rst_n(rst_n),
    .uart_rx(uart_rx),
    .fcw_uart(fcw_uart),
    .fcw_update(fcw_update),
    .led_uart(led_uart)
);

// 频率控制字选择（串口优先）
always @(posedge clk_100mhz or negedge rst_n) begin
    if(!rst_n)
        fcw_sel <= 32'd10737418;
    else if(fcw_update)
        fcw_sel <= fcw_uart;
    else
        fcw_sel <= fcw_key;
end

// DDS核心模块
DDS_Core dds_core_inst(
    .clk(clk_100mhz),
    .rst_n(rst_n),
    .fcw(fcw_sel),
    .wave_sel(wave_sel),
    .dds_out(dds_out)
);

endmodule
