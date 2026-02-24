rem ------------------------------------------------------------------
rem  Trivadis Software Development
rem ------------------------------------------------------------------
rem  Project..........: Trivadis Forms and Reports Analysis
rem  Script...........: AnalyseReport.sql
rem  Developer........: Tobias Eidam (toe), tobias.eidam@trivadis.com
rem  Date.............: 09.02.2014
rem  Version..........: 1.0.0
rem  Parameter........: -
rem  Output...........: -
rem  Description......: Create the HTML analysis report
rem ------------------------------------------------------------------
rem  Date        Who  What
rem  09.02.2014  pep  Formatted
rem  13.02.2014  pep  set serveroutput on size unlimited
rem ------------------------------------------------------------------

set define on
set termout on

prompt
prompt ############################################
prompt #                                          #
prompt #          Auswertung der Analyse          #
prompt #                                          #
prompt ############################################
prompt

set heading off
set linesize 100
set pagesize 100
set trimspool on
set verify off
set echo off
set feedback off
set serveroutput on size unlimited

prompt
prompt Verzeichnis Auswertungsdateien
prompt
accept path char default 'report' prompt 'Verzeichnis Auswertungsdateien (Default: ''report''): '


@@script\reports_komplexitaet.sql report
@@script\reports_statistic.sql report
@@script\reports_komplexitaet_alle.sql report

set termout on

