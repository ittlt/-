// System Top Module
module DDS_Signal_Generator(
    input           clk_50mhz,
    input           rst_n,
    input [2:0]     key_in,
    input           uart_rx,
    output [7:0]    dds_out,
    output          dac_rst,
    output          uart_tx,
   // output          led_key,
    output          led_sys,
    output          led_uart
);

wire        clk_100mhz;
wire [31:0] fcw_key;
wire [1:0]  wave_sel;
reg  [31:0] fcw_sel;

wire [31:0] fcw_uart;
wire        fcw_update;

// 1. PLL 50MHz -> 100MHz
pll_50m_to_100m pll_inst(
    .clk_in1(clk_50mhz),
    .clk_out1(clk_100mhz),
    .resetn(rst_n),
    .locked(led_sys)
);

// 2. DAC reset
assign dac_rst = rst_n;

// 3. Key Control
Key_Control key_ctrl_inst(
    .clk(clk_100mhz),
    .rst_n(rst_n),
    .key_in(key_in),
    .fcw(fcw_key),
    .wave_sel(wave_sel),
    .key_vilad(key_vilad)
);

// 4. HMI UART Receive
HMI_Recv hmi_recv_inst(
    .clk(clk_100mhz),
    .rst_n(rst_n),
    .HMI_RX(uart_rx),
    .HMI_Num(fcw_uart),
    .HMI_Done(fcw_update)
);

// HMI_Recv无TX和LED输出，tie off
assign uart_tx = 1'b1;
assign led_uart = 1'b0;

// 5. FCW select - UART优先
always @(posedge clk_100mhz or negedge rst_n) begin
    if(!rst_n)
        fcw_sel <= 32'd10737418;
    else if(fcw_update)
        fcw_sel <= fcw_uart;
    else if(key_vilad)
        fcw_sel <= fcw_key;
end

// 6. DDS Core
DDS_Core dds_core_inst(
    .clk(clk_100mhz),
    .rst_n(rst_n),
    .fcw(fcw_sel),
    .wave_sel(wave_sel),
    .dds_out(dds_out)
);

// 7. ILA Debug - monitor fcw_uart(HMI_Num) and uart_rx
(* DONT_TOUCH = "TRUE" *)
ila_0 ila_inst(
    .clk(clk_100mhz),
    .probe0(fcw_uart),     // HMI_Num [31:0]
    .probe1(uart_rx),
    .probe2(dds_out)
);

endmodule
