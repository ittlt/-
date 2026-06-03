set ROOT "//wsl.localhost/Ubuntu1/home/pyf/github"

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
run 200ms
quit -f
