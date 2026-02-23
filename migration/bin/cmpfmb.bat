@echo off
setlocal

echo -----------------------------------------------------------------
echo Compile Forms 12c Module %1
echo -----------------------------------------------------------------

call %MIG_HOME%\bin\setenv.bat

set MIG_TEST_DIR=%MIG_TEST12_DIR%
set FORMS_PATH=%MIG_TEST12_DIR%
set ORACLE_HOME=C:\Middleware12\Oracle_Home
set PATH=%ORACLE_HOME%\bin;%ORACLE_HOME%\jdk\bin;C:\Windows\system32;C:\Windows;C:\Windows\System32\Wbem
set FORMS_PLSQL_BHVR_COMMON_SQL=1
set FRMCMP=%ORACLE_HOME%\BIN\frmcmp.exe
set FMB=%1.fmb

cd /d %MIG_TEST_DIR%

if exist %1.fmx del /f /q %1.fmx
if exist %1.fmt del /f /q %1.fmt
if exist %1.err del /f /q %1.err
if exist %FMB%.save del /f /q %FMB%.save
if not exist logfmb mkdir logfmb

echo Compile %FMB%
copy /y "%FMB%" "%FMB%.save" > :nul
%FRMCMP% module="%FMB%" module_type=FORM userid=%MIG_DBCONNECT% compile_all=yes batch=yes window_state=minimize
del /f /q "%FMB%"
ren "%FMB%.save" "%FMB%"
if exist %1.err move /y %1.err logfmb

cd /d %MIG_HOME%

endlocal
echo on
