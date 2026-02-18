@ECHO off
setlocal
echo.
echo Migrate All started %DATE% %TIME%

set MIG_BIN=%MIG_HOME%\bin

call %MIG_BIN%\01_copy_all.bat
call %MIG_BIN%\02_prep_all.bat

echo.
echo Migrate PLL Files
set mig_pll=1
set mig_mmb=0
set mig_fmb=0
set mig_pll_filter=*.pll
set mig_mmb_filter=*.mmb
set mig_fmb_filter=*.fmb
call %MIG_BIN%\migration.bat

echo.
echo Migrate MMB Files
set mig_pll=0
set mig_mmb=1
set mig_fmb=0
set mig_pll_filter=*.pll
set mig_mmb_filter=*.mmb
set mig_fmb_filter=*.fmb
call %MIG_BIN%\migration.bat

echo.
echo Migrate FMB Files
set mig_pll=0
set mig_mmb=0
set mig_fmb=1
set mig_pll_filter=*.pll
set mig_mmb_filter=*.mmb

set mig_fmb_filter=ofistd45.fmb
call %MIG_BIN%\migration.bat

set mig_fmb_filter=ofistd60.fmb
call %MIG_BIN%\migration.bat



echo.
echo Migrate All finished %DATE% %TIME%

endlocal
