DEFINE PATH='&1'
DEFINE SCHEMA='%'

DEFINE FILENAME = &PATH/index.htm

SET TERMOUT ON
PROMPT Erstelle index.htm ...
PROMPT
SET TERMOUT OFF
SPOOL &FILENAME
DECLARE
  v_anzahl_module         VARCHAR2(40):=tvd_information.get_anzahl_module;
  v_gesamt_zeilen         VARCHAR2(40):=tvd_information.get_anzahl_zeilen;
  v_betroffene_zeilen     VARCHAR2(40):=tvd_information.get_betroffene_zeilen;
  v_sep                    VARCHAR2(2) := db_report_output.g_separator;
  v_prozent                number(10) := TVD_INFORMATION.GET_OPTION_NUMBER('AUFSCHLAG');
  cursor c_klasse
    IS SELECT   COUNT (s.suchstring) Anzahl, s.klasse Klasse
    FROM betroffen_daten a JOIN suchstring s ON (a.suchstring = s.suchstring)
    GROUP BY s.klasse
    ORDER BY s.klasse;
  cursor c_zeit
   is SELECT DISTINCT s.klasse klasse, s.zeit minuten
           FROM suchstring s
          WHERE s.klasse IS NOT NULL order by s.klasse;
  cursor c_aufwand 
   is  SELECT   COUNT (s.suchstring) Anzahl, s.klasse Klasse, round(COUNT (s.suchstring)* min(s.ZEIT) /60 / 8,2) Tage 
    FROM betroffen_daten a JOIN suchstring s ON (a.suchstring = s.suchstring)
    GROUP BY s.klasse
    ORDER BY s.klasse;
BEGIN
  db_report_output.header('Forms Analyse Report V2.1 vom '||' - '||TO_CHAR(SYSDATE, 'DD.MM.RRRR HH24:MI:SS'));
  db_report_output.title(tvd_information.v_text);
  db_report_output.ADRESSAT;
  db_report_output.text('<p>');
  db_report_output.text ('<table border="1"  width="100%" class="header">');
  db_report_output.text('<tr><td  colspan="7" align="center"><h1>Module</h1></td></tr>');
  db_report_output.html_table_header ( 'Anzahl Module' || v_sep ||' gesamt Zeilen '||v_sep||' betroffene Zeilen '||v_sep||' davon Forms'||v_sep||' davon Libraries '||v_sep||' davon Menues '||v_sep||' davon Reports ');
  db_report_output.html_table(          v_anzahl_module|| v_sep ||v_gesamt_zeilen  ||v_sep||v_betroffene_zeilen ||v_sep||tvd_information.get_anzahl_fmb||v_sep||tvd_information.get_anzahl_pll||v_sep||tvd_information.get_anzahl_mmb||v_sep||tvd_information.get_anzahl_rdf);
  db_report_output.text('</table>');
  db_report_output.text('<p>');
  db_report_output.text ('<table border="1"  width="100%" class="header">');
  db_report_output.text('<tr><td  colspan="6" align="center"><h1>Canvas</h1></td></tr>');
  db_report_output.html_table_header ( 'Anzahl Canvas' || v_sep ||' Content '||v_sep||' Stacked '||v_sep||' Tabed ');
  db_report_output.html_table(          TVD_INFORMATION.GET_ANZAHL_CANVAS   || v_sep 
                                      ||TVD_INFORMATION.get_anzahl_content  ||v_sep
                                      ||TVD_INFORMATION.get_anzahl_stacked ||v_sep
                                      ||TVD_INFORMATION.get_anzahl_tab
                                     );
  db_report_output.text('</table>');
  db_report_output.text ('<table border="1"  width="100%" class="header">');
  db_report_output.text('<tr><td  colspan="6" align="center"><h1>Erläuterung der Problem Klassen</h1></td></tr>');
  db_report_output.html_table_header ( 'A' || v_sep ||' B '||v_sep||' C '||v_sep||'D');
  db_report_output.html_table(          'Die Migration der Klasse A kann durch ein Script getätigt werden'
                           || v_sep ||'Bei der Klasse B müssen einzelne Migrations Teile entwickelt werden, die aber danach durch ein Script automatisiert werden'
                           ||v_sep||'Die Klasse C muss manuell entwickelt werden und kann nur bedingt über ein Script automatisiert migriert werden.'
                           ||v_sep||'Die Klasse D muss in jedem Falle händisch entwickelt werden.');
     
  db_report_output.text('</table>');
  db_report_output.text('<p>');
  db_report_output.text('<p>');
  db_report_output.text ('<table border="1"  width="100%" class="header">');
  db_report_output.text('<td  colspan="2" align="center">');
  db_report_output.html_table_start; 
  db_report_output.html_table_header (   'Problem Klasse'
                                       || v_sep
                                       || 'Anzahl'
                                      );

   FOR c IN c_klasse
   LOOP
 
      db_report_output.html_table (   c.Klasse
                                   || v_sep
                                   || c.Anzahl );
   END LOOP;

   db_report_output.html_table_end;
   db_report_output.text('</td>');
   db_report_output.text('<td  colspan="2" align="center">');
   db_report_output.text ('<b>Hinweise fuer die Aufwands Werte</b><br>');
   db_report_output.text ('Es wurden fuer die Errechnung der Zeit folgende Vorgaben verwendet');
   db_report_output.html_table_start;
   db_report_output.html_table_header (   'Problem Klasse'
                                       || v_sep
                                       || 'Zeit in Minuten'
                                      );

   FOR c IN c_zeit
   LOOP
 
      db_report_output.html_table (   c.Klasse
                                   || v_sep
                                   ||to_char(to_number(c.Minuten)*v_prozent) );
   END LOOP;

   db_report_output.html_table_end;
   db_report_output.text('</td>');
   db_report_output.text('<td  colspan="2" align="center">');
   db_report_output.text ('<b>unverbindliche Aufwandsschätzung</b><br>');
   db_report_output.text ('anhand der gefundenen Informationen kann von einem ungefährem Aufwand ausgegangen werden');
   db_report_output.html_table_start;
   db_report_output.html_table_header (   'Problem Klasse'
                                       || v_sep
                                       || 'Anzahl'
                                       || v_sep
                                       || 'Zeit in Manntagen' 
                                      );

   FOR c IN c_aufwand
   LOOP
 
      db_report_output.html_table (   c.Klasse
                                   || v_sep
                                   || c.anzahl
                                   || v_sep
                                   || to_char(to_number(c.tage)*v_prozent) );
   END LOOP;
   db_report_output.html_table_end;
   db_report_output.text('</td>');

   db_report_output.html_table_end;
   DB_REPORT_OUTPUT.text('<br>');
   DB_REPORT_OUTPUT.text('<br>');
   DB_REPORT_OUTPUT.ABSCHLUSS;
END;
/
SPOOL OFF

