/* Formatted on 27.12.2010 10:09:17 (QP5 v5.115.810.9015) */
DEFINE PATH='&1'
DEFINE SCHEMA='%'

DEFINE FILENAME = &PATH/aufwaende.htm


SET TERMOUT ON
PROMPT Erstelle aufwaende.htm..
PROMPT
SET TERMOUT OFF
REM ##################################################################
REM Erstellen der aufwaende.htm
REM ##################################################################
SPOOL &FILENAME

DECLARE
   v_anzahl_module   VARCHAR2 (40) := tvd_information.get_anzahl_module;
   v_gesamt_zeilen   VARCHAR2 (40) := tvd_information.get_anzahl_zeilen;
   v_betroffene_zeilen VARCHAR2 (40)
         := tvd_information.get_betroffene_zeilen ;
   v_sep             VARCHAR2 (2) := db_report_output.g_separator;
   v_prozent NUMBER (10)
         := TVD_INFORMATION.GET_OPTION_NUMBER ('AUFSCHLAG') ;

   CURSOR c_suchstring
   IS
        SELECT   DISTINCT b.suchstring such
          FROM   betroffen_daten b
      ORDER BY   1 ASC;

   CURSOR c_klasse
   IS
        SELECT   COUNT (s.suchstring) Anzahl, s.klasse Klasse
          FROM      betroffen_daten a
                 JOIN
                    suchstring s
                 ON (a.suchstring = s.suchstring)
      GROUP BY   s.klasse
      ORDER BY   s.klasse;

   CURSOR c_zeit
   IS
        SELECT   DISTINCT s.klasse klasse, s.zeit minuten
          FROM   suchstring s
         WHERE   s.klasse IS NOT NULL
      ORDER BY   s.klasse;

   CURSOR c_aufwand
   IS
        SELECT   COUNT (s.suchstring) Anzahl,
                 s.klasse Klasse,
                 ROUND (COUNT (s.suchstring) * MIN (s.ZEIT) / 60 / 8, 2) Tage
          FROM      betroffen_daten a
                 JOIN
                    suchstring s
                 ON (a.suchstring = s.suchstring)
      GROUP BY   s.klasse
      ORDER BY   s.klasse;

   CURSOR c_topics
   IS
      SELECT   id, topic FROM PROJEKT_PLANUNG;

   CURSOR c_sontiges
   IS
      SELECT   so.BEZEICHNUNG,
               so.AUFWAND_MIN,
               so.GLOBAL,
               so.BESCHREIBUNG
        FROM   SONSTIGES so, ZUO_PROJEK_TAETIGKEIT zu
       WHERE   SO.ID = ZU.BERSCHREIBUNG_ID;
