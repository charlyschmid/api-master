@echo off
setlocal
echo.
echo Prepare Migration started %DATE% %TIME%

call %MIG_HOME%\bin\setenv.bat

rem -t --target     clean:append        clean
rem clean           default, delete all files in target directories before migrate
rem append          append/overwrite files in target directory

set MIG_TARGET=clean

:loop
if not "%1" == "" (
   if /i "%1" == "-t" (
      set MIG_TARGET=%2
      shift
   )
   shift
   goto :loop
)

echo.
echo Settings
echo Target  %MIG_TARGET%

if /i "%MIG_TARGET%" == "clean" (
echo.
echo delete all files in directory %MIG_TARGET_DIR%
del %MIG_TARGET_DIR%\* /F /Q
)

echo.
echo copy lib files to %MIG_TARGET_DIR%
xcopy %MIG_LIB_DIR%\*.* %MIG_TARGET_DIR% /Y /Q

echo.
echo copy resource files to %MIG_TARGET_DIR%
if exist %MIG_SOURCE_DIR%\*.res xcopy %MIG_SOURCE_DIR%\*.res %MIG_TARGET_DIR% /Y /Q

echo.
echo Prepare Migration finished %DATE% %TIME%

endlocal
