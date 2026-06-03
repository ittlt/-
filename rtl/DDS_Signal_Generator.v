// System Top Module
module DDS_Signal_Generator(
    input           clk_50mhz,
    input           rst_n,
    input [2:0]     key_in,
    output [7:0]    dds_out,
    output          dac_rst,
    output          led_key,
    output          led_sys
);

wire        clk_100mhz;
wire [31:0] fcw_key;
wire [1:0]  wave_sel;
reg  [31:0] fcw_sel;

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
    .led_key(led_key)
);

// 4. FCW select
always @(posedge clk_100mhz or negedge rst_n) begin
    if(!rst_n) begin
        fcw_sel <= 32'd10737418;
    end else begin
        fcw_sel <= fcw_key;
    end
end

// 5. DDS Core
DDS_Core dds_core_inst(
    .clk(clk_100mhz),
    .rst_n(rst_n),
    .fcw(fcw_sel),
    .wave_sel(wave_sel),
    .dds_out(dds_out)
);

// 6. ILA Debug - monitor dds_out[7:0]
(* DONT_TOUCH = "TRUE" *)
ila_0 ila_inst(
    .clk(clk_100mhz),
    .probe0(dds_out)
);

endmodule
