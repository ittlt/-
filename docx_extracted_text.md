__基于FPGA的DDS信号发生器实现实验指导书__

<a id="heading_0"></a>__一、适用平台__

本实验以FPGA为核心硬件平台，搭配信号转换、按键、串口等外设构建完整开发环境，具体要求如下：

- 核心控制模块：DE2实验板（核心芯片为Altera Cyclone II EP2C35F672C6），该芯片具备35840个逻辑单元、1056KB嵌入式存储单元及4个PLL锁相环模块，可满足DDS信号生成的高速相位累加运算需求，同时提供丰富I/O口支持多外设扩展；
- 开发环境：软件层面采用Quartus II 13\.0及以上版本（负责FPGA工程创建、Verilog代码编译、时序分析与程序下载）、ModelSim\-Altera（用于Verilog代码功能仿真与时序仿真验证）、串口调试助手（如SecureCRT、SSCOM，实现PC端与FPGA串口通信调试）；
- 外设模块：数模转换（DAC）模块（选用AD9708，实现数字信号到模拟信号的高速转换）、4个独立按键模块（用于频率手动调整）、RS232串口通信模块（实现PC端与FPGA的数据交互）、示波器（用于观测并验证输出模拟信号波形）；
- 辅助工具：5V直流电源（为DE2实验板及外设供电）、杜邦线（用于模块间信号连接）、RS232转USB线（实现PC与DE2实验板的串口通信扩展）、示波器探头（用于采集DAC输出的模拟信号）。

<a id="heading_1"></a>__二、实验内容__

本实验核心围绕基于FPGA的DDS信号发生器三大核心功能展开，最终实现“控制指令输入（按键/串口）\-FPGA核心处理\-DDS信号合成\-DAC数模转换\-信号验证”的完整闭环，具体内容如下：

1. Verilog代码编写与DDS信号输出实现及验证：深入理解DDS信号合成原理（相位累加器、相位\-幅度映射、数字波形生成），基于Verilog HDL编写DDS信号生成核心代码，包含相位累加器模块、相位\-幅度查找表（LUT）模块（支持正弦/方波/三角波）及数字信号输出模块。在Quartus II中完成工程创建、代码编译与时序约束，将程序下载至DE2实验板；通过DAC模块将FPGA输出的数字信号转换为模拟信号，利用示波器观测输出波形，验证信号频率、幅值等参数的正确性。
2. 按键控制DDS信号频率调整实现：完成按键模块与FPGA的硬件连接，基于Verilog编写按键消抖模块（解决机械按键抖动问题）与频率调整控制模块。通过4个独立按键定义不同功能（如“频率增加”“频率减少”“波形切换”“确认锁定”），实现DDS信号输出频率的步进式调整（如步进100Hz、1kHz）；操作过程中通过示波器实时观测信号频率变化，验证按键控制功能的有效性与稳定性。
3. 串行口控制DDS信号频率调整实现：基于FPGA的UART接口搭建串口通信电路，通过RS232转USB线完成PC端与DE2实验板的连接。基于Verilog编写UART接收模块，实现PC端通过串口调试助手发送频率控制指令（如ASCII码格式的频率值）；编写指令解析模块，将接收的串口指令转换为DDS相位累加器所需的频率控制字，实现对DDS信号频率的精准调整；同时，设计反馈机制，向PC端发送频率调整完成的确认信息，验证串口通信的可靠性与频率控制的精准性。

<a id="heading_2"></a>__三、技术路线__

本实验采用“FPGA核心控制\+DDS数字合成\+双模式频率调控\+DAC数模转换\+波形验证”的技术路线，遵循“需求分析\-系统架构设计\-FPGA逻辑开发\-硬件电路搭建\-系统集成调试\-功能验证”的分步实施流程，确保实验目标顺利达成，具体流程如下：

1. 需求梳理与系统架构设计：明确实验核心需求（实现DDS信号输出、支持按键/串口双模式频率调整、频率范围100Hz\-1MHz）；划分核心功能模块（DDS信号生成模块、按键控制模块、UART串口模块、DAC驱动模块）；定义各模块间的信号交互规则（如频率控制字传输格式、按键指令编码、串口数据帧格式）。
2. FPGA逻辑开发与仿真验证：基于Verilog HDL分模块编写代码（DDS核心模块、按键消抖模块、UART接收模块、频率控制模块）；在ModelSim\-Altera中搭建仿真平台，编写测试激励文件，对各模块进行功能仿真与时序仿真，验证模块逻辑正确性（如相位累加器计数精度、按键消抖效果、UART数据接收完整性）；整合各模块代码进行系统级仿真，确保模块间协同工作正常。
3. 硬件电路设计与搭建：根据系统架构完成硬件连接：① FPGA的DDS数字信号输出端与AD9708 DAC模块的数字信号输入端连接；② 4个独立按键与FPGA I/O口连接；③ FPGA UART接口与RS232电平转换模块（MAX232）连接；④ DAC模块模拟信号输出端与示波器探头连接；⑤ 5V电源与DE2实验板、DAC模块的供电接口连接；使用万用表检测电路连通性，避免短路、虚焊问题。
4. FPGA工程配置与程序下载：在Quartus II中创建基于DE2实验板（Cyclone II EP2C35F672C6）的工程，导入编写的Verilog代码；进行引脚约束（将DDS输出、按键输入、UART接口等信号映射到FPGA具体引脚）；设置时序约束（基于系统时钟频率约束关键路径）；完成代码编译与综合，生成FPGA配置文件（\.sof格式）；通过JTAG下载线将配置文件下载至DE2实验板。
5. 系统集成调试与功能验证：分别对三大核心功能进行调试：① DDS信号输出调试：通过示波器观测DAC输出波形，优化相位累加器位宽、查找表深度等参数提升波形质量；② 按键控制调试：操作按键调整频率，验证频率变化是否符合预期，优化消抖参数；③ 串口控制调试：通过串口调试助手发送指令，验证指令解析与频率调整功能，优化波特率（如9600bps）与数据帧格式；最终全面验证系统功能完整性与稳定性。

