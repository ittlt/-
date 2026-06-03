# DDS信号发生器

基于FPGA的DDS（直接数字频率合成）信号发生器，支持正弦波/方波/三角波生成，频率可通过按键或UART串口控制。

## 功能特性

- 3种波形输出：正弦波、方波、三角波
- 32位相位累加器，频率精度 0.023Hz
- 8位DAC输出（0~255）
- 4个按键控制：频率+/-、波形切换、预留
- UART串口控制：9600bps，支持 0~999999Hz 频率设置
- 复位功能：恢复默认100kHz正弦波

## 项目结构

```
├── rtl/                        # RTL源码
│   ├── DDS_Core.v              # DDS核心：相位累加器 + 正弦LUT + 方波/三角波生成
│   ├── Key_Control.v           # 按键消抖（延时消抖） + 频率/波形控制
│   ├── UART_Parse.v            # UART接收（9600bps） + 指令解析 → FCW
│   └── DDS_Signal_Generator.v  # 系统顶层：PLL + 按键 + UART + DDS + 频率选择
├── tb/
│   └── tb_DDS_Signal_Generator.v  # 仿真测试台（含行为级PLL模型）
├── sim/
│   ├── run_sim.sh              # WSL一键仿真脚本
│   └── run_sim_win.do          # ModelSim GUI脚本（Windows）
├── DDS_top.v                   # 原始单文件（历史参考）
└── CLAUDE.md                   # 项目开发文档
```

## 模块层次

```
DDS_Signal_Generator (顶层)
├── pll_50m_to_100m      (Quartus PLL IP，仿真用行为模型替代)
├── Key_Control           (按键消抖 + FCW/wave_sel)
├── UART_Parse            (UART接收 + FCW计算)
└── DDS_Core              (相位累加 + 波形查找表 + 输出选择)
```

## 关键参数

| 参数 | 值 | 说明 |
|------|-----|------|
| 系统时钟 | 100MHz（PLL倍频自50MHz） | 相位累加器时钟 |
| 相位累加器 | 32位 | 频率精度 ≈ 0.023Hz |
| DAC输出 | 8位（0~255） | 正弦波LUT 256点 |
| 默认FCW | 10737418 | 对应100kHz |
| FCW步进 | 107374 | 对应1kHz（按键Freq+/-） |
| UART波特率 | 9600bps, 8N1 | 指令格式：'F'+6位ASCII频率(Hz) |
| 消抖时间 | 10ms | 4个按键独立消抖 |

## 仿真方法

### Windows ModelSim（推荐）

```cmd
D:\FPGA_software\Modelsim_2020_4\win64\vsim.exe -do sim\run_sim_win.do
```

自动编译、运行仿真、显示分组波形、保存wave.do配置文件。

### WSL环境

```bash
bash sim/run_sim.sh
```

命令行模式，打印测试结果到stdout。

### 测试用例

| 测试 | 内容 | 验证点 | 结果 |
|------|------|--------|------|
| TEST1 | 默认正弦波 | phase_acc递增，sin_lut正确 | PASS |
| TEST2 | 按键切换方波 | wave_sel=01 | PASS |
| TEST3 | 按键切换三角波 | wave_sel=10 | PASS |
| TEST4 | Freq+增加频率 | FCW: 10737418→10844792 | PASS |
| TEST5 | UART F200000 | fcw_uart=8589934 | PASS |
| TEST6 | 复位 | FCW恢复10737418 | PASS |

## UART指令格式

```
格式：'F' + 6位ASCII数字（频率单位Hz）
示例：F200000 → 200kHz, F001000 → 1kHz, F000500 → 500Hz
范围：0 ~ 999999 Hz
```

字节序列（十六进制）：`46 3x 3x 3x 3x 3x 3x`（3x为ASCII数字0-9）

## FCW计算公式

```
FCW = freq × 2^32 / 100_000_000
```

UART解析中的权重（6位数字 d0~d5）：
```
d0(十万位) × 4294967 + d1(万位) × 429497 + d2(千位) × 42950
+ d3(百位) × 4295 + d4(十位) × 429 + d5(个位) × 43
```

## 目标平台

- **FPGA**：DE2开发板（Cyclone II）
- **晶振**：50MHz
- **DAC**：8位输出
- **仿真工具**：ModelSim 2020.4（Windows）

## 已知限制

- UART指令中十位和个位使用同一字节，对非整十频率有微小误差
- PLL IP核需在Quartus中生成，仿真用行为模型替代
- 按键消抖时间10ms，仿真中需等待>10ms才能触发第二次按键
