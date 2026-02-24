set Path=c:\oracle\product\11.1.0\db_1\bin;C:\WINDOWS\system32;C:\WINDOWS;C:\WINDOWS\System32\Wbem
set ORACLE_SID=orcl
set ORACLE_HOME=c:\oracle\product\11.1.0\db_1

del /Q %1%
del /Q report
del /Q script
xcopy vorlage script

