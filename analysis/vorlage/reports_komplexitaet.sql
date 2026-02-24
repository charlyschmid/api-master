rem ------------------------------------------------------------------
rem  Trivadis Software Development
rem ------------------------------------------------------------------
rem  Project..........: Trivadis Forms and Reports Analysis
rem  Script...........: reports_komplexitaet.sql
rem  Developer........: Perry Pakull (PeP), perry.pakull@trivadis.com
rem  Date.............: 02.06.2014
rem  Version..........: 1.0.0
rem  Parameter........: -
rem  Output...........: reports_komplexitaet.htm
rem  Description......: Create file reports_komplexitaet.htm
rem ------------------------------------------------------------------
rem  Date        Who  What
rem  09.02.2014  pep  Formatted
rem ------------------------------------------------------------------

define path='&1'
define schema='%'
define filename = &path/reports_komplexitaet.htm
define mod_statistic  = script\reports_statistic.sql

set termout on
prompt
prompt Erstelle reports_komplexitaet.htm ...
prompt
set termout off

spool &filename

declare
   l_sep                          varchar2 (2) := db_report_output.g_separator;
   l_counter                      number (5);
   l_gesamt_komp                  number (6) := tvd_reports_information.get_complex_value_application;
   l_modul                        varchar2 (4000);
   l_html                         varchar2 (4000);
   l_srclenall                    reports_statistic.statistic_value%type;
   l_srclencode                   reports_statistic.statistic_value%type;
   l_srclencomments               reports_statistic.statistic_value%type;
   l_srclencode_pct               number (20);
   l_srclencomments_pct           number (20);
   --
   l_stmtplsql                    reports_statistic.statistic_value%type;
   l_stmtselect                   reports_statistic.statistic_value%type;
   l_stmtinsert                   reports_statistic.statistic_value%type;
   l_stmtupdate                   reports_statistic.statistic_value%type;
   l_stmtdelete                   reports_statistic.statistic_value%type;
   l_stmtread                     reports_statistic.statistic_value%type;
   l_stmtwrite                    reports_statistic.statistic_value%type;
   l_stmtread_pct                 number (20);
   l_stmtwrite_pct                number (20);
   l_stmt_pct                     number (20);
   --
   l_statframes                   reports_statistic.statistic_value%type;
   l_repframes                    reports_statistic.statistic_value%type;
   l_frames                       reports_statistic.statistic_value%type;
   l_statframes_pct               number (20);
   l_repframes_pct                number (20);
   --
   type appvalues_array is table of reports_statistic_app_view.sum_statistic%type
                              index by varchar2 (50);
   t_appvalues                    appvalues_array;
   --
   cursor c_module
   is
      select rc.mod_id, rc.mod_name, rc.mod_maske, round (sum (rc.complexity), 2) complexity
        from reports_modul_complexity_view rc
      group by rc.mod_id, rc.mod_name, rc.mod_maske
      order by complexity desc;
   --
   cursor c_komp
   is
      select rcd.percentage, rcd.modulcount
        from reports_complexity_distrib rcd
      order by rcd.percentage;
   --
   cursor c_set
   is
      select rss.rss_id,
             rss.object_name,
             rss.object_description,
             rss.min_value,
             rss.max_value,
             rss.priority,
             rss.avg,
             rss.max,
             rss.sum
        from reports_statistic_set_view rss
      order by rss.rss_id;
