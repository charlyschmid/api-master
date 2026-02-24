rem ------------------------------------------------------------------
rem  Trivadis Software Development
rem ------------------------------------------------------------------
rem  Project..........: Forms and Reports Analysis
rem  Script...........: views.sql
rem  Developer........: Perry Pakull (PeP), perry.pakull@trivadis.com
rem  Date.............: 02.06.2014
rem  Version..........: 1.0.0
rem  Parameter........: -
rem  Output...........: -
rem  Description......: Create view objects for reports complexity
rem ------------------------------------------------------------------
rem  Version Date       Who      What
rem ------------------------------------------------------------------

create or replace view reports_statistic_matrix_view
as
select mods.mod_id,
       mods.mod_name,
       mods.mod_maske,
       rss.rss_id,
       rss.object_name,
       rss.object_description,
       rss.min_value,
       rss.max_value,
       rss.priority,
       sumrp.sum_rs_priority,
       rss.priority / sumrp.sum_rs_priority prio_factor
  from module mods,
       reports_statistic_set rss,
       (select sum (sum_rss.priority) sum_rs_priority
          from reports_statistic_set sum_rss) sumrp
 where mods.mod_typ = 'RDF'
;

create or replace view reports_statistic_set_view
as
select rss.rss_id,
       rss.object_name,
       rss.object_description,
       rss.min_value,
       rss.max_value,
       rss.priority,
       round (avg (rs.statistic_value), 1) avg,
       round (max (rs.statistic_value), 1) max,
       round (sum (rs.statistic_value), 1) sum
  from reports_statistic_set rss, reports_statistic rs
 where rs.rss_rss_id = rss.rss_id
group by rss.rss_id, rss.object_name, rss.object_description, rss.min_value, rss.max_value, rss.priority
;

create or replace view reports_modul_complexity_view
as
select rsm.mod_id,
       rsm.mod_name,
       rsm.mod_maske,
       rsm.rss_id,
       rsm.object_name,
       rsm.object_description,
       rsm.min_value,
       rsm.max_value,
       rsm.priority,
       rsm.sum_rs_priority,
       rsm.prio_factor,
       nvl (rs.statistic_value, 0) statistic_value,
       case
          when nvl (rs.statistic_value, 0) > rsm.max_value then 100 * rsm.prio_factor
          else ( (nvl (rs.statistic_value, 0) * 100) / rsm.max_value) * rsm.prio_factor
       end
          complexity
  from reports_statistic_matrix_view rsm, reports_statistic rs
 where rs.mod_mod_id(+) = rsm.mod_id
   and rs.rss_rss_id(+) = rsm.rss_id
;

create or replace view reports_complexity_distrib
as
with modul_complexity as (select rc.mod_id, round (sum (rc.complexity), 1) complexity
                            from reports_modul_complexity_view rc
                          group by rc.mod_id)
select 10 percentage, count (1) modulcount
  from modul_complexity
 where complexity < 10
union all
select 20 percentage, count (1) modulcount
  from modul_complexity
 where complexity between 10 and 20
union all
select 30 percentage, count (1) modulcount
  from modul_complexity
 where complexity between 20 and 30
union all
select 40 percentage, count (1) modulcount
  from modul_complexity
 where complexity between 30 and 40
union all
select 50 percentage, count (1) modulcount
  from modul_complexity
 where complexity between 40 and 50
union all
select 60 percentage, count (1) modulcount
  from modul_complexity
 where complexity between 50 and 60
union all
select 70 percentage, count (1) modulcount
  from modul_complexity
 where complexity between 60 and 70
union all
select 80 percentage, count (1) modulcount
  from modul_complexity
 where complexity between 70 and 80
union all
select 90 percentage, count (1) modulcount
  from modul_complexity
 where complexity between 80 and 90
union all
select 100 percentage, count (1) modulcount
  from modul_complexity
 where complexity between 90 and 100
;


create or replace view reports_statistic_app_view
as
select rss.rss_id, rss.object_name, rss.object_description, sum (nvl (rs.statistic_value, 0)) sum_statistic
  from reports_statistic_set rss, reports_statistic rs
 where rs.rss_rss_id(+) = rss.rss_id
group by rss.rss_id, rss.object_name, rss.object_description
;

