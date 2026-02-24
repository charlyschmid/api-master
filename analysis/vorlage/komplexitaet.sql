DEFINE PATH='&1'
DEFINE SCHEMA='%'

DEFINE FILENAME = &PATH/komplexitaet.htm
DEFINE MOD_STATISTIC  = script\module_statistic.sql

SET TERMOUT ON
PROMPT Erstelle komplexitaet.htm ...
PROMPT
SET TERMOUT OFF
SPOOL &FILENAME
DECLARE
  v_anzahl_module         VARCHAR2(40):=tvd_information.get_anzahl_module;
  v_gesamt_zeilen         VARCHAR2(40):=tvd_information.get_anzahl_zeilen;
  v_betroffene_zeilen     VARCHAR2(40):=tvd_information.get_betroffene_zeilen;
  v_sep                    VARCHAR2(2) := db_report_output.g_separator;
  v_prozent                number(10) := TVD_INFORMATION.GET_OPTION_NUMBER('AUFSCHLAG');
  v_counter				  number(5);
v_gesamt_komp number(6):=TVDMIG.tvd_information.get_complex_value_application;
  cursor c_module
    IS
        select m.mod_name,  round(ms.modul_gesammt,1) modul_gesammt
        from     module m
                ,module_stat ms
        where   M.MOD_ID = ms.MOD_ID
        order by ms.modul_gesammt desc;
  cursor c_zeit
   is SELECT DISTINCT s.klasse klasse, s.zeit minuten
           FROM suchstring s
          WHERE s.klasse IS NOT NULL order by s.klasse;
  cursor c_aufwand 
   is  SELECT   COUNT (s.suchstring) Anzahl, s.klasse Klasse, round(COUNT (s.suchstring)* min(s.ZEIT) /60 / 8,2) Tage 
    FROM betroffen_daten a JOIN suchstring s ON (a.suchstring = s.suchstring)
    GROUP BY s.klasse
    ORDER BY s.klasse;
	
  cursor c_app_stat is
	select * 
   from application_statistic;
   
   cursor c_komp is
   select * 
   from modul_kom_verteilung 
   order by 1;
   cursor c_set is
   SELECT 
   M.MSS_FEATURE
   , M.MSS_MIN_VALUE
   , M.MSS_MAX_VALUE
   , M.MSS_PRIORITY
   , M.MSS_PRIORITY_PLL
   , M.AVG
   , M.MAX
   , M.SUM
   FROM TVDMIG.MODULE_STATISTIC_SET_VIEW M;
BEGIN
  db_report_output.headerj('Forms Analyse Report V4.0 vom '||' - '||TO_CHAR(SYSDATE, 'DD.MM.RRRR HH24:MI:SS'));
  
db_report_output.title(tvd_information.v_text);

/*
DB_REPORT_OUTPUT.text('<br>');
db_report_output.text ('<table border="1"  width="100%" class="header">');
db_report_output.text('<td  width="60%" colspan="2" align="center">');
db_report_output.text(db_report_output.get_link('komplexitaet.htm', '<br>Applikations Komplexität Standard<br>'));
db_report_output.text('</td>');
db_report_output.text('<td  width="40%" colspan="2" align="center">');
db_report_output.text(db_report_output.get_link('komplexitaet.htm', 'Applikations Komplexität FBS'));
db_report_output.text('</td>');
db_report_output.html_table_end;
*/

db_report_output.subtitle ('anzahl', 'Applikations Komplexität Standard');

  db_report_output.text ('<table border="1"  width="100%" class="header">');  

if v_gesamt_komp between 35 and 60 then
	db_report_output.text('<td  bgcolor="#FFF000" width="60%" colspan="2" align="center">');	
elsif v_gesamt_komp > 60 then
	db_report_output.text('<td  bgcolor="#FF0000" width="60%" colspan="2" align="center">');
else
	db_report_output.text('<td  bgcolor="#00FF00" width="60%" colspan="2" align="center">');
end if;

	db_report_output.text ('<b><font size="7">'||TVDMIG.tvd_information.get_complex_value_application||'%</font></b><br>');
  db_report_output.text('</td>');
   
