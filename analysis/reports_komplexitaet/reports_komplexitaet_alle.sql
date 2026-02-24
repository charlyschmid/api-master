rem ------------------------------------------------------------------
rem  Trivadis Software Development
rem ------------------------------------------------------------------
rem  Project..........: Trivadis Forms and Reports Analysis
rem  Script...........: reports_komplexitaet_alle.sql
rem  Developer........: Perry Pakull (PeP), perry.pakull@trivadis.com
rem  Date.............: 02.06.2014
rem  Version..........: 1.0.0
rem  Parameter........: -
rem  Output...........: reports_komplexitaet_alle.htm
rem  Description......: Create file reports_komplexitaet_alle.htm
rem ------------------------------------------------------------------
rem  Date        Who  What
rem  09.02.2014  pep  Formatted
rem ------------------------------------------------------------------

define path='&1'
define schema='%'
define filename = &path/reports_komplexitaet_alle.htm

set termout on
prompt
prompt Erstelle reports_komplexitaet_alle.htm ...
prompt
set termout off

spool &filename

declare
   l_sep                          varchar2 (2) := db_report_output.g_separator;
   l_modul                        varchar2 (4000);
   --
   cursor c_module
   is
      select rc.mod_name, round (sum (rc.complexity), 2) complexity
        from reports_modul_complexity_view rc
      group by rc.mod_name
      order by rc.mod_name;
begin
   db_report_output.header (tvd_reports_information.header_text || ' - ' || to_char (sysdate, 'DD.MM.RRRR HH24:MI:SS'));
   db_report_output.title (tvd_reports_information.header_text);
   db_report_output.subtitle ('anzahl', 'Reports Komplexität Standard Übersicht');
   db_report_output.html_table_start;
   db_report_output.html_table_header ('Modul' || l_sep || 'Komplexität in Prozent');
   for c in c_module
   loop
      l_modul := 'mod_stat_' || lower (replace (c.mod_name, '.', '_')) || '.htm';
      db_report_output.html_table (db_report_output.get_link (l_modul, lower (c.mod_name)) || l_sep || c.complexity);
   end loop;
   db_report_output.html_table_end;
   db_report_output.text ('<br>');
   db_report_output.text ('<br>');
   db_report_output.abschluss;
end;
/

spool off

