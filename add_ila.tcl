# 重新配置ILA IP核（2个探针）
# 在Vivado Tcl Console中运行：source D:/FPGAmoudle/--main/--main/add_ila.tcl

# 打开工程
open_project D:/FPGAmoudle/--main/--main/vivado_project/DDS_Signal_Generator.xpr

# 创建ILA IP核 (7系列器件)
create_ip -name ila -vendor xilinx.com -library ip -version 6.2 \
    -module_name ila_0

# 配置ILA: 2个探针端口
# probe0: 8位宽, 监控dds_out[7:0]
# probe1: 1位宽, 监控uart_rx
set_property -dict [list \
    CONFIG.C_NUM_OF_PROBES {2} \
    CONFIG.C_PROBE0_WIDTH {8} \
    CONFIG.C_PROBE1_WIDTH {1} \
    CONFIG.C_INPUT_PIPE_STAGES {0} \
] [get_ips ila_0]

# 生成ILA输出产品
generate_target all [get_files ila_0.xci]

# 保存并关闭工程
close_project

puts "=========================================="
puts "ILA IP核已重新配置!"
puts "探针配置: probe0=8位(dds_out), probe1=1位(uart_rx)"
puts "=========================================="
