@echo off
setlocal

set MIG_BIN=%MIG_HOME%\bin
set ORACLE_HOME=E:\oracle\product\Middleware11gR2\Oracle_FRHome1
set SQLPATH=%MIG_HOME%\bin;%ORACLE_HOME%\reports\admin\sql

echo.
echo Install Reports SRW Package
%ORACLE_HOME%\bin\sqlplus winstd/winstd@f11mig @install_srw.sql

endlocal
echo on
