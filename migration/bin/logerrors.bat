@echo off
setlocal
echo.
echo Log Compiler Errors Forms 12c

call %MIG_HOME%\bin\setenv.bat

set MIG_CMD=%MIG_SCRIPT_DIR%\mig_errors.p2s
set LOGFILE=errors_%LOG_DATE%_%LOG_TIME%.log

echo.
echo Call FormsAPIMaster running %MIG_CMD%
cmd /c call %FAM_EXE% /script /API=%FAM_API% /HOMES=%API_ORACLE_HOME% /RUN=%MIG_CMD% /LOG=%MIG_LOG_DIR%\%LOGFILE%

if exist %MIG_LOG_DIR%\compile_summary.log echo %MIG_LOG_DIR%\compile_summary.log created
if exist %MIG_LOG_DIR%\compile_errors.log echo %MIG_LOG_DIR%\compile_errors.log created

endlocal
