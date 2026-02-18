@echo off
setlocal

call %MIG_HOME%\bin\setenv.bat

echo.
echo copy new migrated files 
echo from %MIG_TARGET_DIR% 
echo to   %MIG_TEST11_DIR%
echo -----------------------------------------------------------------
echo.
echo copy pll files
if exist %MIG_TARGET_DIR%\*.pll xcopy %MIG_TARGET_DIR%\*.pll %MIG_TEST11_DIR% /D /Y /F

echo.
echo copy mmb files
if exist %MIG_TARGET_DIR%\*.mmb xcopy %MIG_TARGET_DIR%\*.mmb %MIG_TEST11_DIR% /D /Y /F

echo.
echo copy fmb files
if exist %MIG_TARGET_DIR%\*.fmb xcopy %MIG_TARGET_DIR%\*.fmb %MIG_TEST11_DIR% /D /Y /F

echo.
echo copy res files
if exist %MIG_TARGET_DIR%\*.res xcopy %MIG_TARGET_DIR%\*.res %MIG_TEST11_DIR% /D /Y /F

echo.
echo copy olb files
if exist %MIG_TARGET_DIR%\*.olb xcopy %MIG_TARGET_DIR%\*.olb %MIG_TEST11_DIR% /D /Y /F

echo.
echo copy rdf files
if exist %MIG_TARGET_DIR%\*.rdf xcopy %MIG_TARGET_DIR%\*.rdf %MIG_TEST11_DIR% /D /Y /F

endlocal
