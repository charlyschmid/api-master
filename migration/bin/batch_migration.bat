@echo off
setlocal
echo.
echo -----------------------------------------------------------------
echo Batch Migration started %DATE% %TIME%
echo -----------------------------------------------------------------

call %MIG_HOME%\bin\setenv.bat

rem -m --mode       migrate:all
rem migrate         default, use settings from config.ini
rem all             migrate all, sets copy=all, source=clean, target=clean

rem -c --copy       all:lot1:lot2:lot3
rem all             default, copy all files to source directory
rem lot<n>          copy files from lot<n>-directory to source directory

rem -s --source     clean:append
rem clean           default, delete all files in source directory before
rem append          copy to source directory, do not delete before

rem -t --target     clean:append
rem clean           default, delete all files in target directories before
rem append          append/overwrite files in target directory

rem -d --deploy     clean:append
rem clean           default, delete all files in deployment directories before
rem append          append/overwrite files in deployment directory

set MIG_MODE=migrate
set MIG_COPY=all
set MIG_SOURCE=clean
set MIG_TARGET=clean
set MIG_DEPLOY=clean

:loop
if not "%1" == "" (
   if /i "%1" == "-m" (
      set MIG_MODE=%2
      shift
   )
   if /i "%1" == "-c" (
      set MIG_COPY=%2
      shift
   )
   if /i "%1" == "-s" (
      set MIG_SOURCE=%2
      shift
   )
   if /i "%1" == "-t" (
      set MIG_TARGET=%2
      shift
   )
   if /i "%1" == "-d" (
      set MIG_DEPLOY=%2
      shift
   )
   shift
   goto :loop
)

echo.
echo Settings
echo Mode    %MIG_MODE%
echo Copy    %MIG_COPY%
echo Source  %MIG_SOURCE%
echo Target  %MIG_TARGET%
echo Deploy  %MIG_DEPLOY%

if /i "%MIG_MODE%" == "all" (
echo.
echo Delete Log Files
echo -----------------------------------------------------------------
echo delete all files in directory %MIG_LOG_DIR%
del %MIG_LOG_DIR%\* /F /Q
)

echo.
echo Copy Source Files
echo -----------------------------------------------------------------
call %MIG_BIN_DIR%\copy_all.bat -c=%MIG_COPY% -s=%MIG_SOURCE%

echo.
echo Prepare Migration Setup
echo -----------------------------------------------------------------
call %MIG_BIN_DIR%\prep_all.bat -m=%MIG_MODE% -t=%MIG_TARGET%

echo.
echo Migrate Source Files
echo -----------------------------------------------------------------
call %MIG_BIN_DIR%\migration.bat -m=%MIG_MODE%

echo.
echo Copy Migrated Files to Test-Directory
echo -----------------------------------------------------------------
call %MIG_BIN_DIR%\copy2testmig12.bat

echo.
echo Generate Compiler Script
echo -----------------------------------------------------------------
call %MIG_BIN_DIR%\compiler12c.bat

echo.
echo Compile Files in Test-Directory
echo -----------------------------------------------------------------
call %MIG_TEST12_DIR%\compile.bat

echo.
echo Log Compiler Errors
echo -----------------------------------------------------------------
call %MIG_BIN_DIR%\logerrors.bat

echo.
echo Deployment
echo -----------------------------------------------------------------
call %MIG_BIN_DIR%\deploy_all.bat -d=%MIG_DEPLOY%

echo.
echo -----------------------------------------------------------------
echo Batch Migration finished %DATE% %TIME%
echo -----------------------------------------------------------------

endlocal