<a id="heading_3"></a>__四、硬件设计步骤__

本实验硬件设计以DE2实验板为核心，围绕DDS信号输出与DAC转换、按键控制、串口通信三大功能模块展开，具体设计步骤如下：

<a id="heading_4"></a>__4\.1 核心控制模块（DE2实验板）电路设计__

1. 核心芯片确认：明确DE2实验板核心芯片为Altera Cyclone II EP2C35F672C6，梳理其可用I/O口、时钟接口、JTAG下载接口等关键资源；
2. 电源电路设计：采用5V直流电源通过实验板电源接口供电，实验板内部稳压模块将5V转换为3\.3V，为FPGA核心电路、I/O口及板载外设供电；连接电源开关，便于实验过程中设备启停控制；
3. 时钟电路设计：利用DE2实验板板载的50MHz有源晶振作为系统时钟源，通过FPGA内部PLL锁相环模块将50MHz时钟倍频至100MHz，为DDS相位累加器、UART串口等模块提供稳定同步时钟；
4. 调试接口设计：预留JTAG下载接口，用于连接Quartus II开发环境实现程序下载与在线调试；预留3个板载LED指示灯接口，分别用于指示系统工作状态、按键操作有效状态、串口通信状态。

<a id="heading_5"></a>__4\.2 DDS信号输出与DAC转换模块电路设计__

1. DAC模块选型：选用AD9708高速DAC芯片（8位分辨率，最高转换速率125MSPS，单5V供电），满足中高频DDS信号的数模转换需求；

- 电路连接：
- 数字信号输入：将FPGA的8位I/O口（如GPIO\_0~GPIO\_7）作为DDS数字信号输出端，对应连接至AD9708的D0~D7数字信号输入端，传输DDS生成的数字波形数据；
- 时钟与控制信号：将FPGA输出的100MHz同步时钟信号连接至AD9708的CLK引脚，为DAC转换提供时钟同步；将FPGA的GPIO\_8引脚连接至AD9708的RESET引脚，用于DAC模块复位控制；
- 模拟信号输出：AD9708的VOUT引脚为模拟信号输出端，通过示波器探头连接至该引脚观测波形；在VOUT引脚端并联10nF电容进行滤波，提升输出信号稳定性；
- 供电与接地：AD9708的VDD引脚接入5V电源，VSS引脚与FPGA、实验板共地，确保电源稳定性与信号完整性。

<a id="heading_6"></a>__4\.3 按键控制模块电路设计__

1. 按键选型：选用4个独立机械按键，分别定义为“Freq\+”（频率增加）、“Freq\-”（频率减少）、“Wave\_Sel”（波形切换）、“Confirm”（确认锁定）功能；

- 电路连接：
- 信号连接：每个按键的一端对应连接FPGA的I/O口（如GPIO\_9~GPIO\_12），另一端接地；
- 上拉电阻设计：在每个FPGA I/O口与3\.3V电源之间连接10KΩ上拉电阻，确保按键未按下时，FPGA引脚为高电平；按键按下时，引脚被拉低为低电平，通过电平变化检测按键操作；
- 消抖设计：在每个按键两端并联0\.1μF电容，减少机械抖动对信号检测的影响；
- I/O口配置：将FPGA对应I/O口配置为输入模式，确保按键信号稳定传输。

<a id="heading_7"></a>__4\.4 串口通信模块电路设计__

1. 串口模块选型：利用DE2实验板板载的RS232串口接口，搭配MAX232电平转换芯片，实现FPGA UART接口（3\.3V TTL电平）与PC端RS232接口（±12V电平）的电平匹配；

- 电路连接：
- FPGA与MAX232连接：FPGA的UART\_TX引脚（如GPIO\_13）连接至MAX232芯片的T1IN引脚，FPGA的UART\_RX引脚（如GPIO\_14）连接至MAX232芯片的R1OUT引脚；
- MAX232与RS232接口连接：MAX232芯片的T1OUT引脚连接至RS232接口的TXD引脚，MAX232芯片的R1IN引脚连接至RS232接口的RXD引脚；
- 供电与接地：MAX232芯片的VCC引脚接入5V电源，VEE引脚通过电荷泵电路产生负电压，GND引脚与FPGA、实验板共地；
- PC端连接：使用RS232转USB线连接RS232接口与PC端USB接口，安装对应驱动程序，实现PC与FPGA的串口通信。

