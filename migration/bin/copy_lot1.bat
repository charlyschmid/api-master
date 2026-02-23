rem Copy Lot1 to Migration Source Folder

@echo off
setlocal

call %MIG_HOME%\bin\setenv.bat

set SOURCE_FOLDER=Z:\Lot1
set TARGET_FOLDER=%MIG_HOME%\01source
set FILETYPES=*.olb *.fmb *.pll *.mmb *.res *.rdf
set TEMP_DIRS=%SOURCE_FOLDER%\temp.dirs
set TEMP_FILES=%SOURCE_FOLDER%\temp.files

echo -----------------------------------------------------------------
echo -- Copy %SOURCE_FOLDER% to %TARGET_FOLDER%
echo -----------------------------------------------------------------

cd /d %SOURCE_FOLDER%

echo create directory list %SOURCE_FOLDER%
dir /s /l /b /ad > %TEMP_DIRS%
copy /y %TEMP_DIRS% %MIG_LOT_DIR%\lot1.dirs

echo create file list %SOURCE_FOLDER%
dir /s /l /b /aa %FILETYPES% > %TEMP_FILES%
copy /y %TEMP_FILES% %MIG_LOT_DIR%\lot1.files

echo copy %SOURCE_FOLDER% to target folder %TARGET_FOLDER%
for /f "delims=" %%f in (%TEMP_FILES%) do (
xcopy "%%f" %TARGET_FOLDER% /f /y
)

cd /d %MIG_HOME%

endlocal