db_report_output.text('<td  width="40%" colspan="2" align="center">');
   db_report_output.text ('<b><font size="4">Top Ten Forms Komplexität</font></b><br>');
    
db_report_output.html_table_start;
   db_report_output.html_table_header ('Modul' || v_sep || 'Komplexität in Prozent');
   v_counter := 0;
   for c in c_module loop
	
    db_report_output.html_table (  db_report_output.get_link('mod_stat_'||lower(c.mod_name)||'.htm', lower(c.mod_name))
                                || v_sep
                                || c.modul_gesammt
                               );
	v_counter := v_counter +1;
	exit when v_counter >= 10;
   end loop;                              
   db_report_output.html_table_end;
   db_report_output.text (db_report_output.get_link('komplexitaet_alle.htm', '<b>Übersicht Komplexität aller Module >>></b>'));
   
db_report_output.text('</td>');
   db_report_output.html_table_end;


   db_report_output.subtitle ('anzahl', 'Komplexitäts Verteilung');
 db_report_output.text ('<table border="1"  width="100%" class="header">');
 
 db_report_output.text('<td width="60%" colspan="2" align="center">');
 db_report_output.text('<div id="placeholder" style="width:600px;height:300px;"></div>');  
 db_report_output.text('</td>');
 
 db_report_output.text('<td width="40%" colspan="2" align="center">');
 
 db_report_output.html_table_start;
 db_report_output.html_table_header ('Komplexität in %' || v_sep || 'Anzahl Module');
 for c in c_komp loop    
	 db_report_output.html_table (   c.percent-10||' bis '||c.percent||' %'
                                || v_sep
                                || c.auftreten
                               );
end loop;
 db_report_output.html_table_end;
 db_report_output.text('</td>');
 
 db_report_output.text ('</table>');   
 
 

 
 db_report_output.subtitle ('anzahl', 'Dokumentation im Code');
 db_report_output.text ('<table border="1"  width="100%" class="header">');
 
 db_report_output.text('<td width="60%" colspan="2" align="center">');
 db_report_output.text('<div id="doku" style="width:600px;height:300px;"></div>');  
 db_report_output.text('</td>');
 
 db_report_output.text('<td width="40%" colspan="2" align="center">');
 
 db_report_output.html_table_start;
 db_report_output.html_table_header ('Merkmal' || v_sep || 'Anzahl');
 for c in c_app_stat loop    
	 db_report_output.html_table (   'Gesamtlänge Sourcecode'
                                || v_sep
                                || c.sourcecode_all
                               );
	 db_report_output.html_table (   'davon Kommentare'
                                || v_sep
                                || c.comment_length
                               );
end loop;
 db_report_output.html_table_end;
 db_report_output.text('</td>');
 
 db_report_output.text ('</table>');   
 
 
 db_report_output.subtitle ('anzahl', 'Datenbankzugriff im Code');
 db_report_output.text ('<table border="1"  width="100%" class="header">');
 
 db_report_output.text('<td width="60%" colspan="2" align="center">');
 db_report_output.text('<div id="dbc" style="width:600px;height:300px;"></div>');  
 db_report_output.text('</td>');
 
 db_report_output.text('<td width="40%" colspan="2" align="center">');
 
 db_report_output.html_table_start;
 db_report_output.html_table_header ('Merkmal' || v_sep || 'Anzahl');
 for c in c_app_stat loop    
	 db_report_output.html_table (   'Gesamtmenge Statements'
                                || v_sep
                                || c.statements
                               );
	 db_report_output.html_table (   'Datenbankzugriffe schreibend'
                                || v_sep
                                || c.db_statements_write
                               );
	 db_report_output.html_table (   'Datenbankzugriffe lesend'
                                || v_sep
                                || c.db_statements_read
                               );
