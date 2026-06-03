set ROOT "D:/Work_Place/Cursor/claude/DDS_project"

quit -sim
if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work

vlog -work work "$ROOT/rtl/DDS_Core.v"
vlog -work work "$ROOT/rtl/Key_Control.v"
vlog -work work "$ROOT/rtl/UART_Parse.v"
vlog -work work "$ROOT/rtl/DDS_Signal_Generator.v"
vlog -work work "$ROOT/tb/tb_DDS_Signal_Generator.v"

vsim -t 1ns -voptargs=+acc -lib work tb_DDS_Signal_Generator

# 添加关键信号到波形窗口
add wave -divider "=== Test Signals ==="
add wave -radix unsigned /tb_DDS_Signal_Generator/clk_50mhz
add wave -radix unsigned /tb_DDS_Signal_Generator/rst_n
add wave -radix binary /tb_DDS_Signal_Generator/key_in
add wave -radix unsigned /tb_DDS_Signal_Generator/uart_rx
add wave -radix unsigned /tb_DDS_Signal_Generator/dds_out
add wave -radix binary /tb_DDS_Signal_Generator/u_dut/wave_sel
add wave -radix unsigned /tb_DDS_Signal_Generator/u_dut/fcw_sel
add wave -radix unsigned /tb_DDS_Signal_Generator/u_dut/dds_core_inst/phase_acc
add wave -radix unsigned /tb_DDS_Signal_Generator/u_dut/dds_core_inst/sin_lut
add wave -radix unsigned /tb_DDS_Signal_Generator/u_dut/fcw_key
add wave -radix unsigned /tb_DDS_Signal_Generator/u_dut/fcw_uart
add wave -radix unsigned /tb_DDS_Signal_Generator/u_dut/fcw_update

run 200ms
quit -f
