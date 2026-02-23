@echo off
setlocal
echo.
echo Deployment GEFI started %DATE% %TIME%

call %MIG_HOME%\bin\setenv.bat

rem -d --deploy     clean:append
rem clean           default, delete all files in deployment directories before
rem append          append/overwrite files in deployment directory

set MIG_DEPLOY=clean

:loop
if not "%1" == "" (
   if /i "%1" == "-d" (
      set MIG_DEPLOY=%2
      shift
   )
   shift
   goto :loop
)

echo.
echo Settings
echo Deploy  %MIG_DEPLOY%

if /i "%MIG_DEPLOY%" == "clean" (
echo.
echo delete all files in directory %GEFI_DEPLOYMENT_DIR%
del %GEFI_DEPLOYMENT_DIR%\* /F /Q
)

echo.
echo deploy lot1
call %MIG_BIN_DIR%\deploy_lot1.bat > %MIG_LOG_DIR%\deploy_lot1.log

echo.
echo deploy lot2
call %MIG_BIN_DIR%\deploy_lot2.bat > %MIG_LOG_DIR%\deploy_lot2.log

echo.
echo deploy lot3
call %MIG_BIN_DIR%\deploy_lot3.bat > %MIG_LOG_DIR%\deploy_lot3.log

cd /d %MIG_HOME%

echo.
echo Deployment GEFI finished %DATE% %TIME%

endlocal
