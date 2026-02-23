@echo off
setlocal

echo.
echo Backup Directory 05reports including contents

call %MIG_HOME%\bin\setenv.bat

set MIG_NEW_DIR=%MIG_BACKUP_05REPORTS_DIR%_%LOG_DATE%_%LOG_TIME%

echo.
echo move %MIG_REPTARGET_DIR% to backup folder %MIG_NEW_DIR%
move %MIG_REPTARGET_DIR% %MIG_NEW_DIR%

echo.
echo create new target folder %MIG_REPTARGET_DIR%
mkdir %MIG_REPTARGET_DIR%

endlocal
