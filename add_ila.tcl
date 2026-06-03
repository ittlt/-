# 添加ILA IP核到现有工程
# 在Vivado Tcl Console中运行：source D:/FPGAmoudle/--main/--main/add_ila.tcl

# 打开工程
open_project D:/FPGAmoudle/--main/--main/vivado_project/DDS_Signal_Generator.xpr

# 检查ILA是否已存在
if {[llength [get_ips -quiet ila_0]] == 0} {
    # 创建ILA IP核 (7系列器件)
    create_ip -name ila -vendor xilinx.com -library ip -version 6.2 \
        -module_name ila_0
} else {
    puts "ILA IP核已存在，跳过创建"
}

# 配置ILA: 1个探针端口，位宽8位，监控dds_out[7:0]
# 探针时钟使用clk_100mhz (PLL输出)
set_property -dict [list \
    CONFIG.C_NUM_OF_PROBES {1} \
    CONFIG.C_PROBE0_WIDTH {8} \
    CONFIG.C_INPUT_PIPE_STAGES {0} \
] [get_ips ila_0]

# 生成ILA输出产品
generate_target all [get_files ila_0.xci]

# 添加ILA实例化到顶层（通过网表插入方式）
# 在综合后使用Mark Debug方式标记dds_out信号

# 保存并关闭工程
close_project

puts "=========================================="
puts "ILA IP核已添加到工程!"
puts "探针配置: 8位宽, 监控dds_out[7:0]"
puts "=========================================="
puts ""
puts "后续操作步骤:"
puts "1. 运行综合 (Run Synthesis)"
puts "2. 综合完成后，在Netlist Design中找到dds_out信号"
puts "3. 右键 -> Mark Debug"
puts "4. 运行实现 (Run Implementation)"
puts "5. 生成比特流 (Generate Bitstream)"
puts "6. 打开Hardware Manager，连接ILA进行调试"
