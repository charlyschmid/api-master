/* Formatted on 2008/05/14 11:54 (Formatter Plus v4.8.8) */
DEFINE PATH='&1'
DEFINE SCHEMA='%'

DEFINE FILENAME = &PATH/allgemein.htm
DEFINE MOD_GEFUNDENE  = script/mod_allgemein.sql

SET TERMOUT ON
PROMPT Erstelle allgemein.htm ...
PROMPT
SET TERMOUT OFF
REM ##################################################################
REM Erstellen der allgemein.htm
REM ##################################################################
SPOOL &FILENAME

DECLARE
   v_sep     VARCHAR2 (2)   := db_report_output.g_separator;
   v_modul   VARCHAR2 (200) := NULL;
BEGIN
  db_report_output.header('Forms Analyse Report V2.1 vom '||' - '||TO_CHAR(SYSDATE, 'DD.MM.RRRR HH24:MI:SS'));
  db_report_output.title(tvd_information.v_text);

  db_report_output.text('<p>');
   db_report_output.text
      ('<b>Modul:</b> Hier werden alle Module aufgelistet sowie die zugehoerigen Libraries.'
      );
   db_report_output.br;
------------------------------------------
-- Welche Module sind betroffen
------------------------------------------
   db_report_output.anchor ('anzahl', 'Uebersicht der Anzahl an Modulen');
   db_report_output.anchor ('formsmodule',
                            'Auflistung aller Forms Module mit Libraries'
                           );
   db_report_output.anchor ('menuemodule',
                            'Auflistung aller Menue Module mit Libraries'
                           );
   db_report_output.anchor ('librariemodule',
                            'Auflistung aller Libraries Module mit Libraries'
                           );
   db_report_output.anchor ('reportsmodule',
                            'Auflistung aller Reports Module mit Libraries'
                           );                           
   db_report_output.subtitle ('anzahl', 'Anzahl einzelnen Modul Typen');
   db_report_output.html_table_start;
   db_report_output.html_table_header ('Modul Typ' || v_sep || 'Anzahl');
   db_report_output.html_table (   'Forms Module '
                                || v_sep
                                || tvd_information.get_anzahl_module ('FMB')
                               );
   db_report_output.html_table (   'Menue Module '
                                || v_sep
                                || tvd_information.get_anzahl_module ('MMB')
                               );
   db_report_output.html_table (   'Libraries Module '
                                || v_sep
                                || tvd_information.get_anzahl_module ('PLL')
                               );
   db_report_output.html_table (   'Reports Module '
                                || v_sep
                                || tvd_information.get_anzahl_module ('RDF')
                               );                               
   db_report_output.html_table_end;
   db_report_output.top;
   db_report_output.subtitle ('formsmodule',
                              'Auflistung aller Forms Module mit Libraries'
                             );
   db_report_output.html_table_start;
   db_report_output.html_table_header (   'Modul Name'
                                       || v_sep
                                       || 'Datei Name'
                                       || v_sep
                                       || 'Library'
                                      );

   FOR i IN (SELECT   m.mod_maske, m.mod_name, ma.att_lib_name, ma.mod_lib_id,
                      ma.mod_reihenfolge, m.mod_id
                 FROM module m, mod_att_lib ma
                WHERE m.mod_id = ma.mod_id AND m.mod_typ = 'FMB'
             --AND ROWNUM < 20
             ORDER BY m.mod_maske ASC, ma.mod_reihenfolge ASC)
   LOOP
      IF v_modul IS NULL OR v_modul != i.mod_maske
      THEN
         db_report_output.html_table
            (   i.mod_maske
             || v_sep
             || db_report_output.get_link
                   (tvd_information.get_html
                                      (tvd_information.get_modul_name (i.mod_id)
                                      ),
                    tvd_information.get_modul_name (i.mod_id)
                   )
             || v_sep
             || db_report_output.get_link
                   (tvd_information.get_html
                                  (tvd_information.get_modul_name (i.mod_lib_id)
                                  ),
                    tvd_information.get_modul_name (i.mod_lib_id)
                   )
            );
         v_modul := i.mod_maske;
      ELSE
         db_report_output.html_table
            (   ' '
             || v_sep
             || ' '
             || v_sep
             || db_report_output.get_link
                   (tvd_information.get_html
                                  (tvd_information.get_modul_name (i.mod_lib_id)
                                  ),
                    tvd_information.get_modul_name (i.mod_lib_id)
                   )
            );
      END IF;
   END LOOP;

   db_report_output.html_table_end;
   db_report_output.top;
   db_report_output.subtitle ('menuemodule',
                              'Auflistung aller Menue Module mit Libraries'
                             );
   db_report_output.html_table_start;
   db_report_output.html_table_header (   'Modul Name'
                                       || v_sep
                                       || 'Datei Name'
                                       || v_sep
                                       || 'Library'
                                      );

   FOR i IN (SELECT   m.mod_maske, m.mod_name, ma.att_lib_name, ma.mod_lib_id,
                      ma.mod_reihenfolge, m.mod_id
                 FROM module m, mod_att_lib ma
                WHERE m.mod_id = ma.mod_id AND m.mod_typ = 'MMB'
             --AND ROWNUM < 20
             ORDER BY m.mod_maske ASC, ma.mod_reihenfolge ASC)
   LOOP
      IF v_modul IS NULL OR v_modul != i.mod_maske
      THEN
         db_report_output.html_table
            (   i.mod_maske
             || v_sep
             || db_report_output.get_link
                   (tvd_information.get_html
                                      (tvd_information.get_modul_name (i.mod_id)
                                      ),
                    tvd_information.get_modul_name (i.mod_id)
                   )
             || v_sep
             || db_report_output.get_link
                   (tvd_information.get_html
                                  (tvd_information.get_modul_name (i.mod_lib_id)
                                  ),
                    tvd_information.get_modul_name (i.mod_lib_id)
                   )
            );
         v_modul := i.mod_maske;
      ELSE
         db_report_output.html_table
            (   ' '
             || v_sep
             || ' '
             || v_sep
             || db_report_output.get_link
                   (tvd_information.get_html
                                  (tvd_information.get_modul_name (i.mod_lib_id)
                                  ),
                    tvd_information.get_modul_name (i.mod_lib_id)
                   )
            );
      END IF;
   END LOOP;

   db_report_output.html_table_end;
   db_report_output.top;
   db_report_output.subtitle
                            ('librariemodule',
                             'Auflistung aller Libraries Module mit Libraries'
                            );
   db_report_output.html_table_start;
   db_report_output.html_table_header (   'Modul Name'
                                       || v_sep
                                       || 'Datei Name'
                                       || v_sep
                                       || 'Library'
                                      );

   FOR i IN (SELECT   m.mod_maske, m.mod_name, ma.att_lib_name, ma.mod_lib_id,
                      ma.mod_reihenfolge, m.mod_id
                 FROM module m, mod_att_lib ma
                WHERE m.mod_id = ma.mod_id AND m.mod_typ = 'PLL'
             --AND ROWNUM < 20
             ORDER BY m.mod_maske ASC, ma.mod_reihenfolge ASC)
   LOOP
      IF v_modul IS NULL OR v_modul != i.mod_maske
      THEN
         db_report_output.html_table
            (   i.mod_maske
             || v_sep
             || db_report_output.get_link
                   (tvd_information.get_html
                                      (tvd_information.get_modul_name (i.mod_id)
                                      ),
                    tvd_information.get_modul_name (i.mod_id)
                   )
             || v_sep
             || db_report_output.get_link
                   (tvd_information.get_html
                                  (tvd_information.get_modul_name (i.mod_lib_id)
                                  ),
                    tvd_information.get_modul_name (i.mod_lib_id)
                   )
            );
         v_modul := i.mod_maske;
      ELSE
         db_report_output.html_table
            (   ' '
             || v_sep
             || ' '
             || v_sep
             || db_report_output.get_link
                   (tvd_information.get_html
                                  (tvd_information.get_modul_name (i.mod_lib_id)
                                  ),
                    tvd_information.get_modul_name (i.mod_lib_id)
                   )
            );
      END IF;
   END LOOP;


   db_report_output.html_table_end;
   db_report_output.subtitle ('reportsmodule',
                              'Auflistung aller Reports Module mit Libraries'
                             );
   db_report_output.html_table_start;
   db_report_output.html_table_header (   'Reports Name'
                                       || v_sep
                                       || 'Datei Name'
                                       || v_sep
                                       || 'Library'
                                      );

   FOR i IN (SELECT   m.mod_maske, m.mod_name, ma.att_lib_name, ma.mod_lib_id,
                      ma.mod_reihenfolge, m.mod_id
                 FROM module m, mod_att_lib ma
                WHERE m.mod_id = ma.mod_id AND m.mod_typ = 'RDF'
             --AND ROWNUM < 20
             ORDER BY m.mod_maske ASC, ma.mod_reihenfolge ASC)
   LOOP
      IF v_modul IS NULL OR v_modul != i.mod_maske
      THEN
         db_report_output.html_table
            (   i.mod_maske
             || v_sep
             || db_report_output.get_link
                   (tvd_information.get_html
                                      (tvd_information.get_modul_name (i.mod_id)
                                      ),
                    tvd_information.get_modul_name (i.mod_id)
                   )
             || v_sep
             || db_report_output.get_link
                   (tvd_information.get_html
                                  (tvd_information.get_modul_name (i.mod_lib_id)
                                  ),
                    tvd_information.get_modul_name (i.mod_lib_id)
                   )
            );
         v_modul := i.mod_maske;
      ELSE
         db_report_output.html_table
            (   ' '
             || v_sep
             || ' '
             || v_sep
             || db_report_output.get_link
                   (tvd_information.get_html
                                  (tvd_information.get_modul_name (i.mod_lib_id)
                                  ),
                    tvd_information.get_modul_name (i.mod_lib_id)
                   )
            );
      END IF;
   END LOOP;

   db_report_output.html_table_end;
   db_report_output.top;

    DB_REPORT_OUTPUT.text('<br>');
   DB_REPORT_OUTPUT.text('<br>');
   DB_REPORT_OUTPUT.ABSCHLUSS;
END;
/

SPOOL OFF