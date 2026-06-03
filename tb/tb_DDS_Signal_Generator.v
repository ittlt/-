// DDS信号发生器仿真测试平台
`timescale 1ns / 1ps

module tb_DDS_Signal_Generator;

reg         clk_50mhz;
reg         rst_n;
reg  [3:0]  key_in;
reg         uart_rx;
wire [7:0]  dds_out;
wire        dac_rst, led_key, led_uart, led_sys;

parameter BAUD_PERIOD = 104167;  // 9600bps

DDS_Signal_Generator_sim u_dut(
    .clk_50mhz(clk_50mhz), .rst_n(rst_n), .key_in(key_in),
    .uart_rx(uart_rx), .dds_out(dds_out), .dac_rst(dac_rst),
    .led_key(led_key), .led_uart(led_uart), .led_sys(led_sys)
);

initial begin clk_50mhz=0; forever #10 clk_50mhz=~clk_50mhz; end

initial begin
    rst_n=0; key_in=4'b1111; uart_rx=1'b1;
    #200; rst_n=1; #100;

    // TEST1: 默认正弦波
    $display("\n=== TEST1: 正弦波 (FCW=10737418, ~100kHz) ===");
    repeat(100) begin @(posedge u_dut.clk_100mhz);
        $display("t=%0d phase=%0d sin=%0d out=%0d sel=%b",
            $time, u_dut.dds_core_inst.phase_acc[31:24],
            u_dut.dds_core_inst.sin_lut, dds_out, u_dut.wave_sel);
    end

    // TEST2: 切换方波
    $display("\n=== TEST2: 按键切换方波 ===");
    key_in[2]=0; #25_000_000; key_in[2]=1; #11_000_000;
    $display("wave_sel=%b (期望01)", u_dut.wave_sel);

    // TEST3: 切换三角波
    $display("\n=== TEST3: 按键切换三角波 ===");
    key_in[2]=0; #25_000_000; key_in[2]=1; #11_000_000;
    $display("wave_sel=%b (期望10)", u_dut.wave_sel);

    // TEST4: Freq+
    $display("\n=== TEST4: Freq+ ===");
    $display("操作前FCW=%0d", u_dut.fcw_sel);
    key_in[0]=0; #25_000_000; key_in[0]=1; #11_000_000;
    $display("操作后FCW=%0d (期望10844792)", u_dut.fcw_sel);

    // TEST5: UART F200000
    $display("\n=== TEST5: UART F200000 ===");
    $display("操作前FCW=%0d", u_dut.fcw_sel);
    uart_send(8'h46); uart_send(8'h32); uart_send(8'h30);
    uart_send(8'h30); uart_send(8'h30); uart_send(8'h30); uart_send(8'h30);
    #2_000_000;
    $display("fcw_uart=%0d, fcw_sel=%0d (期望8589935)",
             u_dut.uart_parse_inst.fcw_uart, u_dut.fcw_sel);

    // TEST6: 复位
    $display("\n=== TEST6: 复位 ===");
    $display("复位前: FCW=%0d wave_sel=%b", u_dut.fcw_sel, u_dut.wave_sel);
    rst_n=0; #200; rst_n=1; #500;
    $display("复位后: FCW=%0d (期望10737418) wave_sel=%b (期望00)",
             u_dut.fcw_sel, u_dut.wave_sel);

    $display("\n=== 所有测试完成 ===");
    $finish;
end

task uart_send;
    input [7:0] data;
    integer i;
    begin
        uart_rx=0; #BAUD_PERIOD;
        for(i=0;i<8;i=i+1) begin uart_rx=data[i]; #BAUD_PERIOD; end
        uart_rx=1; #BAUD_PERIOD;
    end
endtask

endmodule

// 仿真用顶层模块（行为级PLL）
module DDS_Signal_Generator_sim(
    input clk_50mhz, input rst_n, input [3:0] key_in, input uart_rx,
    output [7:0] dds_out, output dac_rst, output led_key, output led_uart, output led_sys
);
reg clk_100mhz; initial clk_100mhz=0; always #5 clk_100mhz=~clk_100mhz;
assign led_sys=1; assign dac_rst=rst_n;

wire [31:0] fcw_key, fcw_uart;
wire [1:0] wave_sel;
wire fcw_update;
reg [31:0] fcw_sel;
reg fcw_update_prev;

Key_Control key_ctrl_inst(.clk(clk_100mhz), .rst_n(rst_n), .key_in(key_in),
    .fcw(fcw_key), .wave_sel(wave_sel), .led_key(led_key));

UART_Parse uart_parse_inst(.clk(clk_100mhz), .rst_n(rst_n), .uart_rx(uart_rx),
    .fcw_uart(fcw_uart), .fcw_update(fcw_update), .led_uart(led_uart));

// 频率选择：串口更新后锁定，否则跟随按键
reg fcw_uart_lock;
always @(posedge clk_100mhz) fcw_update_prev <= fcw_update;
always @(posedge clk_100mhz or negedge rst_n) begin
    if(!rst_n) begin
        fcw_sel <= 32'd10737418;
        fcw_uart_lock <= 0;
    end else if(fcw_update && !fcw_update_prev) begin
        fcw_sel <= fcw_uart;
        fcw_uart_lock <= 1;
    end else if(!fcw_uart_lock) begin
        fcw_sel <= fcw_key;
    end
end

DDS_Core dds_core_inst(.clk(clk_100mhz), .rst_n(rst_n),
    .fcw(fcw_sel), .wave_sel(wave_sel), .dds_out(dds_out));
endmodule
