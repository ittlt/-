# ============================================================================
# ModelSim 仿真脚本（Windows路径版本）
# 由WSL自动调用
# ============================================================================

# 设置项目根目录（Windows路径）
set ROOT_DIR [file normalize [file dirname [info script]]/..]

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

# 5. 启动仿真
echo "====== 启动仿真 ======"
vsim -t 1ns -lib work tb_DDS_Signal_Generator



# 8. 运行仿真
echo "====== 开始仿真 ======"
run 200ms

echo "====== 仿真完成 ======"
# 输出finish信号
finish
