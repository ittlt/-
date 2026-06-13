# Vivado工程创建脚本
# 在Vivado Tcl Console中运行：source D:/FPGAmoudle/--main/--main/create_project.tcl

# 工程参数
set proj_name "DDS_Signal_Generator"
set proj_dir "D:/FPGAmoudle/--main/--main/vivado_project"
set part "xc7z010clg400-1"

# 删除旧工程（如存在）
if {[file exists $proj_dir]} {
    file delete -force $proj_dir
}

# 创建工程
create_project $proj_name $proj_dir -part $part -force

# 添加RTL源文件
add_files -norecurse {
    D:/FPGAmoudle/--main/--main/rtl/DDS_Signal_Generator.v
    D:/FPGAmoudle/--main/--main/rtl/DDS_Core.v
    D:/FPGAmoudle/--main/--main/rtl/Key_Control.v
    D:/FPGAmoudle/--main/--main/rtl/UART_Parse.v
}

# 设置顶层模块
set_property top DDS_Signal_Generator [current_fileset]

# 创建PLL IP核 (50MHz -> 100MHz)
create_ip -name clk_wiz -vendor xilinx.com -library ip -version 6.0 \
    -module_name pll_50m_to_100m

set_property -dict [list \
    CONFIG.PRIM_IN_FREQ {50} \
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {100} \
    CONFIG.USE_LOCKED {true} \
    CONFIG.RESET_TYPE {ACTIVE_LOW} \
    CONFIG.RESET_PORT {resetn} \
] [get_ips pll_50m_to_100m]

# 生成IP输出产品
generate_target all [get_files pll_50m_to_100m.xci]

# 创建XDC约束文件
set xdc_dir [file join $proj_dir $proj_name.srcs constrs_1 new]
file mkdir $xdc_dir
set xdc_file [file join $xdc_dir DDS_Signal_Generator.xdc]
set fp [open $xdc_file w]

puts $fp {## 时钟信号 - 50MHz系统时钟 (PL_GCLK)
set_property PACKAGE_PIN N18 [get_ports clk_50mhz]
set_property IOSTANDARD LVCMOS33 [get_ports clk_50mhz]

## 复位按键（低电平有效）- PL_KEY1
set_property PACKAGE_PIN G19 [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]

## PL端用户按键（3个，低电平有效）
set_property PACKAGE_PIN G20 [get_ports {key_in[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {key_in[0]}]
set_property PACKAGE_PIN H15 [get_ports {key_in[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {key_in[1]}]
set_property PACKAGE_PIN G15 [get_ports {key_in[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {key_in[2]}]

## UART串口
set_property PACKAGE_PIN W16 [get_ports uart_rx]
set_property IOSTANDARD LVCMOS33 [get_ports uart_rx]
set_property PACKAGE_PIN R17 [get_ports uart_tx]
set_property IOSTANDARD LVCMOS33 [get_ports uart_tx]

## 8位DAC输出 - 使用J25扩展接口
set_property PACKAGE_PIN T11 [get_ports {dds_out[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_out[0]}]
set_property PACKAGE_PIN T10 [get_ports {dds_out[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_out[1]}]
set_property PACKAGE_PIN T12 [get_ports {dds_out[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_out[2]}]
set_property PACKAGE_PIN U12 [get_ports {dds_out[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_out[3]}]
set_property PACKAGE_PIN U13 [get_ports {dds_out[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_out[4]}]
set_property PACKAGE_PIN V13 [get_ports {dds_out[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_out[5]}]
set_property PACKAGE_PIN T14 [get_ports {dds_out[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_out[6]}]
set_property PACKAGE_PIN T15 [get_ports {dds_out[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {dds_out[7]}]

## PL端LED指示灯
set_property PACKAGE_PIN K16 [get_ports dac_rst]
set_property IOSTANDARD LVCMOS33 [get_ports dac_rst]
set_property PACKAGE_PIN J16 [get_ports led_key]
set_property IOSTANDARD LVCMOS33 [get_ports led_key]
set_property PACKAGE_PIN J14 [get_ports led_sys]
set_property IOSTANDARD LVCMOS33 [get_ports led_sys]
set_property PACKAGE_PIN K19 [get_ports led_uart]
set_property IOSTANDARD LVCMOS33 [get_ports led_uart]}

close $fp

# 添加约束文件
add_files -fileset constrs_1 $xdc_file

# 更新编译顺序
update_compile_order -fileset sources_1

puts "=========================================="
puts "工程创建完成!"
puts "工程路径: $proj_dir/$proj_name.xpr"
puts "=========================================="