BEGIN
   db_report_output.header(   'Forms Analyse Report V2.0 vom '
                           || ' - '
                           || TO_CHAR (SYSDATE, 'DD.MM.RRRR HH24:MI:SS'));
   db_report_output.title (tvd_information.v_text);
   db_report_output.text ('<table border="1"  width="100%" class="header">');
   db_report_output.text (
      '<tr><td  colspan="6" align="center"><h1>Module</h1></td></tr>'
   );
   db_report_output.html_table_header(   'Anzahl Module'
                                      || v_sep
                                      || ' gesamt Zeilen '
                                      || v_sep
                                      || ' betroffene Zeilen '
                                      || v_sep
                                      || ' davon Forms'
                                      || v_sep
                                      || ' davon Libraries '
                                      || v_sep
                                      || ' davon Menues ');
   db_report_output.html_table(   v_anzahl_module
                               || v_sep
                               || v_gesamt_zeilen
                               || v_sep
                               || v_betroffene_zeilen
                               || v_sep
                               || tvd_information.get_anzahl_fmb
                               || v_sep
                               || tvd_information.get_anzahl_pll
                               || v_sep
                               || tvd_information.get_anzahl_mmb);
   db_report_output.text ('</table>');
   db_report_output.text ('<p>');
   ------------------------------------------
   -- Uebersicht der Klassifikationen
   ------------------------------------------
   db_report_output.text ('<table border="1"  width="100%" class="header">');
   db_report_output.text('<tr><td  colspan="6" align="center"><h1>Erläuterung der Problem Klassen</h1></td></tr>');
   db_report_output.html_table_header (
      'A' || v_sep || ' B ' || v_sep || ' C ' || v_sep || 'D'
   );
   db_report_output.html_table('Die Migration der Klasse A kann durch ein Script getätigt werden'
                               || v_sep
                               || 'Bei der Klasse B müssen einzelne Migrations Teile entwickelt werden, die aber danach durch ein Script automatisiert werden'
                               || v_sep
                               || 'Die Klasse C muss manuell entwickelt werden und kann nur bedingt über ein Script automatisiert migriert werden.'
                               || v_sep
                               || 'Die Klasse D muss in jedem Falle händisch entwickelt werden.');

   db_report_output.text ('</table>');
   db_report_output.text ('<p>');
   db_report_output.text ('<p>');
   db_report_output.html_table_start;
   db_report_output.html_table_header ('Problem Klasse' || v_sep || 'Anzahl');

   FOR c IN c_klasse
   LOOP
      db_report_output.html_table (c.Klasse || v_sep || c.Anzahl);
   END LOOP;

   db_report_output.html_table_end;


   db_report_output.text ('<b>Hinweise fuer die Aufwands Werte</b><br>');
   db_report_output.text (
      'Es wurden fuer die Errechnung der Zeit folgende Vorgaben verwendet'
   );
   db_report_output.html_table_start;
   db_report_output.html_table_header (
      'Problem Klasse' || v_sep || 'Zeit in Minuten'
   );

   FOR c IN c_zeit
   LOOP
      db_report_output.html_table (
         c.Klasse || v_sep || TO_CHAR (TO_NUMBER (c.Minuten) * v_prozent)
      );
   END LOOP;

   db_report_output.html_table_end;

   ------------------------------------------
   -- ca Aufwand
   ------------------------------------------
   db_report_output.text ('<b>unverbindliche Aufwandsschätzung</b><br>');
   db_report_output.text('anhand der gefundenen Informationen kann von einem ungefährem Aufwand ausgegangen werden');
   db_report_output.html_table_start;
   db_report_output.html_table_header (
      'Problem Klasse' || v_sep || 'Anzahl' || v_sep || 'Zeit in Manntagen'
   );

   FOR c IN c_aufwand
   LOOP
      db_report_output.html_table(   c.Klasse
                                  || v_sep
                                  || c.anzahl
                                  || v_sep
                                  || TO_CHAR (TO_NUMBER (c.tage) * v_prozent));
   END LOOP;

   db_report_output.html_table_end;

   ------------------------------------------
   -- c_sontiges
   ------------------------------------------
   db_report_output.text ('<b>unverbindliche Aufwandsschätzung</b><br>');
   db_report_output.text('anhand der gefundenen Informationen kann von einem ungefährem Aufwand ausgegangen werden');
   DB_REPORT_OUTPUT.text ('<br>');
   DB_REPORT_OUTPUT.text ('<br>');

   FOR c IN c_topics
   LOOP
      db_report_output.text (
         '<table border="1"  width="100%" class="header">'
      );
      db_report_output.text(   '<tr><td  colspan="6" align="center"><h1>'
                            || c.topic
                            || '</h1></td></tr>');
      db_report_output.html_table_header(   'Bezeichnung'
                                         || v_sep
                                         || 'Aufwand in Minuten'
                                         || v_sep
                                         || 'Beschreibung');

      FOR c1
      IN (SELECT   so.BEZEICHNUNG,
                   so.AUFWAND_MIN,
                   so.GLOBAL,
                   so.BESCHREIBUNG
            FROM   SONSTIGES so, ZUO_PROJEK_TAETIGKEIT zu
           WHERE   SO.ID = ZU.BERSCHREIBUNG_ID AND ZU.PROJEKT_PL_ID = c.id)
      LOOP
         db_report_output.text ('<tr><td >' || c1.bezeichnung || '</td>');
         if c1.global='Y' then
         db_report_output.text ('<td align="center">' || c1.aufwand_min || '</td>');
         else
         db_report_output.text ('<td align="center">' || to_char(to_number(c1.aufwand_min) * to_number(v_anzahl_module) )|| '</td>');
         end if;
         db_report_output.text ('<td >' || c1.beschreibung || '</td></tr>');
      END LOOP;

      db_report_output.html_table_end;
   END LOOP;

   DB_REPORT_OUTPUT.text ('<br>');
   DB_REPORT_OUTPUT.text ('<br>');
   DB_REPORT_OUTPUT.ABSCHLUSS;
END;
/

SPOOL OFF