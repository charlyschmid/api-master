@echo off
setlocal
echo Compile Reports started %DATE% %TIME%

set MIG_TEST=%MIG_HOME%\testmig
set FORMS_PATH=%MIG_TEST%
set REPORTS_PATH=%MIG_TEST%

set repcmp=E:\oracle\product\Middleware11gR2\Oracle_FRHome1\BIN\rwconverter.exe
set db_connect=winstd/winstd@f11mig

cd /d %MIG_TEST%

echo -----------------------------------------------------------------
echo Delete old runtime files
echo -----------------------------------------------------------------
if exist *.rep del /f /q *.rep
if exist logrdf rmdir logrdf /s /q
mkdir logrdf

echo -----------------------------------------------------------------
echo Compile Reports
echo -----------------------------------------------------------------

for %%f in (*.rdf) do %repcmp% userid=%db_connect% stype=RDFFILE source=%%f dtype=REPFILE dest=%%f logfile=%%f.log overwrite=YES batch=YES

move *.log logrdf

cd /d %MIG_HOME%

echo Compile Reports finished %DATE% %TIME%
endlocal
echo on
