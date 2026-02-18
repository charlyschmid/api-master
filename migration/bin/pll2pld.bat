@echo off
setlocal
echo.
echo convert %1.pll to %1.pld
set frmcmp=E:\oracle\product\Middleware11gR2\Oracle_FRHome1\BIN\frmcmp.exe
set dbconnect=winstd/winstd@f11mig
if exist %1.pld del /f /q %1.pld
%frmcmp% module=%1.pll output_file=%1.pld module_type=LIBRARY userid=%dbconnect% script=yes batch=yes window_state=minimize
endlocal
