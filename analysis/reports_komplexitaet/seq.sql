rem ------------------------------------------------------------------
rem  Trivadis Software Development
rem ------------------------------------------------------------------
rem  Project..........: Forms and Reports Analysis
rem  Script...........: seq.sql
rem  Developer........: Perry Pakull (PeP), perry.pakull@trivadis.com
rem  Date.............: 02.06.2014
rem  Version..........: 1.0.0
rem  Parameter........: -
rem  Output...........: -
rem  Description......: Create sequence objects for reports complexity
rem ------------------------------------------------------------------
rem  Version Date       Who      What
rem ------------------------------------------------------------------

drop sequence reports_statistic_set_seq;
drop sequence reports_statistic_seq;
create sequence reports_statistic_set_seq start with 1 increment by 1 nocache noorder nocycle;
create sequence reports_statistic_seq start with 1 increment by 1 nocache noorder nocycle;