<a id="heading_8"></a>__五、功能软件架构__

本实验基于Verilog HDL开发的FPGA逻辑代码采用“模块化分层架构”设计，整体分为底层驱动层、核心功能层、控制交互层、系统整合层，各层职责清晰、耦合度低，便于开发、调试与维护，具体架构如下：

<a id="heading_9"></a>__5\.1 架构分层及职责__

- 底层驱动层：
- 核心职责：为上层模块提供基础硬件驱动支持，封装底层硬件操作逻辑，屏蔽硬件细节；
- 主要组件：时钟生成模块、按键消抖模块、UART接收模块、DAC驱动模块；
- 核心逻辑：时钟生成模块基于FPGA内部PLL实现100MHz系统时钟及UART波特率时钟（16倍频）生成；按键消抖模块通过时序逻辑过滤按键抖动，输出稳定的按键电平信号；UART接收模块实现串口数据的异步接收、位同步与帧解析（起始位\+8位数据位\+1位停止位）；DAC驱动模块实现DDS数字信号的同步输出与DAC模块复位控制。
- 核心功能层：
- 核心职责：实现DDS信号生成的核心逻辑，完成频率控制字计算、相位累加、相位\-幅度映射及多波形生成；
- 主要组件：频率控制字计算模块、相位累加器模块、相位\-幅度查找表（LUT）模块；
- 核心逻辑：频率控制字计算模块根据上层控制指令（按键/串口）计算对应的DDS频率控制字（FCW）；相位累加器模块在系统时钟驱动下，基于FCW进行相位累加并输出相位值；相位\-幅度LUT模块存储正弦、方波、三角波的相位\-幅度映射数据，根据相位值查找对应的幅度值，生成数字波形信号。

1. 控制交互层：  


- 核心职责：实现按键与串口控制指令的解析，生成DDS信号调整控制信号，完成上层控制与核心功能层的交互；
- 主要组件：按键指令解析模块、串口指令解析模块、控制信号生成模块；
- 核心逻辑：按键指令解析模块将消抖后的按键信号转换为频率调整、波形切换指令；串口指令解析模块将UART接收的PC端指令（ASCII码格式）解析为频率值并计算对应的频率控制字；控制信号生成模块根据解析后的指令，输出频率控制字更新信号、波形选择信号，控制核心功能层的DDS信号生成。
- 系统整合层：
- 核心职责：整合各底层与功能模块，实现模块间的信号同步与数据交互，协调系统整体工作流程；
- 主要组件：系统顶层模块、信号同步模块、状态指示模块；
- 核心逻辑：系统顶层模块实例化各功能模块，定义模块间的信号连接；信号同步模块确保各模块时钟、控制信号的同步性，避免时序冲突；状态指示模块通过板载LED指示灯展示系统工作状态（如当前频率调整状态、串口通信状态），便于实验调试。

<a id="heading_10"></a>__5\.2 核心模块工作流程__

1. DDS信号生成流程：系统启动后，底层时钟模块生成100MHz系统时钟；频率控制字计算模块初始化默认频率控制字；相位累加器模块在系统时钟驱动下基于默认FCW进行相位累加，输出相位值；相位\-幅度LUT模块根据相位值查找幅度数据，生成数字波形信号；DAC驱动模块将数字波形信号同步输出至AD9708，完成数模转换并输出模拟信号。
2. 按键控制流程：按键按下时，按键消抖模块对按键信号进行消抖处理，输出稳定的按键电平；按键指令解析模块检测按键类型，生成对应的控制指令（如“Freq\+”“Wave\_Sel”）；控制信号生成模块根据指令计算新的频率控制字，发送更新信号至相位累加器模块；相位累加器模块更新FCW，重新进行相位累加，生成新频率的波形信号，实现频率调整。
3. 串口控制流程：PC端通过串口调试助手发送频率控制指令（如“F100000”表示设置频率为100kHz）；UART接收模块接收串口数据，完成位同步与帧解析，提取频率值；串口指令解析模块将频率值转换为对应的频率控制字；控制信号生成模块发送频率控制字更新信号至相位累加器模块；相位累加器模块更新FCW，生成新频率的DDS信号；同时，系统通过UART模块向PC端发送“频率更新完成”反馈指令，完成一次串口控制流程。

<a id="heading_11"></a>__六、核心实现代码与代码详细注释__

<a id="heading_12"></a>__6\.1 Quartus II工程配置关键步骤__

