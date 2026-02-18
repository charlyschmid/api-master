@echo off
setlocal

echo.
echo Backup Directory testmig12 including contents

call %MIG_HOME%\bin\setenv.bat
set MIG_NEW_DIR=%MIG_BACKUP_TESTMIG12_DIR%_%LOG_DATE%_%LOG_TIME%

echo.
echo move %MIG_TEST12_DIR% to backup folder %MIG_NEW_DIR%
move %MIG_TEST12_DIR% %MIG_NEW_DIR%

echo.
echo create new target folder %MIG_TEST12_DIR%
mkdir %MIG_TEST12_DIR%

endlocal
