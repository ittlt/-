# ============================================================================
# ModelSim 自动化仿真脚本
# 使用方法：
#   Windows CMD:  D:\modelsim2020\modeltech64_2020.4\win64\vsim.exe -do sim\run_sim.do
#   WSL:          /mnt/d/modelsim2020/modeltech64_2020.4/win64/vsim.exe -do sim/run_sim.do
# ============================================================================

# 1. 清除旧工程
quit -sim
if [file exists work] {
    vdel -lib work -all
}

# 2. 创建工作库
vlib work
vmap work work

# 3. 编译RTL源文件（按依赖顺序）
echo "====== 编译RTL模块 ======"
vlog -work work rtl/DDS_Core.v
vlog -work work rtl/Key_Control.v
vlog -work work rtl/UART_Parse.v
vlog -work work rtl/DDS_Signal_Generator.v

# 4. 编译仿真文件
echo "====== 编译仿真文件 ======"
vlog -work work tb/tb_DDS_Signal_Generator.v

# 5. 启动仿真（加载仿真用顶层模块）
echo "====== 启动仿真 ======"
vsim -t 1ns -lib work tb_DDS_Signal_Generator

# 6. 添加波形信号
echo "====== 配置波形窗口 ======"
# 顶层信号
add wave -divider "=== Clock & Reset ==="
add wave -radix unsigned /tb_DDS_Signal_Generator/clk_50mhz
add wave -radix unsigned /tb_DDS_Signal_Generator/rst_n

add wave -divider "=== Keys ==="
add wave -radix binary /tb_DDS_Signal_Generator/key_in

add wave -divider "=== UART ==="
add wave -radix unsigned /tb_DDS_Signal_Generator/uart_rx

add wave -divider "=== DDS Output ==="
add wave -radix unsigned /tb_DDS_Signal_Generator/dds_out
add wave -radix unsigned /tb_DDS_Signal_Generator/led_key
add wave -radix unsigned /tb_DDS_Signal_Generator/led_uart

add wave -divider "=== Internal Signals ==="
add wave -radix binary /tb_DDS_Signal_Generator/u_dut/wave_sel
add wave -radix unsigned /tb_DDS_Signal_Generator/u_dut/fcw_sel
add wave -radix unsigned /tb_DDS_Signal_Generator/u_dut/dds_core_inst/phase_acc
add wave -radix unsigned /tb_DDS_Signal_Generator/u_dut/dds_core_inst/sin_lut
add wave -radix unsigned /tb_DDS_Signal_Generator/u_dut/dds_core_inst/square_wave
add wave -radix unsigned /tb_DDS_Signal_Generator/u_dut/dds_core_inst/triangle_wave

add wave -divider "=== UART Parse ==="
add wave -radix unsigned /tb_DDS_Signal_Generator/u_dut/uart_parse_inst/cnt_bit
add wave -radix unsigned /tb_DDS_Signal_Generator/u_dut/uart_parse_inst/cmd_cnt
add wave -radix hexadecimal /tb_DDS_Signal_Generator/u_dut/uart_parse_inst/uart_data
add wave -radix unsigned /tb_DDS_Signal_Generator/u_dut/uart_parse_inst/fcw_uart
add wave -radix unsigned /tb_DDS_Signal_Generator/u_dut/uart_parse_inst/fcw_update

# 7. 配置波形显示
configure wave -namecolwidth 280
configure wave -valuecolwidth 120
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2

# 8. 运行仿真
echo "====== 开始仿真 ======"
run 200ms

echo "====== 仿真完成 ======"
