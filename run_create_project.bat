@echo off
REM 用Vivado批处理模式创建工程
REM 双击运行即可

set VIVADO=D:\tools\vivado\2019.2\bin\vivado.bat
set TCL_SCRIPT=D:\FPGAmoudle\--main\--main\create_project.tcl

echo 正在创建Vivado工程...
"%VIVADO%" -mode batch -source "%TCL_SCRIPT%"

echo.
echo 完成！工程位于: vivado_project\DDS_Signal_Generator.xpr
pause
