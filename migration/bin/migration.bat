@echo off
setlocal
echo.
echo Migration Run started %DATE% %TIME%

call %MIG_HOME%\bin\setenv.bat

rem -m --mode       migrate:all
rem migrate         default, use settings from config.ini
rem all             migrate all, sets copy=all, source=clean, target=clean

set MIG_MODE=migrate

:loop
if not "%1" == "" (
   if /i "%1" == "-m" (
      set MIG_MODE=%2
      shift
   )
   shift
   goto :loop
)

echo.
echo Settings
echo Mode    %MIG_MODE%

if /i "%MIG_MODE%" == "all" goto MIGRATE_ALL
if /i "%MIG_MODE%" == "migrate" goto MIGRATE_MIGRATE
goto MIGRATION_DONE

:MIGRATE_ALL
echo Migrate ALL

set MIG_OLB=1
set MIG_PLL=1
set MIG_MMB=1
set MIG_FMB=1
set MIG_REF=1
set MIG_RDF=1
set MIG_OLB_FILTER=*.olb
set MIG_PLL_FILTER=*.pll
set MIG_MMB_FILTER=*.mmb
set MIG_FMB_FILTER=*.fmb
set MIG_RDF_FILTER=*.rdf

goto MIGRATION_RUN

:MIGRATE_MIGRATE
echo Migrate with settings from config.ini

goto MIGRATION_RUN

:MIGRATION_RUN
set MIG_CMD=%MIG_SKRIPT_DIR%\mig_main.p2s
set LOGFILE=migration_%LOG_DATE%_%LOG_TIME%.log

echo.
echo delete runtime and error files in %MIG_TARGET_DIR%

if exist "%MIG_TARGET_DIR%\*.err" del %MIG_TARGET_DIR%\*.err
if exist "%MIG_TARGET_DIR%\*.log" del %MIG_TARGET_DIR%\*.err
if exist "%MIG_TARGET_DIR%\*.pld" del %MIG_TARGET_DIR%\*.pld
if exist "%MIG_TARGET_DIR%\*.mmt" del %MIG_TARGET_DIR%\*.pld
if exist "%MIG_TARGET_DIR%\*.fmt" del %MIG_TARGET_DIR%\*.pld
if exist "%MIG_TARGET_DIR%\*.rex" del %MIG_TARGET_DIR%\*.pld
if exist "%MIG_TARGET_DIR%\*.fmx" del %MIG_TARGET_DIR%\*.fmx
if exist "%MIG_TARGET_DIR%\*.plx" del %MIG_TARGET_DIR%\*.plx
if exist "%MIG_TARGET_DIR%\*.mmx" del %MIG_TARGET_DIR%\*.mmx
if exist "%MIG_TARGET_DIR%\*.rep" del %MIG_TARGET_DIR%\*.pld

echo.
echo Call FormsAPIMaster running %MIG_CMD%
echo using API     %FAM_API%
echo using HOMES   %API_ORACLE_HOME%

cd /d %MIG_SOURCE_DIR%

call %FAM_EXE% /script /API=%FAM_API% /HOMES=%API_ORACLE_HOME% /RUN=%MIG_CMD% /LOG=%MIG_LOG_DIR%\%LOGFILE%

cd /d %MIG_HOME%

:MIGRATION_DONE
echo.
echo Migration Run finished %DATE% %TIME%

endlocal
