@echo off
setlocal

echo.
echo Backup Directory testmig including contents

call %MIG_HOME%\bin\setenv.bat
set MIG_NEW_DIR=%MIG_BACKUP_TESTMIG11_DIR%_%LOG_DATE%_%LOG_TIME%

echo.
echo move %MIG_TEST11_DIR% to backup folder %MIG_NEW_DIR%
move %MIG_TEST11_DIR% %MIG_NEW_DIR%

echo.
echo create new target folder %MIG_TEST11_DIR%
mkdir %MIG_TEST11_DIR%

endlocal