end loop;
 db_report_output.html_table_end;
 db_report_output.text('</td>');
 
 db_report_output.text ('</table>');  



 
  db_report_output.subtitle ('anzahl', 'Modul Blöcke');
 db_report_output.text ('<table border="1"  width="100%" class="header">');
 
 db_report_output.text('<td width="60%" colspan="2" align="center">');
 db_report_output.text('<div id="dbb" style="width:600px;height:300px;"></div>');  
 db_report_output.text('</td>');
 
 db_report_output.text('<td width="40%" colspan="2" align="center">');
 
 db_report_output.html_table_start;
 db_report_output.html_table_header ('Merkmal' || v_sep || 'Anzahl');
 for c in c_app_stat loop    
	 db_report_output.html_table (   'Gesamtmenge Blöcke'
                                || v_sep
                                || c.blocks_all
                               );
	 db_report_output.html_table (   'Datenbank Blöcke'
                                || v_sep
                                || c.blocks_db
                               );
	 db_report_output.html_table (   'Control Blöcke'
                                || v_sep
                                || c.blocks_ctl
                               );
end loop;
 db_report_output.html_table_end;
 db_report_output.text('</td>');
 
 db_report_output.text ('</table>'); 
 
 
 
 
 db_report_output.subtitle ('anzahl', 'Kriterien und Gewichtung');
 db_report_output.html_table_start;
 db_report_output.html_table_header ('Kriterium' || v_sep || 'Kriterium MIN'|| v_sep || 'Kriterium MAX'|| v_sep || 'Kriterium Gewichtung'|| v_sep ||'Kriterium Gewichtung PLL'|| v_sep ||'Anwendung Durchschnitt'|| v_sep || 'Anwendung MAX'|| v_sep || 'Anwendung Summe');
 for c in c_set loop    
	 db_report_output.html_table (   c.MSS_FEATURE
                                || v_sep
                                || c.MSS_MIN_VALUE
                                || v_sep
                                || c.MSS_MAX_VALUE
								|| v_sep
                                || c.MSS_PRIORITY
								|| v_sep
                                || c.MSS_PRIORITY_PLL
                                || v_sep
                                || c.AVG
								|| v_sep
                                || c.MAX
								|| v_sep
                                || c.SUM
                               );					   
end loop;
 db_report_output.html_table_end;

   DB_REPORT_OUTPUT.text('<br>');
   DB_REPORT_OUTPUT.text('<br>');
   DB_REPORT_OUTPUT.ABSCHLUSS;

--Javascript Part

db_report_output.text('<script id="source">');
db_report_output.text('$(function () {');
db_report_output.text('    var d1 = [];');
db_report_output.text('        d1.push([0, 0 ]);');
for c in c_komp loop
	db_report_output.text('        d1.push(['||c.percent||', '||c.auftreten||' ]);');
end loop;


db_report_output.text('    var stack = 1, bars = true, lines = true, steps = false;');
    
db_report_output.text('    function plotWithOptions() {');
db_report_output.text('        $.plot($("#placeholder"), [ d1 ], {');
db_report_output.text('            series: {');
db_report_output.text('               stack: stack,');
db_report_output.text('                lines: { show: lines, fill: true, steps: steps },');
db_report_output.text('                bars: { show: bars, barWidth: 0.2 }');
db_report_output.text('            }');
db_report_output.text('        });');
db_report_output.text('    }');

db_report_output.text('    plotWithOptions();');
db_report_output.text('});');

for c in c_app_stat loop
db_report_output.text('	var data_doku = [');
db_report_output.text('		{ label: "Dokumentation",  data: '||c.comment_length||'},');
db_report_output.text('		{ label: "Sourcecode",  data: '||c.sourcecode_length||'}');
db_report_output.text('	];');
end loop;

db_report_output.text('    $.plot($("#doku"), data_doku, ');
db_report_output.text('	{');
db_report_output.text('        series: {');
db_report_output.text('            pie: { ');
db_report_output.text('                show: true,');
db_report_output.text('                radius: 1,');
db_report_output.text('                label: {');
db_report_output.text('                    show: true,');
db_report_output.text('                    radius: 1,');
db_report_output.text('                    formatter: function(label, series){');
db_report_output.text('return ''<div style="font-size:8pt;text-align:center;padding:2px;color:black;">''');
db_report_output.text('+label+''<br/>''+Math.round(series.percent)+''%</div>'';');
db_report_output.text('                    },');
db_report_output.text('                    background: { opacity: 0.8 }');
db_report_output.text('                }');
db_report_output.text('            }');
db_report_output.text('        },');
db_report_output.text('        legend: {');
db_report_output.text('            show: false');
db_report_output.text('        }');
db_report_output.text('	});');