// 1\. 工程创建：启动Quartus II，点击“New Project Wizard”，设置工程名称与保存路径，点击“Next”至芯片选择步骤；  
// 2\. 芯片选择：选择“Altera”\->“Cyclone II”\->“EP2C35F672C6”，确认芯片型号后完成工程创建；  
// 3\. 代码导入：新建Verilog HDL文件，编写各功能模块代码（顶层模块、DDS核心模块、按键消抖模块、UART接收模块等），保存后导入工程；  
// 4\. 引脚约束：点击“Assignments”\->“Pin Planner”，打开引脚规划界面，进行如下引脚映射（根据DE2实验板引脚定义调整）：  
//    \- DDS数字信号输出（D0\-D7）：GPIO\_0\-GPIO\_7（对应FPGA引脚PIN\_21\-PIN\_28）；  
//    \- 按键输入（Freq\+、Freq\-、Wave\_Sel、Confirm）：GPIO\_9\-GPIO\_12（对应FPGA引脚PIN\_30\-PIN\_33）；  
//    \- UART接口（TX、RX）：GPIO\_13（UART\_TX，PIN\_34）、GPIO\_14（UART\_RX，PIN\_35）；  
//    \- DAC复位控制（RESET）：GPIO\_8（PIN\_29）；  
//    \- 系统时钟输入（50MHz晶振）：PIN\_12（CLK\_50MHz）；  
//    \- 状态指示LED：GPIO\_15\-GPIO\_17（PIN\_36\-PIN\_38）；  
// 5\. 时序约束：点击“Assignments”\->“Timing Constraints Wizard”，设置系统时钟频率为100MHz（PLL倍频后），约束关键路径时序；  
// 6\. PLL配置：点击“Tools”\->“MegaWizard Plug\-In Manager”，选择“Create a new custom megafunction variation”，选择“PLL”，将50MHz输入时钟倍频至100MHz，生成PLL时钟模块；  
// 7\. 工程编译：点击“Processing”\->“Start Compilation”，进行工程综合、布局布线与编译，确保无错误；  
// 8\. 程序下载：连接JTAG下载线至DE2实验板，点击“Tools”\->“Programmer”，选择下载文件（\.sof格式），点击“Start”下载程序至FPGA。

<a id="heading_13"></a>__6\.2 DDS核心模块代码（Verilog）__

// DDS信号发生器核心模块  
// 功能：基于相位累加器与查找表实现正弦/方波/三角波生成，支持频率控制字更新  
module DDS\_Core\(  
    input           clk,         // 系统时钟（100MHz）  
    input           rst\_n,       // 复位信号（低电平有效）  
    input \[31:0\]    fcw,         // 频率控制字（32位，决定输出频率）  
    input \[1:0\]     wave\_sel,    // 波形选择（00：正弦波，01：方波，10：三角波）  
    output reg \[7:0\]dds\_out      // DDS数字信号输出（8位，连接DAC）  
\);

// 内部信号定义  
reg \[31:0\] phase\_acc;  // 32位相位累加器，决定相位精度（相位范围0~2^32\-1，对应0~360°）  
wire \[7:0\] sin\_lut;    // 正弦波查找表输出  
wire \[7:0\] square\_wave; // 方波输出  
wire \[7:0\] triangle\_wave; // 三角波输出

// 1\. 相位累加器模块：根据频率控制字累加相位，系统时钟每周期累加一次FCW  
always @\(posedge clk or negedge rst\_n\) begin  
    if\(\!rst\_n\) begin  
        phase\_acc <= 32'd0;  // 复位时相位累加器清零，初始相位为0°  
    end else begin  
        // 相位累加：溢出后自动归零，实现相位循环（对应波形周期重复）  
        phase\_acc <= phase\_acc \+ fcw;    
    end  
end

// 2\. 正弦波查找表（LUT）：8位幅度（0~255），取32位相位累加器高8位作为索引（256个相位点）  
// 查找表数据为正弦波0~360°的幅度值，可通过MATLAB生成后导入（此处给出部分示例数据）  
reg \[7:0\] sin\_lut\_table \[0:255\];  
initial begin  
    // 初始化正弦波查找表，正弦波幅度范围映射为0~255（直流偏置128，幅值127）  
    sin\_lut\_table\[0\]  = 8'd128;  // 0°，幅度中点  
    sin\_lut\_table\[1\]  = 8'd131;  // 1\.40625°，幅度轻微上升  
    sin\_lut\_table\[2\]  = 8'd134;  // 2\.8125°，继续上升  
    // \.\.\. 省略中间250个数据点（实际实验需补充完整256个数据）  
    sin\_lut\_table\[254\] = 8'd131; // 357\.1875°，幅度下降  
    sin\_lut\_table\[255\] = 8'd128; // 358\.59375°，回到中点  
end  
// 取相位累加器高8位作为查找表索引，获取对应正弦波幅度值  
assign sin\_lut = sin\_lut\_table\[phase\_acc\[31:24\]\];  

