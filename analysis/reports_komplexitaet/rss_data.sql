rem ------------------------------------------------------------------
rem  Trivadis Software Development
rem ------------------------------------------------------------------
rem  Project..........: Forms and Reports Analysis
rem  Script...........: rss_data.sql
rem  Developer........: Perry Pakull (PeP), perry.pakull@trivadis.com
rem  Date.............: 23.05.2014
rem  Version..........: 1.0.0
rem  Parameter........: -
rem  Output...........: -
rem  Description......: Inserting data reports_statistic_set
rem ------------------------------------------------------------------
rem  Version Date       Who      What
rem ------------------------------------------------------------------

prompt ***************************************************************
prompt Inserting data reports_statistic_set ...
prompt ***************************************************************

insert into reports_statistic_set (object_name, object_description, min_value, max_value, priority)
values ('ATTLIB','Attached Library',1,10,100);
insert into reports_statistic_set (object_name, object_description, min_value, max_value, priority)
values ('DATALINK','Data Link',1,10,100);
insert into reports_statistic_set (object_name, object_description, min_value, max_value, priority)
values ('QUERY','Query',1,10,100);
insert into reports_statistic_set (object_name, object_description, min_value, max_value, priority)
values ('GROUP','Group',1,10,100);
insert into reports_statistic_set (object_name, object_description, min_value, max_value, priority)
values ('GROUPCOL','Group Column',1,10,100);
insert into reports_statistic_set (object_name, object_description, min_value, max_value, priority)
values ('FMLCOL','Formula Column',1,10,100);
insert into reports_statistic_set (object_name, object_description, min_value, max_value, priority)
values ('PLCHCOL','Placeholder Column',1,10,100);
insert into reports_statistic_set (object_name, object_description, min_value, max_value, priority)
values ('SUMCOL','Summary Column',1,10,100);
insert into reports_statistic_set (object_name, object_description, min_value, max_value, priority)
values ('SYSPAR','System Parameter',1,10,100);
insert into reports_statistic_set (object_name, object_description, min_value, max_value, priority)
values ('USERPAR','User Parameter',1,10,100);
insert into reports_statistic_set (object_name, object_description, min_value, max_value, priority)
values ('PFBP','Parameter Form Boilerplate',1,10,100);
insert into reports_statistic_set (object_name, object_description, min_value, max_value, priority)
values ('PFFIELD','Parameter Form Field',1,10,100);
insert into reports_statistic_set (object_name, object_description, min_value, max_value, priority)
values ('ANCHOR','Anchor',1,10,100);
insert into reports_statistic_set (object_name, object_description, min_value, max_value, priority)
values ('BPTEXT','Boilerplate Text',1,10,100);
insert into reports_statistic_set (object_name, object_description, min_value, max_value, priority)
values ('BPGRAPH','Boilerplate Graphical Element',1,10,100);
insert into reports_statistic_set (object_name, object_description, min_value, max_value, priority)
values ('BPIMAGE','Boilerplate Image',1,10,100);
insert into reports_statistic_set (object_name, object_description, min_value, max_value, priority)
values ('BPLF','Boilerplate Link File',1,10,100);
insert into reports_statistic_set (object_name, object_description, min_value, max_value, priority)
values ('BPOLE','Boilerplate OLE',1,10,100);
insert into reports_statistic_set (object_name, object_description, min_value, max_value, priority)
values ('BUTTON','Button',1,10,100);
insert into reports_statistic_set (object_name, object_description, min_value, max_value, priority)
values ('CHART','Chart',1,10,100);
insert into reports_statistic_set (object_name, object_description, min_value, max_value, priority)
values ('FIELD','Field',1,10,100);
insert into reports_statistic_set (object_name, object_description, min_value, max_value, priority)
values ('STATFRAME','Frame Static',1,10,100);
insert into reports_statistic_set (object_name, object_description, min_value, max_value, priority)
values ('REPFRAME','Frame Repeating',1,10,100);
insert into reports_statistic_set (object_name, object_description, min_value, max_value, priority)
values ('UNPROC','User Named Procedure',1,10,100);
insert into reports_statistic_set (object_name, object_description, min_value, max_value, priority)
values ('FTRG','Format Trigger',1,10,100);
insert into reports_statistic_set (object_name, object_description, min_value, max_value, priority)
values ('RTRG','Report Trigger',1,10,100);
insert into reports_statistic_set (object_name, object_description, min_value, max_value, priority)
values ('PFTRG','Parameter Form Trigger',1,10,100);
insert into reports_statistic_set (object_name, object_description, min_value, max_value, priority)
values ('PVTRG','Parameter Validation Trigger',1,10,100);
insert into reports_statistic_set (object_name, object_description, min_value, max_value, priority)
values ('BUTRG','Button Trigger',1,10,100);
insert into reports_statistic_set (object_name, object_description, min_value, max_value, priority)
values ('REFCQFCT','Ref Cursor Query Function',1,10,100);
insert into reports_statistic_set (object_name, object_description, min_value, max_value, priority)
values ('FTRGFRAME','Format Trigger on Frame',1,10,100);
insert into reports_statistic_set (object_name, object_description, min_value, max_value, priority)
values ('FTRGFIELD','Format Trigger on Field',1,10,100);
insert into reports_statistic_set (object_name, object_description, min_value, max_value, priority)
values ('FTRGBP','Format Trigger on Boilerplate',1,10,100);
insert into reports_statistic_set (object_name, object_description, min_value, max_value, priority)
values ('STMTPLSQL','Statements PL/SQL',1,10,100);
insert into reports_statistic_set (object_name, object_description, min_value, max_value, priority)
values ('STMTSELECT','Statements SELECT',1,10,100);
insert into reports_statistic_set (object_name, object_description, min_value, max_value, priority)
values ('STMTINSERT','Statements INSERT',1,10,100);
insert into reports_statistic_set (object_name, object_description, min_value, max_value, priority)
values ('STMTUPDATE','Statements UPDATE',1,10,100);
insert into reports_statistic_set (object_name, object_description, min_value, max_value, priority)
values ('STMTDELETE','Statements DELETE',1,10,100);
insert into reports_statistic_set (object_name, object_description, min_value, max_value, priority)
values ('SRCLENALL','Source Length',1,10,100);
insert into reports_statistic_set (object_name, object_description, min_value, max_value, priority)
values ('SRCLENCODE','Source Length Code',1,10,100);
insert into reports_statistic_set (object_name, object_description, min_value, max_value, priority)
values ('SRCLENCOMMENTS','Source Length Comments',1,10,100);
insert into reports_statistic_set (object_name, object_description, min_value, max_value, priority)
values ('SRCLOC','Lines of Code including Comments',1,10,100);

commit;
