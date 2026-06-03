# ============================================================================
# ModelSim GUI仿真脚本（Windows版本）
# 使用方法：
#   Windows: D:\FPGA_software\Modelsim_2020_4\win64\vsim.exe -do sim\run_sim_win.do
#   WSL:     /mnt/d/FPGA_software/Modelsim_2020_4/win64/vsim.exe -do sim/run_sim_win.do
# ============================================================================

# 设置项目根目录（Windows路径，硬编码）
set ROOT_DIR "D:/Work_Place/Cursor/claude/DDS_project"

# 仿真结束时间（ns）：200ms = 200,000,000 ns
set END_TIME "200ms"

# 1. 清除旧工程
quit -sim
if [file exists work] {
    vdel -lib work -all
}

# 2. 创建工作库
vlib work
vmap work work

# 3. 编译RTL源文件
echo "====== 编译RTL模块 ======"
vlog -work work [file join $ROOT_DIR rtl DDS_Core.v]
vlog -work work [file join $ROOT_DIR rtl Key_Control.v]
vlog -work work [file join $ROOT_DIR rtl UART_Parse.v]
vlog -work work [file join $ROOT_DIR rtl DDS_Signal_Generator.v]

# 4. 编译仿真文件
echo "====== 编译仿真文件 ======"
vlog -work work [file join $ROOT_DIR tb tb_DDS_Signal_Generator.v]

# 5. 启动仿真（+acc保留所有信号层次）
echo "====== 启动仿真 ======"
vsim -t 1ns -voptargs=+acc -lib work tb_DDS_Signal_Generator

# 6. 添加波形信号（分组）
echo "====== 配置波形窗口 ======"

# --- 分组1：时钟与复位 ---
add wave -divider "Clock & Reset"
add wave -radix unsigned /tb_DDS_Signal_Generator/clk_50mhz
add wave -radix unsigned /tb_DDS_Signal_Generator/rst_n

# --- 分组2：按键输入 ---
add wave -divider "Key Input"
add wave -radix binary -color cyan /tb_DDS_Signal_Generator/key_in

# --- 分组3：UART ---
add wave -divider "UART"
add wave -radix unsigned -color orange /tb_DDS_Signal_Generator/uart_rx

# --- 分组4：DDS输出 ---
add wave -divider "DDS Output"
add wave -radix unsigned -color green /tb_DDS_Signal_Generator/dds_out
add wave -radix unsigned /tb_DDS_Signal_Generator/led_key
add wave -radix unsigned /tb_DDS_Signal_Generator/led_uart

# --- 分组5：按键控制内部信号 ---
add wave -divider "Key_Control Internal"
add wave -radix binary /tb_DDS_Signal_Generator/u_dut/key_ctrl_inst/key_fall
add wave -radix binary /tb_DDS_Signal_Generator/u_dut/key_ctrl_inst/key_db
add wave -radix binary /tb_DDS_Signal_Generator/u_dut/key_ctrl_inst/key_in
add wave -radix unsigned /tb_DDS_Signal_Generator/u_dut/key_ctrl_inst/cnt

# --- 分组6：DDS核心 ---
add wave -divider "DDS Core"
add wave -radix binary -color yellow /tb_DDS_Signal_Generator/u_dut/wave_sel
add wave -radix unsigned /tb_DDS_Signal_Generator/u_dut/fcw_sel
add wave -radix unsigned /tb_DDS_Signal_Generator/u_dut/dds_core_inst/phase_acc
add wave -radix unsigned -color green /tb_DDS_Signal_Generator/u_dut/dds_core_inst/sin_lut
add wave -radix unsigned /tb_DDS_Signal_Generator/u_dut/dds_core_inst/square_wave
add wave -radix unsigned /tb_DDS_Signal_Generator/u_dut/dds_core_inst/triangle_wave

# --- 分组7：UART解析 ---
add wave -divider "UART Parse"
add wave -radix unsigned /tb_DDS_Signal_Generator/u_dut/uart_parse_inst/cnt_bit
add wave -radix unsigned /tb_DDS_Signal_Generator/u_dut/uart_parse_inst/cmd_cnt
add wave -radix hexadecimal -color orange /tb_DDS_Signal_Generator/u_dut/uart_parse_inst/uart_data
add wave -radix unsigned /tb_DDS_Signal_Generator/u_dut/uart_parse_inst/fcw_uart
add wave -radix unsigned /tb_DDS_Signal_Generator/u_dut/uart_parse_inst/fcw_update

# --- 分组8：频率选择 ---
add wave -divider "Frequency Select"
add wave -radix unsigned /tb_DDS_Signal_Generator/u_dut/fcw_key
add wave -radix unsigned /tb_DDS_Signal_Generator/u_dut/fcw_uart
add wave -radix unsigned -color yellow /tb_DDS_Signal_Generator/u_dut/fcw_sel
add wave -radix unsigned /tb_DDS_Signal_Generator/u_dut/fcw_update

# 7. 配置波形显示
configure wave -namecolwidth 320
configure wave -valuecolwidth 120
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns

# 8. 运行仿真
echo "====== 开始仿真 ($END_TIME) ======"
run $END_TIME

# 9. 缩放至全部波形
WaveRestoreZoom {0 ps} {$END_TIME}

# 10. 保存波形配置文件（后续可直接加载）
write format wave [file join $ROOT_DIR sim wave.do]
echo "====== 波形配置已保存: sim/wave.do ======"

echo "====== 仿真完成，波形已加载 ======"
