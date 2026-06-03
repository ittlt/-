@echo off
REM 直接打开Vivado工程
REM 用法：双击运行此文件

REM Vivado安装路径
set VIVADO_PATH=D:\tools\vivado\2019.2\bin\unwrapped\win64.o\vivado.exe

REM 工程路径
set PROJ_PATH=%~dp0vivado_project\DDS_Signal_Generator.xpr

REM 检查Vivado是否存在
if not exist "%VIVADO_PATH%" (
    echo 错误：未找到Vivado
    pause
    exit /b 1
)

REM 检查工程文件是否存在
if not exist "%PROJ_PATH%" (
    echo 错误：未找到工程文件 %PROJ_PATH%
    pause
    exit /b 1
)

REM 启动Vivado并打开工程
echo 正在启动Vivado...
start "" "%VIVADO_PATH%" "%PROJ_PATH%"

echo Vivado已启动
