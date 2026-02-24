rem ------------------------------------------------------------------
rem  Trivadis Software Development
rem ------------------------------------------------------------------
rem  Project..........: Forms and Reports Analysis
rem  Script...........: reports_statistic_set.sql
rem  Developer........: Perry Pakull (PeP), perry.pakull@trivadis.com
rem  Date.............: 23.05.2014
rem  Version..........: 1.0.0
rem  Parameter........: -
rem  Output...........: -
rem  Description......: Create table reports_statistic_set
rem ------------------------------------------------------------------
rem  Version Date       Who      What
rem ------------------------------------------------------------------

prompt ***************************************************************
prompt Creating table reports_statistic_set ...
prompt ***************************************************************

drop table reports_statistic_set cascade constraints;

create table reports_statistic_set (
rss_id                        number,
object_name                   varchar2(30)                  constraint rss_object_name_nn not null,
object_description            varchar2(50)                  constraint rss_object_description_nn not null,
min_value                     number(20)       default 0    constraint rss_min_value_nn not null,
max_value                     number(20)       default 0    constraint rss_max_value_nn not null,
priority                      number(4)        default 0    constraint rss_priority_nn not null,
creator                       varchar2(50),
creationdate                  date,
editor                        varchar2(50),
editdate                      date
);


prompt Comments table reports_statistic_set

comment on table  reports_statistic_set is 'Reports Statistic Parameters';
comment on column reports_statistic_set.rss_id is 'Primary Key from sequence reports_statistic_set_seq';
comment on column reports_statistic_set.object_name is 'Object Name';
comment on column reports_statistic_set.object_description is 'Object Description';
comment on column reports_statistic_set.min_value is 'Min Value';
comment on column reports_statistic_set.max_value is 'Max Value';
comment on column reports_statistic_set.priority is 'Priority';
comment on column reports_statistic_set.creator is 'Row created by';
comment on column reports_statistic_set.creationdate is 'Row created on';
comment on column reports_statistic_set.editor is 'Row changed by';
comment on column reports_statistic_set.editdate is 'Row changed on';


prompt Creating constraints for table reports_statistic_set

alter table reports_statistic_set
   add constraint rss_pk primary key (rss_id) using index;

alter table reports_statistic_set
   add constraint rss_object_name_uk unique (object_name) using index;


prompt Creating indexes for table reports_statistic_set


prompt Creating trigger for table reports_statistic_set

create or replace trigger rss_biur_trg
before insert or update on reports_statistic_set
referencing new as new old as old
for each row
begin
   if inserting then
      if :new.rss_id is null
      then
         :new.rss_id := reports_statistic_set_seq.nextval;
      end if;
      :new.creator := user;
      :new.creationdate := sysdate;
   end if;
   if inserting or updating
   then
      :new.editor := user;
      :new.editdate := sysdate;
   end if;
end;
/
show errors trigger rss_biur_trg
