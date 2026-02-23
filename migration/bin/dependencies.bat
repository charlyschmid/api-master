@echo off
setlocal
echo.
echo Analyze Module Dependencies started %DATE% %TIME%

call %MIG_HOME%\bin\setenv.bat

set MIG_CMD=%MIG_SCRIPT_DIR%\mig_dependencies.p2s
set LOGFILE=dependencies_%LOG_DATE%_%LOG_TIME%.log
set API_ORACLE_HOME="D:\Dev6i\BIN"
set FAM_API=6i

echo.
echo Call FormsAPIMaster running %MIG_CMD%

cd /d %MIG_SOURCE_DIR%

call %FAM_EXE% /script /API=%FAM_API% /HOMES=%API_ORACLE_HOME% /RUN=%MIG_CMD% /LOG=%MIG_LOG_DIR%\%LOGFILE%

cd /d %MIG_HOME%

echo.
echo Analyze Module Dependencies finished %DATE% %TIME%

endlocal
