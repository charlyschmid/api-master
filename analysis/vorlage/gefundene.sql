/* Formatted on 2006/12/22 13:40 (Formatter Plus v4.8.7) */
DEFINE PATH='&1'
DEFINE SCHEMA='%'

DEFINE FILENAME = &PATH/gefundene.htm
DEFINE MOD_GEFUNDENE  = script/mod_gefunden.sql

SET TERMOUT ON
PROMPT Erstelle gefundene.htm ...
PROMPT
SET TERMOUT OFF
REM ##################################################################
REM Erstellen der uebersicht.htm
REM ##################################################################
SPOOL &FILENAME

DECLARE
   v_sep   VARCHAR2 (2) := db_report_output.g_separator;

   CURSOR c_suchstring
   IS
      SELECT DISTINCT b.suchstring such, c.KLASSE
                 FROM betroffen_daten b, SUCHSTRING c
                 where b.SUCHSTRING=c.SUCHSTRING
             ORDER BY 1 ASC;
BEGIN
   db_report_output.header('Forms Analyse Report V2.0 vom '||' - '||TO_CHAR(SYSDATE, 'DD.MM.RRRR HH24:MI:SS'));
   db_report_output.title(tvd_information.v_text);
   db_report_output.text('<p>');
  
   db_report_output.subtitle ('Build_Ins', 'Programm Komponenten die migriert werden müssen');
   db_report_output.html_table_start;
   db_report_output.html_table_header (   'Build_In'
                                       || v_sep
                                       || 'Anzahl'
                                       || v_sep
                                       || 'Build_In Betrachtung'
                                       || v_sep
                                       || 'Beschreibung'
                                       || v_sep
                                       || 'Ersetzung'
                                       || v_sep
                                       || 'Klasse'
                                      );

   FOR c IN c_suchstring
   LOOP
      db_report_output.html_table
                                 (   c.such
                                  || v_sep
                                  || tvd_information.get_zeilen_suchstring (upper(c.such))
                                  || v_sep
                                  || db_report_output.get_link
                                                             (   'mod_'
                                                              || rtrim(ltrim(LOWER (c.such)))
                                                              || '.htm',
                                                              LOWER (c.such)
                                                             )
                                 || v_sep
                                 || tvd_information.get_suchstring_ersetztung (upper(c.such))
                                 
                                 
                                 || v_sep
                                 || tvd_information.get_suchstring_loesung (upper(c.such))
                                 || v_sep
                                 || c.klasse
                                 
                                 );
                                 --get_suchstring_ersetztung (p_suchstring 
   END LOOP;

   db_report_output.html_table_end;
   
    DB_REPORT_OUTPUT.text('<br>');
   DB_REPORT_OUTPUT.text('<br>');
   DB_REPORT_OUTPUT.ABSCHLUSS;
  
END;
/

SPOOL OFF

SET TERMOUT ON
PROMPT Erstellen des mod_gefunden.sql....

SET TERMOUT OFF


SPOOL &MOD_GEFUNDENE

DECLARE
   CURSOR c_suchstring
   IS
      SELECT DISTINCT betroffen_daten.SUCHSTRING such
                 FROM betroffen_daten 
             ORDER BY 1 ASC;
BEGIN
   FOR c IN c_suchstring
   LOOP
      DBMS_OUTPUT.put_line ('@@mod_' || rtrim(ltrim(LOWER (c.such))) || '.sql');
      tvd_information.erstelle_mod_such_sql (LOWER (c.such));
   END LOOP;
END;
/

SPOOL OFF