// 3\. 方波生成：根据相位累加器高8位判断，大于127输出高电平（255），否则输出低电平（0）  
// 方波占空比为50%，幅度范围0~255  
assign square\_wave = \(phase\_acc\[31:24\] > 8'd127\) ? 8'd255 : 8'd0;

// 4\. 三角波生成：相位累加器高8位0~127时线性递增，128~255时线性递减  
// 幅度范围0~254，保证线性变化  
assign triangle\_wave = \(phase\_acc\[31:24\] <= 8'd127\) ?   
                 phase\_acc\[31:24\] << 1 :  // 0~127：0~254递增（左移1位等价于×2）  
                \(8'd255 \- \(phase\_acc\[31:24\] \- 8'd128\) << 1\);  // 128~255：254~0递减

// 5\. 波形选择与输出：根据wave\_sel信号选择对应波形，复位时输出低电平  
always @\(posedge clk or negedge rst\_n\) begin  
    if\(\!rst\_n\) begin  
        dds\_out <= 8'd0;  // 复位时输出低电平，确保DAC初始状态稳定  
    end else begin  
        case\(wave\_sel\)  
            2'b00: dds\_out <= sin\_lut;       // 选择正弦波输出  
            2'b01: dds\_out <= square\_wave;   // 选择方波输出  
            2'b10: dds\_out <= triangle\_wave; // 选择三角波输出  
            default: dds\_out <= sin\_lut;     // 默认输出正弦波，提高系统容错性  
        endcase  
    end  
end

endmodule

<a id="heading_14"></a>__6\.3 按键消抖与频率控制模块代码（Verilog）__

// 按键消抖与频率控制模块  
// 功能：实现4个按键的消抖处理，生成频率控制字与波形选择信号，输出至DDS核心模块  
module Key\_Control\(  
    input           clk,         // 系统时钟（100MHz）  
    input           rst\_n,       // 复位信号（低电平有效）  
    input \[3:0\]     key\_in,      // 按键输入（4位，对应Freq\+、Freq\-、Wave\_Sel、Confirm）  
    output reg \[31:0\]fcw,         // 输出频率控制字（送至DDS核心模块）  
    output reg \[1:0\]wave\_sel,    // 输出波形选择信号（送至DDS核心模块）  
    output reg      led\_key      // 按键有效指示LED（高电平有效）  
\);

// 内部信号定义  
reg \[19:0\] cnt\_debounce;  // 消抖计数器（100MHz时钟，计数20ms需1000000个时钟周期，2^20≈1048576≥1000000）  
reg \[3:0\] key\_sync;       // 按键同步信号（两级寄存器消除亚稳态）  
reg \[3:0\] key\_delay1;     // 按键延迟信号1  
reg \[3:0\] key\_delay2;     // 按键延迟信号2  
wire \[3:0\] key\_edge;      // 按键下降沿检测（按键按下时触发，消抖后）  
reg \[1:0\] wave\_sel\_reg;   // 波形选择寄存器（暂存波形选择状态）  
reg \[31:0\] fcw\_reg;       // 频率控制字寄存器（暂存频率控制字）

// 参数定义（频率控制字计算：FCW = 频率值 \* 2^32 / 系统时钟频率（100MHz））  
parameter FCW\_DEFAULT = 32'd10737418;  // 默认频率控制字（对应100kHz：100000 \* 2^32 / 100000000 = 10737418\.24，取整）  
parameter FCW\_STEP = 32'd107374;       // 频率步进控制字（对应1kHz：1000 \* 2^32 / 100000000 = 107374\.1824，取整）  
parameter FCW\_MIN = 32'd10737;         // 频率下限控制字（对应100Hz：100 \* 2^32 / 100000000 = 10737\.41824，取整）

// 1\. 按键同步与消抖处理：两级同步消除亚稳态，20ms消抖确认按键状态  
always @\(posedge clk or negedge rst\_n\) begin  
    if\(\!rst\_n\) begin  
        key\_sync <= 4'b1111;  // 初始状态为高电平（上拉电阻作用）  
        key\_delay1 <= 4'b1111;  
        key\_delay2 <= 4'b1111;  
        cnt\_debounce <= 20'd0;  
    end else begin  
        // 两级寄存器同步，消除按键信号亚稳态  
        key\_sync <= key\_in;  
        key\_delay1 <= key\_sync;  
        key\_delay2 <= key\_delay1;  
        // 消抖计数：当按键状态变化时，计数器清零重新计数；状态稳定时，计数器累加  
        if\(key\_delay1 \!= key\_delay2\) begin  
            cnt\_debounce <= 20'd0;  
        end else begin  
            cnt\_debounce <= cnt\_debounce \+ 20'd1;  
        end  
    end  
end

// 2\. 按键下降沿检测：消抖计数满20ms后，检测到key\_delay2由高变低则判定为有效按键  
assign key\_edge = key\_delay2 & \(~key\_delay1\) & \(cnt\_debounce == 20'd1\_000\_000\);

// 3\. 频率控制字与波形选择逻辑：根据有效按键信号更新频率控制字和波形选择状态  
always @\(posedge clk or negedge rst\_n\) begin  
    if\(\!rst\_n\) begin  
        fcw\_reg <= FCW\_DEFAULT;    // 复位时加载默认频率控制字（100kHz）  
        wave\_sel\_reg <= 2'b00;     // 初始选择正弦波  
        led\_key <= 1'b0;           // 复位时按键指示LED熄灭  
    end else begin  
        led\_key <= 1'b0;           // 默认LED熄灭，仅按键有效时点亮  
        case\(key\_edge\)  
            4'b0001: begin  // Freq\+按键按下（key\_in\[0\]对应Freq\+）  
                fcw\_reg <= fcw\_reg \+ FCW\_STEP;  // 频率增加1kHz  
                led\_key <= 1'b1;                // 按键有效，LED点亮  
            end  
            4'b0010: begin  // Freq\-按键按下（key\_in\[1\]对应Freq\-）  
                // 频率下限保护：确保频率不低于100Hz  
                if\(fcw\_reg >= FCW\_MIN \+ FCW\_STEP\) begin  
                    fcw\_reg <= fcw\_reg \- FCW\_STEP;  // 频率减少1kHz  
                end  
                led\_key <= 1'b1;                    // 按键有效，LED点亮  
            end  
            4'b0100: begin  // Wave\_Sel按键按下（key\_in\[2\]对应Wave\_Sel）  
               wave\_sel\_reg <= wave\_sel\_reg \+ 2'd1; // 切换波形（正弦\->方波\->三角波）  
               if\(wave\_sel\_reg == 2'b10\) begin      // 三角波之后回到正弦波，循环切换  
               wave\_sel\_reg <= 2'b00;  
                end  
                led\_key <= 1'b1;                      // 按键有效，LED点亮  
            end  
            4'b1000: begin  // Confirm按键按下（key\_in\[3\]对应Confirm）  
                // 确认锁定当前频率与波形（此处直接保持当前状态，无额外锁定逻辑）  
                led\_key <= 1'b1;                      // 按键有效，LED点亮  
            end  
            default: begin  // 无按键操作，保持当前状态  
                fcw\_reg <= fcw\_reg;  
                wave\_sel\_reg <= wave\_sel\_reg;  
            end  
        endcase  
    end  
end

// 4\. 输出赋值：将暂存的频率控制字和波形选择信号输出至DDS核心模块  
always @\(posedge clk or negedge rst\_n\) begin  
    if\(\!rst\_n\) begin  
        fcw <= FCW\_DEFAULT;  
        wave\_sel <= 2'b00;  
    end else begin  
        fcw <= fcw\_reg;  
        wave\_sel <= wave\_sel\_reg;  
    end  
end

endmodule

<a id="heading_15"></a>__6\.4 UART接收与指令解析模块代码（Verilog）__

// UART接收与指令解析模块  
// 功能：实现UART异步接收（9600bps），解析PC端频率控制指令，生成频率控制字输出至DDS核心模块  
module UART\_Parse\(  
    input           clk,         // 系统时钟（100MHz）  
    input           rst\_n,       // 复位信号（低电平有效）  
    input           uart\_rx,     // UART接收引脚  
    output reg \[31:0\]fcw\_uart,   // 解析后的频率控制字（送至DDS核心模块）  
    output reg      fcw\_update,  // 频率控制字更新标志（高电平有效，通知DDS模块更新）  
    output reg      led\_uart     // 串口通信状态指示LED（高电平有效）  
\);

// 内部信号定义  
reg \[15:0\] cnt\_baud;      // 波特率时钟计数器（9600bps，100MHz时钟下，波特率周期≈10417个时钟周期）  
reg \[3:0\] cnt\_bit;        // 位计数器（0\-9：对应起始位\+8位数据位\+1位停止位）  
reg \[7:0\] uart\_data;      // 接收的数据字节（8位）  
reg \[7:0\] cmd\_buf \[0:5\];  // 指令缓存（存储ASCII码格式的频率指令，格式：“Fxxxxxx”，共6个数据字节）  
reg \[2:0\] cmd\_cnt;        // 指令字节计数器（0\-6，计数接收的指令字节数）  
reg uart\_rx\_sync1;        // 接收信号同步寄存器1  
reg uart\_rx\_sync2;        // 接收信号同步寄存器2  
reg uart\_rx\_sync3;        // 接收信号同步寄存器3  
wire uart\_rx\_neg;         // 接收信号下降沿检测（用于捕获起始位）  
reg recv\_flag;            // 单字节接收完成标志

// 参数定义（波特率相关）  
parameter BAUD\_CNT = 16'd10416;  // 9600bps波特率计数最大值（100MHz/9600 \- 1 ≈ 10416）  
parameter BAUD\_HALF = 16'd5208;  // 波特率半周期计数（用于位采样，确保在位周期中间采样）  
parameter FCW\_DEFAULT = 32'd10737418;  // 默认频率控制字（100kHz）

// 1\. 接收信号同步与下降沿检测：三级同步消除亚稳态，检测起始位下降沿  
always @\(posedge clk or negedge rst\_n\) begin  
    if\(\!rst\_n\) begin  
        uart\_rx\_sync1 <= 1'b1;  
        uart\_rx\_sync2 <= 1'b1;  
        uart\_rx\_sync3 <= 1'b1;  
    end else begin  
        // 三级寄存器同步，消除UART接收信号的亚稳态  
        uart\_rx\_sync1 <= uart\_rx;  
        uart\_rx\_sync2 <= uart\_rx\_sync1;  
        uart\_rx\_sync3 <= uart\_rx\_sync2;  
    end  
end  
// 检测下降沿（uart\_rx\_sync2由1变0，且uart\_rx\_sync3为1）  
assign uart\_rx\_neg = ~uart\_rx\_sync2 & uart\_rx\_sync3;

// 2\. 波特率时钟生成与位计数：检测到起始位后，启动波特率计数与位计数  
always @\(posedge clk or negedge rst\_n\) begin  
    if\(\!rst\_n\) begin  
        cnt\_baud <= 16'd0;  
        cnt\_bit <= 4'd0;  
        recv\_flag <= 1'b0;  
        led\_uart <= 1'b0;  
    end else if\(uart\_rx\_neg\) begin  // 检测到起始位，开始接收过程  
        cnt\_baud <= BAUD\_HALF;     // 计数至半周期，准备在第一位数据的中间位置采样  
        cnt\_bit <= 4'd1;           // 位计数器置1（起始位为0，对应cnt\_bit=0）  
        recv\_flag <= 1'b0;  
        led\_uart <= 1'b1;          // 串口接收中，LED点亮  
    end else if\(cnt\_bit \!= 4'd0\) begin  // 正在接收数据（位计数器不为0）  
        cnt\_baud <= cnt\_baud \+ 16'd1;  
        if\(cnt\_baud == BAUD\_CNT\) begin  // 一个波特率周期结束  
            cnt\_baud <= 16'd0;  
            cnt\_bit <= cnt\_bit \+ 4'd1;  
           if\(cnt\_bit == 4'd9\) begin  // 接收完成（已接收起始位\+8位数据位\+1位停止位）  
                cnt\_bit <= 4'd0;  
                recv\_flag <= 1'b1;     // 单字节接收完成标志置1  
                led\_uart <= 1'b0;      // 接收完成，LED熄灭  
            end  
        end  
    end else begin  
        recv\_flag <= 1'b0;  // 无接收过程，接收完成标志清零  
    end  
end

// 3\. UART数据接收：在每个位周期的中间位置采样数据（8位数据位，无校验位，1位停止位）  
always @\(posedge clk or negedge rst\_n\) begin  
    if\(\!rst\_n\) begin  
        uart\_data <= 8'd0;  
    end else if\(cnt\_bit \!= 4'd0 && cnt\_baud == BAUD\_HALF\) begin  

// 在位周期中间采样，确保采样稳定  
        case\(cnt\_bit\)  
            4'd2: uart\_data\[0\] <= uart\_rx\_sync2;  // 第1位数据（LSB，最低有效位）  
            4'd3: uart\_data\[1\] <= uart\_rx\_sync2;  
            4'd4: uart\_data\[2\] <= uart\_rx\_sync2;  
            4'd5: uart\_data\[3\] <= uart\_rx\_sync2;  
            4'd6: uart\_data\[4\] <= uart\_rx\_sync2;  
            4'd7: uart\_data\[5\] <= uart\_rx\_sync2;  
            4'd8: uart\_data\[6\] <= uart\_rx\_sync2;  
            4'd9: uart\_data\[7\] <= uart\_rx\_sync2;  // 第8位数据（MSB，最高有效位）  
            default: ;  // 其他位（起始位、停止位）不采样  
        endcase  
    end  
end

// 4\. 指令解析：指令格式为“Fxxxxxx”，F为指令头（ASCII码0x46），后接6位ASCII码表示的频率值（单位Hz）  
always @\(posedge clk or negedge rst\_n\) begin  
    if\(\!rst\_n\) begin  
        cmd\_cnt <= 3'd0;  
        fcw\_uart <= FCW\_DEFAULT;  // 复位时加载默认频率控制字（100kHz）  
        fcw\_update <= 1'b0;  
    end else if\(recv\_flag\) begin  // 单字节接收完成，开始解析  
        if\(cmd\_cnt == 3'd0\) begin  // 接收第一个字节，判断是否为指令头  
            if\(uart\_data == 8'h46\) begin  // 指令头为'F'（ASCII码0x46），确认指令有效  
                cmd\_cnt <= 3'd1;  
            end else begin  
                cmd\_cnt <= 3'd0;  // 指令头错误，丢弃当前接收数据  
            end  
        end else if\(cmd\_cnt <= 3'd6\) begin  // 接收后续6位频率数字的ASCII码  
            cmd\_buf\[cmd\_cnt\-1\] <= uart\_data;  // 存储到指令缓存  
            cmd\_cnt <= cmd\_cnt \+ 3'd1;  
            if\(cmd\_cnt == 3'd6\) begin  // 6位数字接收完成，开始转换为频率值  
                cmd\_cnt <= 3'd0;  
             // 将ASCII码转换为十进制频率值（ASCII码0x30对应数字0，0x39对应数字9）  
                reg \[23:0\] freq;  // 频率值暂存（最大支持999999Hz，24位足够存储）  
                freq = \(cmd\_buf\[0\]\-8'h30\)\*100000 \+ \(cmd\_buf\[1\]\-8'h30\)\*10000 \+   
                       \(cmd\_buf\[2\]\-8'h30\)\*1000 \+ \(cmd\_buf\[3\]\-8'h30\)\*100 \+   
                       \(cmd\_buf\[4\]\-8'h30\)\*10 \+ \(cmd\_buf\[5\]\-8'h30\)\*1;  
                // 计算频率控制字：FCW = 频率值 \* 2^32 / 100MHz  
                fcw\_uart <= \(freq << 32\) / 100\_000\_000;  
                fcw\_update <= 1'b1;  // 频率控制字更新标志置1，通知DDS模块更新  
            \#10 fcw\_update <= 1'b0; // 延迟10个时钟周期后清零标志（确保DDS模块捕获）  
            end  
        end  
    end  
end

endmodule

<a id="heading_16"></a>__6\.5 系统顶层模块代码（Verilog）__

// 系统顶层模块：整合各功能模块，实现完整DDS信号发生器功能  
// 模块间信号交互：PLL生成100MHz时钟，按键/串口模块生成控制信号，DDS核心模块生成数字波形，输出至DAC  
module DDS\_Signal\_Generator\(  
    input           clk\_50mhz,   // 50MHz系统时钟输入（DE2实验板板载晶振）  
    input           rst\_n,       // 复位信号（低电平有效）  
    input \[3:0\]     key\_in,      // 按键输入（4位）  
    input           uart\_rx,     // UART接收引脚  
    output \[7:0\]    dds\_out,     // DDS数字信号输出（连接DAC）  
    output          dac\_rst,     // DAC复位控制  
    output          led\_key,     // 按键状态指示LED  
    output          led\_uart,    // 串口状态指示LED  
    output          led\_sys      // 系统工作状态指示LED（PLL锁定状态）  
\);

// 内部信号定义  
wire        clk\_100mhz;      // PLL输出100MHz系统时钟  
wire \[31:0\] fcw\_key;         // 按键控制模块输出的频率控制字  
wire \[31:0\] fcw\_uart;        // UART解析模块输出的频率控制字  
wire \[1:0\]  wave\_sel;         // 波形选择信号（来自按键控制模块）  
wire        fcw\_update;       // UART频率控制字更新标志  
reg \[31:0\]  fcw\_sel;          // 频率控制字选择输出（选择按键或串口控制字）

// 1\. PLL模块实例化（将50MHz输入时钟倍频至100MHz，提供系统同步时钟）  
// 注：pll\_50m\_to\_100m模块为通过Quartus II MegaWizard生成的PLL IP核  
pll\_50m\_to\_100m pll\_inst\(  
    \.inclk0\(clk\_50mhz\),  // PLL输入时钟（50MHz）  
    \.c0\(clk\_100mhz\),     // PLL输出时钟（100MHz）  
    \.locked\(led\_sys\)     // PLL锁定标志（高电平有效，作为系统工作状态指示）  
\);

// 2\. DAC复位控制：复位信号低电平时DAC复位，复位完成后高电平使能DAC工作  
assign dac\_rst = rst\_n;

// 3\. 按键控制模块实例化：处理按键输入，生成频率控制字和波形选择信号  
Key\_Control key\_ctrl\_inst\(  
    \.clk\(clk\_100mhz\),  
    \.rst\_n\(rst\_n\),  
    \.key\_in\(key\_in\),  
    \.fcw\(fcw\_key\),  
    \.wave\_sel\(wave\_sel\),  
    \.led\_key\(led\_key\)  
\);

// 4\. UART接收与解析模块实例化：接收PC端串口指令，解析生成频率控制字  
UART\_Parse uart\_parse\_inst\(  
    \.clk\(clk\_100mhz\),  
    \.rst\_n\(rst\_n\),  
    \.uart\_rx\(uart\_rx\),  
    \.fcw\_uart\(fcw\_uart\),  
    \.fcw\_update\(fcw\_update\),  
    \.led\_uart\(led\_uart\)  
\);

// 5\. 频率控制字选择逻辑：串口控制优先，当有串口更新标志时选择串口控制字，否则选择按键控制字  
always @\(posedge clk\_100mhz or negedge rst\_n\) begin  
    if\(\!rst\_n\) begin  
        fcw\_sel <= 32'd10737418;  // 复位时默认选择100kHz频率控制字  
    end else if\(fcw\_update\) begin  
        fcw\_sel <= fcw\_uart;       // 串口更新时，选择UART解析的频率控制字  
    end else begin  
        fcw\_sel <= fcw\_key;        // 无串口更新时，选择按键控制的频率控制字  
    end  
end

// 6\. DDS核心模块实例化：根据选择的频率控制字和波形选择信号，生成数字波形输出  
DDS\_Core dds\_core\_inst\(  
    \.clk\(clk\_100mhz\),  
    \.rst\_n\(rst\_n\),  
    \.fcw\(fcw\_sel\),  
    \.wave\_sel\(wave\_sel\),  
    \.dds\_out\(dds\_out\)  
\);

endmodule

