@echo off
setlocal

echo.
echo Backup Directory 04migrated including contents

call %MIG_HOME%\bin\setenv.bat
set MIG_NEW_DIR=%MIG_BACKUP_04MIGRATED_DIR%_%LOG_DATE%_%LOG_TIME%

echo.
echo move %MIG_TARGET_DIR% to backup folder %MIG_NEW_DIR%
move %MIG_TARGET_DIR% %MIG_NEW_DIR%

echo.
echo create new target folder %MIG_TARGET_DIR%
mkdir %MIG_TARGET_DIR%

endlocal
