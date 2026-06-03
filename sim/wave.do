onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Clock & Reset}
add wave -noupdate -radix unsigned /tb_DDS_Signal_Generator/clk_50mhz
add wave -noupdate -radix unsigned /tb_DDS_Signal_Generator/rst_n
add wave -noupdate -divider {Key Input}
add wave -noupdate -color cyan -radix binary /tb_DDS_Signal_Generator/key_in
add wave -noupdate -divider UART
add wave -noupdate -color orange -radix unsigned /tb_DDS_Signal_Generator/uart_rx
add wave -noupdate -divider {DDS Output}
add wave -noupdate -color green -format Analog-Step -height 74 -max 254.99999999999997 -radix unsigned /tb_DDS_Signal_Generator/dds_out
add wave -noupdate -radix unsigned /tb_DDS_Signal_Generator/led_key
add wave -noupdate -radix unsigned /tb_DDS_Signal_Generator/led_uart
add wave -noupdate -divider {Key_Control Internal}
add wave -noupdate -radix binary /tb_DDS_Signal_Generator/u_dut/key_ctrl_inst/key_fall
add wave -noupdate -radix binary /tb_DDS_Signal_Generator/u_dut/key_ctrl_inst/key_db
add wave -noupdate -radix binary /tb_DDS_Signal_Generator/u_dut/key_ctrl_inst/key_in
add wave -noupdate -radix unsigned /tb_DDS_Signal_Generator/u_dut/key_ctrl_inst/cnt
add wave -noupdate -divider {DDS Core}
add wave -noupdate -color yellow -radix binary /tb_DDS_Signal_Generator/u_dut/wave_sel
add wave -noupdate -radix unsigned /tb_DDS_Signal_Generator/u_dut/fcw_sel
add wave -noupdate -radix unsigned /tb_DDS_Signal_Generator/u_dut/dds_core_inst/phase_acc
add wave -noupdate -color green -radix unsigned /tb_DDS_Signal_Generator/u_dut/dds_core_inst/sin_lut
add wave -noupdate -radix unsigned /tb_DDS_Signal_Generator/u_dut/dds_core_inst/square_wave
add wave -noupdate -radix unsigned /tb_DDS_Signal_Generator/u_dut/dds_core_inst/triangle_wave
add wave -noupdate -divider {UART Parse}
add wave -noupdate -radix unsigned /tb_DDS_Signal_Generator/u_dut/uart_parse_inst/cnt_bit
add wave -noupdate -radix unsigned /tb_DDS_Signal_Generator/u_dut/uart_parse_inst/cmd_cnt
add wave -noupdate -color orange -radix hexadecimal /tb_DDS_Signal_Generator/u_dut/uart_parse_inst/uart_data
add wave -noupdate -radix unsigned /tb_DDS_Signal_Generator/u_dut/uart_parse_inst/fcw_uart
add wave -noupdate -radix unsigned /tb_DDS_Signal_Generator/u_dut/uart_parse_inst/fcw_update
add wave -noupdate -divider {Frequency Select}
add wave -noupdate -radix unsigned /tb_DDS_Signal_Generator/u_dut/fcw_key
add wave -noupdate -radix unsigned /tb_DDS_Signal_Generator/u_dut/fcw_uart
add wave -noupdate -color yellow -radix unsigned /tb_DDS_Signal_Generator/u_dut/fcw_sel
add wave -noupdate -radix unsigned /tb_DDS_Signal_Generator/u_dut/fcw_update
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {82956414 ns} 0}
quietly wave cursor active 1
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
update
WaveRestoreZoom {0 ns} {123158369 ns}
