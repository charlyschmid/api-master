@echo off
setlocal
echo.
echo Generate Compiler Commands for Forms 11g

call %MIG_HOME%\bin\setenv.bat

set CMP_TARGET=11g
set MIG_CMD=%MIG_SKRIPT_DIR%\mig_generator.p2s
set LOGFILE=generator_%LOG_DATE%_%LOG_TIME%.log

echo.
echo Call FormsAPIMaster running %MIG_CMD%
cmd /c call %FAM_EXE% /script /API=%FAM_API% /HOMES=%API_ORACLE_HOME% /RUN=%MIG_CMD% /LOG=%MIG_LOG_DIR%\%LOGFILE%

endlocal
