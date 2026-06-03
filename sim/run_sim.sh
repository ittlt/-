#!/bin/bash
# WSL下运行ModelSim仿真包装脚本（命令行输出版）
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
MODELSIM_EXE="/mnt/d/modelsim2020/modeltech64_2020.4/win64/vsim.exe"

WIN_DIR=$(wslpath -w "$PROJECT_DIR" | sed 's|\\|/|g')

DO_FILE="$SCRIPT_DIR/run_sim_auto.do"
cat > "$DO_FILE" << EOF
set ROOT "$WIN_DIR"

quit -sim
if {[file exists work]} { vdel -lib work -all }
vlib work
vmap work work

vlog -work work "\$ROOT/rtl/DDS_Core.v"
vlog -work work "\$ROOT/rtl/Key_Control.v"
vlog -work work "\$ROOT/rtl/UART_Parse.v"
vlog -work work "\$ROOT/rtl/DDS_Signal_Generator.v"
vlog -work work "\$ROOT/tb/tb_DDS_Signal_Generator.v"

vsim -t 1ns -voptargs=+acc -lib work tb_DDS_Signal_Generator
run 200ms
quit -f
EOF

cd "$PROJECT_DIR"
"$MODELSIM_EXE" -c -do "$DO_FILE" 2>&1 | grep -v "^#"
