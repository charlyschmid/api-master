DEFINE PATH='&1'
DEFINE SCHEMA='%'

DEFINE FILENAME = &PATH/komplexitaet_alle.htm

SET TERMOUT ON
PROMPT Erstelle komplexitaet_alle.htm ...
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
BEGIN
  db_report_output.header('Forms Analyse Report V4.0 vom '||' - '||TO_CHAR(SYSDATE, 'DD.MM.RRRR HH24:MI:SS'));
  db_report_output.title(tvd_information.v_text);


db_report_output.subtitle ('anzahl', 'Applikations Komplexität Standard Übersicht');
db_report_output.html_table_start;
   db_report_output.html_table_header ('Modul' || v_sep || 'Komplexität in Prozent');
   v_counter := 0;
   for c in c_module loop
	
    db_report_output.html_table (  db_report_output.get_link('mod_stat_'||lower(c.mod_name)||'.htm', lower(c.mod_name))
                                || v_sep
                                || c.modul_gesammt
                               );
   end loop;                              
   db_report_output.html_table_end;

   DB_REPORT_OUTPUT.text('<br>');
   DB_REPORT_OUTPUT.text('<br>');
   DB_REPORT_OUTPUT.ABSCHLUSS;
   
END;
/
SPOOL OFF

