rem Migration Environment
set MIG_BIN_DIR=%MIG_HOME%\bin
set MIG_LOG_DIR=%MIG_HOME%\logs
set MIG_LIB_DIR=%MIG_HOME%\libfiles
set MIG_SCRIPT_DIR=%MIG_HOME%\scripts
set MIG_SOURCE_DIR=%MIG_HOME%\01source
set MIG_TARGET_DIR=%MIG_HOME%\04migrated
set MIG_REPTARGET_DIR=%MIG_HOME%\05reports
set MIG_TEST11_DIR=%MIG_HOME%\testmig
set MIG_TEST12_DIR=%MIG_HOME%\testmig12
set MIG_BACKUP_DIR=%MIG_HOME%\backup
set MIG_BACKUP_TESTMIG11_DIR=%MIG_HOME%\backup\testmig
set MIG_BACKUP_TESTMIG12_DIR=%MIG_HOME%\backup\testmig12
set MIG_BACKUP_04MIGRATED_DIR=%MIG_HOME%\backup\04migrated
set MIG_BACKUP_05REPORTS_DIR=%MIG_HOME%\backup\05reports
set MIG_LOT_DIR=%MIG_HOME%\lot
rem FormsAPIMaster Environment
set API_ORACLE_HOME="D:\Middleware\Oracle_FRHome1\BIN"
set FAM_API=11g
set FAM_EXE="C:\Program Files (x86)\ORCL Toolbox\FormsAPI Master V3.0\FapiMaster.exe"
set MIG_DBCONNECT=<dbuser>/<dbpwd>@<tns database>
rem Logging Environment
set LOG_DATE=%DATE:~6,4%%DATE:~3,2%%DATE:~0,2%
set LOG_HOUR1=%TIME:~0,1%
set LOG_HOUR2=%TIME:~1,1%
if "%LOG_HOUR1%" == " " set LOG_HOUR1=0
set LOG_TIME=%LOG_HOUR1%%LOG_HOUR2%%TIME:~3,2%
rem Environment
set LOT1_DIR=Z:\Lot1
set LOT2_DIR=Z:\Lot2
set LOT3_DIR=Z:\Lot3
set LOT4_DIR=Z:\Lot4
set DEPLOYMENT_DIR=D:\Deployment\Appl
rem Extensions
set PLL=.pll
set MMB=.mmb
set FMB=.FMB
set RDF=.rdf
set PLX=.plx
set MMX=.mmx
set FMX=.fmx
set REP=.rep