for c in c_app_stat loop
db_report_output.text('	var data_dbc = [');
db_report_output.text('		{ label: "schreibend",  data: '||c.db_statements_write||'},');
db_report_output.text('		{ label: "lesend",  data: '||c.db_statements_read||'},');
db_report_output.text('		{ label: "PL/SQL Statements",  data: '||c.statements_ohne_db||'}');
db_report_output.text('	];');
end loop;

db_report_output.text('    $.plot($("#dbc"), data_dbc, ');
db_report_output.text('	{');
db_report_output.text('        series: {');
db_report_output.text('            pie: { ');
db_report_output.text('                show: true,');
db_report_output.text('                radius: 1,');
db_report_output.text('                label: {');
db_report_output.text('                    show: true,');
db_report_output.text('                    radius: 1,');
db_report_output.text('                    formatter: function(label, series){');
db_report_output.text('return ''<div style="font-size:8pt;text-align:center;padding:2px;color:black;">''');
db_report_output.text('+label+''<br/>''+Math.round(series.percent)+''%</div>'';');
db_report_output.text('                    },');
db_report_output.text('                    background: { opacity: 0.8 }');
db_report_output.text('                }');
db_report_output.text('            }');
db_report_output.text('        },');
db_report_output.text('        legend: {');
db_report_output.text('            show: false');
db_report_output.text('        }');
db_report_output.text('	});');


for c in c_app_stat loop
db_report_output.text('	var data_dbb = [');
db_report_output.text('		{ label: "DB Blöcke",  data: '||c.blocks_db||'},');
db_report_output.text('		{ label: "Control Blöcke",  data: '||c.blocks_ctl||'}');
db_report_output.text('	];');
end loop;

db_report_output.text('    $.plot($("#dbb"), data_dbb, ');
db_report_output.text('	{');
db_report_output.text('        series: {');
db_report_output.text('            pie: { ');
db_report_output.text('                show: true,');
db_report_output.text('                radius: 1,');
db_report_output.text('                label: {');
db_report_output.text('                    show: true,');
db_report_output.text('                    radius: 1,');
db_report_output.text('                    formatter: function(label, series){');
db_report_output.text('return ''<div style="font-size:8pt;text-align:center;padding:2px;color:black;">''');
db_report_output.text('+label+''<br/>''+Math.round(series.percent)+''%</div>'';');
db_report_output.text('                    },');
db_report_output.text('                    background: { opacity: 0.8 }');
db_report_output.text('                }');
db_report_output.text('            }');
db_report_output.text('        },');
db_report_output.text('        legend: {');
db_report_output.text('            show: false');
db_report_output.text('        }');
db_report_output.text('	});');

db_report_output.text('</script>');
   
END;
/
SPOOL OFF

SET TERMOUT ON
prompt Erstellen des module_statistic.sql.... 

SET TERMOUT OFF

 
SPOOL &MOD_STATISTIC
DECLARE
  cursor c_module
    IS
        select m.mod_name
        from     module m
                ,module_stat ms
        where   M.MOD_ID = ms.MOD_ID
        order by ms.modul_gesammt desc;
BEGIN
	--dbms_output.put_line('@@mod_stat_'||lower(substr('lo_fadsp_cr.fmb',1,instr('lo_fadsp_cr.fmb','.') -1))||'.sql');
	--tvd_information.erstelle_mod_modul_stat_sql('lo_fadsp_cr.fmb');
   FOR c IN c_module
   LOOP
    dbms_output.put_line('@@mod_stat_'||lower(c.mod_name)||'.sql');
    tvd_information.erstelle_mod_modul_stat_sql(c.mod_name);
   END LOOP;

END;
/

SPOOL OFF