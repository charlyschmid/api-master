@echo off
setlocal

call %MIG_HOME%\bin\setenv.bat

echo.
echo copy from %MIG_TARGET_DIR% to %MIG_TEST12_DIR%

echo.
echo copy pll files
if exist %MIG_TARGET_DIR%\*.pll xcopy %MIG_TARGET_DIR%\*.pll %MIG_TEST12_DIR% /D /Y /Q

echo.
echo copy mmb files
if exist %MIG_TARGET_DIR%\*.mmb xcopy %MIG_TARGET_DIR%\*.mmb %MIG_TEST12_DIR% /D /Y /Q

echo.
echo copy fmb files
if exist %MIG_TARGET_DIR%\*.fmb xcopy %MIG_TARGET_DIR%\*.fmb %MIG_TEST12_DIR% /D /Y /Q

echo.
echo copy res files
if exist %MIG_TARGET_DIR%\*.res xcopy %MIG_TARGET_DIR%\*.res %MIG_TEST12_DIR% /D /Y /Q

echo.
echo copy olb files
if exist %MIG_TARGET_DIR%\*.olb xcopy %MIG_TARGET_DIR%\*.olb %MIG_TEST12_DIR% /D /Y /Q

echo.
echo copy from %MIG_REPTARGET_DIR% to %MIG_TEST12_DIR%

echo.
echo copy pll files
if exist %MIG_REPTARGET_DIR%\*.pll xcopy %MIG_REPTARGET_DIR%\*.pll %MIG_TEST12_DIR% /D /Y /Q

echo.
echo copy rdf files
if exist %MIG_REPTARGET_DIR%\*.rdf xcopy %MIG_REPTARGET_DIR%\*.rdf %MIG_TEST12_DIR% /D /Y /Q

endlocal
