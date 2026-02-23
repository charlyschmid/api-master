@echo off
setlocal
echo.
echo Tester started %DATE% %TIME%

call %MIG_HOME%\bin\setenv.bat

set MIG_CMD=%MIG_SCRIPT_DIR%\tester.p2s
set LOGFILE=tester_%LOG_DATE%_%LOG_TIME%.log

echo.
echo Call FormsAPIMaster running %MIG_CMD%

cd /d %MIG_SOURCE_DIR%

call %FAM_EXE% /script /API=%FAM_API% /HOMES=%API_ORACLE_HOME% /RUN=%MIG_CMD% /LOG=%MIG_LOG_DIR%\%LOGFILE%

cd /d %MIG_HOME%

echo.
echo Tester finished %DATE% %TIME%

endlocal

