rem ------------------------------------------------------------------
rem  Trivadis Software Development
rem ------------------------------------------------------------------
rem  Project..........: Forms and Reports Analysis
rem  Script...........: reports_statistic.sql
rem  Developer........: Perry Pakull (PeP), perry.pakull@trivadis.com
rem  Date.............: 23.05.2014
rem  Version..........: 1.0.0
rem  Parameter........: -
rem  Output...........: -
rem  Description......: Create table reports_statistic
rem ------------------------------------------------------------------
rem  Version Date       Who      What
rem ------------------------------------------------------------------

drop table reports_statistic cascade constraints;

create table reports_statistic (
rs_id                         number,
mod_mod_id                    number(8),
rss_rss_id                    number,
statistic_value               number(20),
creator                       varchar2(50),
creationdate                  date,
editor                        varchar2(50),
editdate                      date
);


prompt Comments table reports_statistic

comment on table  reports_statistic is 'Reports Statistics';
comment on column reports_statistic.rs_id is 'Primary Key from sequence reports_statistics_seq';
comment on column reports_statistic.mod_mod_id is 'Foreign Key reference on table module';
comment on column reports_statistic.rss_rss_id is 'Foreign Key reference on table reports_statistic_parameters';
comment on column reports_statistic.statistic_value is 'Statistic Value';
comment on column reports_statistic.creator is 'Row created by';
comment on column reports_statistic.creationdate is 'Row created on';
comment on column reports_statistic.editor is 'Row changed by';
comment on column reports_statistic.editdate is 'Row changed on';


prompt Creating constraints for table reports_statistic

alter table reports_statistic
   add constraint rs_pk primary key (rs_id) using index;

alter table reports_statistic
      add constraint rs_rss_fk foreign key (rss_rss_id) references reports_statistic_set (rss_id);


prompt Creating indexes for table reports_statistic

create index rs_rss_rss_id_idx on reports_statistic (rss_rss_id);
create index rs_mod_mod_id_idx on reports_statistic (mod_mod_id);


prompt Creating trigger for table reports_statistic

create or replace trigger rs_biur_trg
before insert or update on reports_statistic
referencing new as new old as old
for each row
begin
   if inserting then
      if :new.rs_id is null
      then
         :new.rs_id := reports_statistic_seq.nextval;
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
show errors trigger rs_biur_trg
