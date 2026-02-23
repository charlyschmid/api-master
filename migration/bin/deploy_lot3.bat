rem Deployment Files Lot3

@echo off
setlocal

call %MIG_HOME%\bin\setenv.bat
set GEFI_LOT_DIR=%GEFI_LOT3_DIR%
set TEMP_FILES=%GEFI_LOT_DIR%\temp.files
set TEMP_DIRS=%GEFI_LOT_DIR%\temp.dirs

echo -----------------------------------------------------------------
echo -- Deployment GEFI %GEFI_LOT_DIR% to %GEFI_DEPLOYMENT_DIR%
echo -----------------------------------------------------------------

echo.
echo Create Directories in %GEFI_DEPLOYMENT_DIR%
echo.

for /F "delims=" %%f in (%TEMP_DIRS%) do (
set "line=%%f"
set "sx=%%~nxf"
setlocal ENABLEDELAYEDEXPANSION 
set "st=!line:%GEFI_LOT_DIR%=%GEFI_DEPLOYMENT_DIR%!"
if not exist "!st!" echo create "!st!"
if not exist "!st!" mkdir "!st!"
endlocal
)

echo.
echo Copy files to %GEFI_DEPLOYMENT_DIR%
echo.

for /F "delims=" %%f in (%TEMP_FILES%) do (
set "line=%%f"
set "file=%%~nxf"
set "ext=%%~xf"
setlocal ENABLEDELAYEDEXPANSION 
set "destfile=!line:%GEFI_LOT_DIR%=%GEFI_DEPLOYMENT_DIR%!"
xcopy "%MIG_TEST12_DIR%\!file!" "!destfile!"* /y /f
if /i "!ext!" == "%PLL%" set "xline=!line:%PLL%=%PLX%!"
if /i "!ext!" == "%MMB%" set "xline=!line:%MMB%=%MMX%!"
if /i "!ext!" == "%FMB%" set "xline=!line:%FMB%=%FMX%!"
if /i "!ext!" == "%RDF%" set "xline=!line:%RDF%=%REP%!"
if /i "!ext!" == "%PLL%" set "xfile=!file:%PLL%=%PLX%!"
if /i "!ext!" == "%MMB%" set "xfile=!file:%MMB%=%MMX%!"
if /i "!ext!" == "%FMB%" set "xfile=!file:%FMB%=%FMX%!"
if /i "!ext!" == "%RDF%" set "xfile=!file:%RDF%=%REP%!"
if not "!xfile!" == "" set "destxfile=!xline:%GEFI_LOT_DIR%=%GEFI_DEPLOYMENT_DIR%!"
if not "!destxfile!" == "" xcopy "%MIG_TEST12_DIR%\!xfile!" "!destxfile!"* /y /f
endlocal
)

echo.
echo Copy PL/SQL Libraries (PLL) to %GEFI_DEPLOYMENT_DIR%\gefi\pll
echo.
xcopy %MIG_TEST12_DIR%\*.pll %GEFI_DEPLOYMENT_DIR%\gefi\pll\* /y /f

echo.
echo Copy PL/SQL Libraries (PLX) to %GEFI_DEPLOYMENT_DIR%\gefi\pll
echo.
xcopy %MIG_TEST12_DIR%\*.plx %GEFI_DEPLOYMENT_DIR%\gefi\pll\* /y /f

echo.
echo Copy Object Libraries to %GEFI_DEPLOYMENT_DIR%\gefi\std
echo.
xcopy %MIG_TEST12_DIR%\*.olb %GEFI_DEPLOYMENT_DIR%\gefi\std\* /y /f

endlocal
