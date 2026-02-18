@echo off
setlocal
echo.
echo Copy Files to Source Directory started %DATE% %TIME%

call %MIG_HOME%\bin\setenv.bat

rem -c --copy       all:lot1:lot2:lot3
rem all             default, copy all files to source directory
rem lot<n>          copy files from lot<n>-directory to source directory

rem -s --source     clean:append
rem clean           default, delete all files in source directory before copy
rem append          copy to source directory, do not delete before

set MIG_COPY=all
set MIG_SOURCE=clean

:loop
if not "%1" == "" (
   if /i "%1" == "-c" (
      set MIG_COPY=%2
      shift
   )
   if /i "%1" == "-s" (
      set MIG_SOURCE=%2
      shift
   )
   shift
   goto :loop
)

echo.
echo Settings
echo Copy    %MIG_COPY%
echo Source  %MIG_SOURCE%

set COPY_LOT1=true
set COPY_LOT2=true
set COPY_LOT3=true

if /i "%MIG_COPY%" == "lot1" (
set COPY_LOT1=true
set COPY_LOT2=false
set COPY_LOT3=false
)

if /i "%MIG_COPY%" == "lot2" (
set COPY_LOT1=false
set COPY_LOT2=true
set COPY_LOT3=false
)

if /i "%MIG_COPY%" == "lot3" (
set COPY_LOT1=false
set COPY_LOT2=false
set COPY_LOT3=true
)

if /i "%MIG_SOURCE%" == "clean" (
echo.
echo delete all files in directory %MIG_SOURCE_DIR%
del %MIG_SOURCE_DIR%\* /F /Q
)

if "%COPY_LOT1%" == "true" (
echo.
echo copy lot1
call %MIG_BIN_DIR%\copy_lot1.bat > %MIG_LOG_DIR%\copy_lot1.log
)

if "%COPY_LOT2%" == "true" (
echo.
echo copy lot2
call %MIG_BIN_DIR%\copy_lot2.bat > %MIG_LOG_DIR%\copy_lot2.log
)

if "%COPY_LOT3%" == "true" (
echo.
echo copy lot3
call %MIG_BIN_DIR%\copy_lot3.bat > %MIG_LOG_DIR%\copy_lot3.log
)

cd /d %MIG_HOME%

echo.
echo Copy All Source Files finished %DATE% %TIME%

endlocal
