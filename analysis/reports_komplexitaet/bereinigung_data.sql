rem ------------------------------------------------------------------
rem  Trivadis Software Development
rem ------------------------------------------------------------------
rem  Project..........: Forms and Reports Analysis
rem  Script...........: bereinigung_data.sql
rem  Developer........: Perry Pakull (PeP), perry.pakull@trivadis.com
rem  Date.............: 02.06.2014
rem  Version..........: 1.0.0
rem  Parameter........: -
rem  Output...........: -
rem  Description......: Additional Statements clearing Repository
rem                     for Reports Statistics and Complexity
rem ------------------------------------------------------------------
rem  Version Date       Who      What
rem ------------------------------------------------------------------

delete bereinigung where folge >= 400;

insert into bereinigung (folge, statement) values(400, 'drop sequence reports_statistic_set_seq');
insert into bereinigung (folge, statement) values(410, 'drop sequence reports_statistic_seq');
insert into bereinigung (folge, statement) values(420, 'create sequence reports_statistic_set_seq start with 1 increment by 1 nocache noorder nocycle');
insert into bereinigung (folge, statement) values(430, 'create sequence reports_statistic_seq start with 1 increment by 1 nocache noorder nocycle');
insert into bereinigung (folge, statement) values(440, 'truncate table reports_statistic');

commit;