begin
   for r_app in (select * from reports_statistic_app_view)
   loop
      t_appvalues (r_app.object_name) := r_app.sum_statistic;
   end loop;
   --
   l_srclenall := t_appvalues ('SRCLENALL');
   l_srclencode := t_appvalues ('SRCLENCODE');
   l_srclencomments := t_appvalues ('SRCLENCOMMENTS');
   l_srclencode_pct := round ( (l_srclencode / l_srclenall * 100), 0);
   l_srclencomments_pct := round ( (l_srclencomments / l_srclenall * 100), 0);
   --
   l_stmtplsql := t_appvalues ('STMTPLSQL');
   l_stmtselect := t_appvalues ('STMTSELECT');
   l_stmtinsert := t_appvalues ('STMTINSERT');
   l_stmtupdate := t_appvalues ('STMTUPDATE');
   l_stmtdelete := t_appvalues ('STMTDELETE');
   l_stmtread := l_stmtselect;
   l_stmtwrite := l_stmtinsert + l_stmtupdate + l_stmtdelete;
   l_stmtread_pct := round ( (l_stmtread / l_stmtplsql * 100), 0);
   l_stmtwrite_pct := round ( (l_stmtwrite / l_stmtplsql * 100), 0);
   l_stmt_pct := round ( ( (l_stmtplsql - (l_stmtread + l_stmtwrite)) / l_stmtplsql * 100), 0);
   --
   l_statframes := t_appvalues ('STATFRAME');
   l_repframes := t_appvalues ('REPFRAME');
   l_frames := l_statframes + l_repframes;
   l_statframes_pct := round ( (l_statframes / l_frames * 100), 0);
   l_repframes_pct := round ( (l_repframes / l_frames * 100), 0);
   --
   l_html := tvd_reports_information.header_text || ' - ' || to_char (sysdate, 'DD.MM.RRRR HH24:MI:SS');
   db_report_output.headerj (l_html);
   db_report_output.title (tvd_reports_information.header_text);
   db_report_output.subtitle ('anzahl', 'Reports Komplexität Standard');
   db_report_output.text ('<table border="1"  width="100%" class="header">');
   if l_gesamt_komp between 35 and 60
   then
      db_report_output.text ('<td  bgcolor="#FFF000" width="60%" colspan="2" align="center">');
   elsif l_gesamt_komp > 60
   then
      db_report_output.text ('<td  bgcolor="#FF0000" width="60%" colspan="2" align="center">');
   else
      db_report_output.text ('<td  bgcolor="#00FF00" width="60%" colspan="2" align="center">');
   end if;
   db_report_output.text ('<b><font size="7">' || l_gesamt_komp || '%</font></b><br>');
   db_report_output.text ('</td>');
   db_report_output.text ('<td  width="40%" colspan="2" align="center">');
   db_report_output.text ('<b><font size="4">Top Ten Reports Komplexität</font></b><br>');
   db_report_output.html_table_start;
   db_report_output.html_table_header ('Modul' || l_sep || 'Komplexität in Prozent');
   l_counter := 0;
   for c in c_module
   loop
      l_modul := 'mod_stat_' || lower (replace (c.mod_name, '.', '_')) || '.htm';
      db_report_output.html_table (db_report_output.get_link (l_modul, lower (c.mod_name)) || l_sep || c.complexity);
      l_counter := l_counter + 1;
      exit when l_counter >= 10;
   end loop;
   db_report_output.html_table_end;
   --
   l_html := '<b>Übersicht Komplexität aller Module >>></b>';
   db_report_output.text (db_report_output.get_link ('reports_komplexitaet_alle.htm', l_html));
   db_report_output.text ('</td>');
   db_report_output.html_table_end;
   --
   db_report_output.subtitle ('anzahl', 'Komplexitäts Verteilung');
   db_report_output.text ('<table border="1"  width="100%" class="header">');
   db_report_output.text ('<td width="60%" colspan="2" align="center">');
   db_report_output.text ('<div id="placeholder" style="width:600px;height:300px;"></div>');
   db_report_output.text ('</td>');
   db_report_output.text ('<td width="40%" colspan="2" align="center">');
   db_report_output.html_table_start;
   db_report_output.html_table_header ('Komplexität in %' || l_sep || 'Anzahl Module');
   for c in c_komp
   loop
      db_report_output.html_table (c.percentage - 10 || ' bis ' || c.percentage || ' %' || l_sep || c.modulcount);
   end loop;
   db_report_output.html_table_end;
   db_report_output.text ('</td>');
   db_report_output.text ('</table>');
   --
   db_report_output.subtitle ('anzahl', 'Dokumentation im Code');
   db_report_output.text ('<table border="1"  width="100%" class="header">');
   db_report_output.text ('<td width="60%" colspan="2" align="center">');
   db_report_output.text ('<div id="doku" style="width:600px;height:300px;"></div>');
   db_report_output.text ('</td>');
   db_report_output.text ('<td width="40%" colspan="2" align="center">');
   db_report_output.html_table_start;
   db_report_output.html_table_header ('Merkmal' || l_sep || 'Anzahl');
   db_report_output.html_table ('Gesamtlänge Sourcecode' || l_sep || l_srclenall);
   db_report_output.html_table ('davon Kommentare' || l_sep || l_srclencomments);
   db_report_output.html_table_end;
   db_report_output.text ('</td>');
   db_report_output.text ('</table>');
   --
   db_report_output.subtitle ('anzahl', 'Datenbankzugriff im Code');
   db_report_output.text ('<table border="1"  width="100%" class="header">');
   db_report_output.text ('<td width="60%" colspan="2" align="center">');
   db_report_output.text ('<div id="dbc" style="width:600px;height:300px;"></div>');
   db_report_output.text ('</td>');
   db_report_output.text ('<td width="40%" colspan="2" align="center">');
   db_report_output.html_table_start;
   db_report_output.html_table_header ('Merkmal' || l_sep || 'Anzahl');
   db_report_output.html_table ('Gesamtmenge Statements' || l_sep || l_stmtplsql);
   db_report_output.html_table ('Datenbankzugriffe schreibend' || l_sep || l_stmtwrite);
   db_report_output.html_table ('Datenbankzugriffe lesend' || l_sep || l_stmtread);
   db_report_output.html_table_end;
   db_report_output.text ('</td>');
   db_report_output.text ('</table>');
   --
   db_report_output.subtitle ('anzahl', 'Layout Frames');
   db_report_output.text ('<table border="1"  width="100%" class="header">');
   db_report_output.text ('<td width="60%" colspan="2" align="center">');
   db_report_output.text ('<div id="dbb" style="width:600px;height:300px;"></div>');
   db_report_output.text ('</td>');
   db_report_output.text ('<td width="40%" colspan="2" align="center">');
   db_report_output.html_table_start;
   db_report_output.html_table_header ('Merkmal' || l_sep || 'Anzahl');
   db_report_output.html_table ('Gesamtmenge Frames' || l_sep || l_frames);
   db_report_output.html_table ('Statische Frames' || l_sep || l_statframes);
   db_report_output.html_table ('Repeating Frames' || l_sep || l_repframes);
   db_report_output.html_table_end;
   db_report_output.text ('</td>');
   db_report_output.text ('</table>');
   --
   db_report_output.subtitle ('anzahl', 'Kriterien und Gewichtung');
   db_report_output.html_table_start;
   db_report_output.html_table_header (
         'Kriterium'
      || l_sep
      || 'Kriterium MIN'
      || l_sep
      || 'Kriterium MAX'
      || l_sep
      || 'Kriterium Gewichtung'
      || l_sep
      || 'Anwendung Durchschnitt'
      || l_sep
      || 'Anwendung MAX'
      || l_sep
      || 'Anwendung Summe'
   );
   for c in c_set
   loop
      db_report_output.html_table (
            c.object_description
         || l_sep
         || c.min_value
         || l_sep
         || c.max_value
         || l_sep
         || c.priority
         || l_sep
         || c.avg
         || l_sep
         || c.max
         || l_sep
         || c.sum
      );
   end loop;
   db_report_output.html_table_end;
   --
   db_report_output.text ('<br>');
   db_report_output.text ('<br>');
   db_report_output.abschluss;
   --
   -- Javascript Part
   --
   db_report_output.text ('<script id="source">');
   db_report_output.text ('$(function () {');
   db_report_output.text ('    var d1 = [];');
   db_report_output.text ('        d1.push([0, 0 ]);');
   for c in c_komp
   loop
      db_report_output.text ('        d1.push([' || c.percentage || ', ' || c.modulcount || ' ]);');
   end loop;
   db_report_output.text ('    var stack = 1, bars = true, lines = true, steps = false;');
   db_report_output.text ('    function plotWithOptions() {');
   db_report_output.text ('        $.plot($("#placeholder"), [ d1 ], {');
   db_report_output.text ('            series: {');
   db_report_output.text ('               stack: stack,');
   db_report_output.text ('                lines: { show: lines, fill: true, steps: steps },');
   db_report_output.text ('                bars: { show: bars, barWidth: 0.2 }');
   db_report_output.text ('            }');
   db_report_output.text ('        });');
   db_report_output.text ('    }');
   db_report_output.text ('    plotWithOptions();');
   db_report_output.text ('});');
   --
   db_report_output.text (' var data_doku = [');
   db_report_output.text ('    { label: "Dokumentation",  data: ' || to_char (l_srclencomments_pct) || '},');
   db_report_output.text ('    { label: "Sourcecode",  data: ' || to_char (l_srclencode_pct) || '}');
   db_report_output.text (' ];');
   db_report_output.text ('    $.plot($("#doku"), data_doku, ');
   db_report_output.text (' {');
   db_report_output.text ('        series: {');
   db_report_output.text ('            pie: { ');
   db_report_output.text ('                show: true,');
   db_report_output.text ('                radius: 1,');
   db_report_output.text ('                label: {');
   db_report_output.text ('                    show: true,');
   db_report_output.text ('                    radius: 1,');
   db_report_output.text ('                    formatter: function(label, series){');
   db_report_output.text ('return ''<div style="font-size:8pt;text-align:center;padding:2px;color:black;">''');
   db_report_output.text ('+label+''<br/>''+Math.round(series.percent)+''%</div>'';');
   db_report_output.text ('                    },');
   db_report_output.text ('                    background: { opacity: 0.8 }');
   db_report_output.text ('                }');
   db_report_output.text ('            }');
   db_report_output.text ('        },');
   db_report_output.text ('        legend: {');
   db_report_output.text ('            show: false');
   db_report_output.text ('        }');
   db_report_output.text (' });');
   --
   db_report_output.text (' var data_dbc = [');
   db_report_output.text ('    { label: "schreibend",  data: ' || to_char (l_stmtwrite_pct) || '},');
   db_report_output.text ('    { label: "lesend",  data: ' || to_char (l_stmtread_pct) || '},');
   db_report_output.text ('    { label: "PL/SQL Statements",  data: ' || to_char (l_stmt_pct) || '}');
   db_report_output.text (' ];');
   db_report_output.text ('    $.plot($("#dbc"), data_dbc, ');
   db_report_output.text (' {');
   db_report_output.text ('        series: {');
   db_report_output.text ('            pie: { ');
   db_report_output.text ('                show: true,');
   db_report_output.text ('                radius: 1,');
   db_report_output.text ('                label: {');
   db_report_output.text ('                    show: true,');
   db_report_output.text ('                    radius: 1,');
   db_report_output.text ('                    formatter: function(label, series){');
   db_report_output.text ('return ''<div style="font-size:8pt;text-align:center;padding:2px;color:black;">''');
   db_report_output.text ('+label+''<br/>''+Math.round(series.percent)+''%</div>'';');
   db_report_output.text ('                    },');
   db_report_output.text ('                    background: { opacity: 0.8 }');
   db_report_output.text ('                }');
   db_report_output.text ('            }');
   db_report_output.text ('        },');
   db_report_output.text ('        legend: {');
   db_report_output.text ('            show: false');
   db_report_output.text ('        }');
   db_report_output.text (' });');
   --
   db_report_output.text (' var data_dbb = [');
   db_report_output.text ('    { label: "Statische Frames",  data: ' || to_char (l_statframes_pct) || '},');
   db_report_output.text ('    { label: "Repeating Frames",  data: ' || to_char (l_repframes_pct) || '}');
   db_report_output.text (' ];');
   db_report_output.text ('    $.plot($("#dbb"), data_dbb, ');
   db_report_output.text (' {');
   db_report_output.text ('        series: {');
   db_report_output.text ('            pie: { ');
   db_report_output.text ('                show: true,');
   db_report_output.text ('                radius: 1,');
   db_report_output.text ('                label: {');
   db_report_output.text ('                    show: true,');
   db_report_output.text ('                    radius: 1,');
   db_report_output.text ('                    formatter: function(label, series){');
   db_report_output.text ('return ''<div style="font-size:8pt;text-align:center;padding:2px;color:black;">''');
   db_report_output.text ('+label+''<br/>''+Math.round(series.percent)+''%</div>'';');
   db_report_output.text ('                    },');
   db_report_output.text ('                    background: { opacity: 0.8 }');
   db_report_output.text ('                }');
   db_report_output.text ('            }');
   db_report_output.text ('        },');
   db_report_output.text ('        legend: {');
   db_report_output.text ('            show: false');
   db_report_output.text ('        }');
   db_report_output.text (' });');
   --
   db_report_output.text ('</script>');
end;
/

spool off

set termout on
prompt Erstellen Datei &mod_statistic....
set termout off

spool &mod_statistic

declare
   cursor c_module
   is
      select mods.mod_name
        from module mods
       where mods.mod_typ = 'RDF';
begin
   for c in c_module
   loop
      dbms_output.put_line ('@@mod_stat_' || lower (replace (c.mod_name, '.', '_')) || '.sql');
      tvd_reports_information.erstelle_mod_modul_stat_sql (c.mod_name);
   end loop;
end;
/

spool off

