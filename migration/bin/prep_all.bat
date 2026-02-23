@echo off
setlocal
echo.
echo Prepare All started %DATE% %TIME%

call %MIG_HOME%\bin\setenv.bat

rem -m --mode       migrate:all
rem migrate         default, use settings from config.ini
rem all             migrate all, sets copy=all, source=clean, target=clean

rem -t --target     clean:append        clean
rem clean           default, delete all files in target directories before migrate
rem append          append/overwrite files in target directory

set MIG_MODE=migrate
set MIG_TARGET=clean

:loop
if not "%1" == "" (
   if /i "%1" == "-m" (
      set MIG_MODE=%2
      shift
   )
   if /i "%1" == "-t" (
      set MIG_TARGET=%2
      shift
   )
   shift
   goto :loop
)

echo.
echo Settings
echo Mode    %MIG_MODE%
echo Target  %MIG_TARGET%

if /i "%MIG_MODE%" == "all" (
echo.
echo backup 04migrated
call %MIG_BIN_DIR%\backup_04migrated.bat > %MIG_LOG_DIR%\backup_04migrated.log
)

if /i "%MIG_MODE%" == "all" (
echo.
echo backup 05reports
call %MIG_BIN_DIR%\backup_05reports.bat > %MIG_LOG_DIR%\backup_05reports.log
)

if /i "%MIG_MODE%" == "all" (
echo.
echo backup testmig
call %MIG_BIN_DIR%\backup_testmig.bat > %MIG_LOG_DIR%\backup_testmig.log
)

if /i "%MIG_MODE%" == "all" (
echo.
echo backup testmig12
call %MIG_BIN_DIR%\backup_testmig12.bat > %MIG_LOG_DIR%\backup_testmig12.log
)

echo.
echo prepare migration
call %MIG_BIN_DIR%\prep_migration.bat -t=%MIG_TARGET%> %MIG_LOG_DIR%\prep_migration.log

cd /d %MIG_HOME%

echo.
echo Prepare All finished %DATE% %TIME%

endlocal
