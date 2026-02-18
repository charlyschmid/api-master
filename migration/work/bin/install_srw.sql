REM
REM  Perry Pakull, Trivadis AG
REM  
REM
REM  NAME
REM   install_srw.sql
REM  DESCRIPTION
REM   Installing the event-based reporting API
REM
REM HISTORY
REM Date     | Done by     | Task
REM ---------+-------------+--------------------------------------------------
REM 09-08-18 | PEP         | customized from rwapiins.sql
REM

set pagesize 1000
set linesize 256
col global_name format a30
col Connect format a50

spool install_srw.log

prompt =====================================================
prompt INSTALL REPORTS SRW PACKAGE
prompt =====================================================
prompt Log in install_srw.log
prompt

prompt ... using connection
select user || ' connected at ' || global_name as "Connect" from global_name;

prompt ... installing custom datatypes
@srwtype.sql

prompt ... D O N E - installing custom datatypes
prompt
prompt
prompt ... installing package SRW

@srwcre.sql
@srwcre_wrap.plb

prompt
prompt ... D O N E - installing package REPORTS
prompt
prompt

spool off

exit
