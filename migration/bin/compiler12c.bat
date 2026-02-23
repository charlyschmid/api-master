@echo off
setlocal
echo.
echo Generate Compiler Commands for Forms 12c

call %MIG_HOME%\bin\setenv.bat

set CMP_TARGET=12c
set MIG_CMD=%MIG_SCRIPT_DIR%\mig_generator.p2s
set LOGFILE=generator_%LOG_DATE%_%LOG_TIME%.log
if exist %MIG_TEST12_DIR%\compile.bat del /q %MIG_TEST12_DIR%\compile.bat

echo.
echo Call FormsAPIMaster running %MIG_CMD%
cmd /c call %FAM_EXE% /script /API=%FAM_API% /HOMES=%API_ORACLE_HOME% /RUN=%MIG_CMD% /LOG=%MIG_LOG_DIR%\%LOGFILE%

if exist %MIG_TEST12_DIR%\compile.bat echo %MIG_TEST12_DIR%\compile.bat generated

endlocal
