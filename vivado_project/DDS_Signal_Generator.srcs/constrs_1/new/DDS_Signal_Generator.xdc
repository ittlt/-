## 时钟信号 - 50MHz系统时钟 (PL_GCLK)
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
set_property IOSTANDARD LVCMOS33 [get_ports led_uart]
