/* Formatted on 2008/04/25 15:34 (Formatter Plus v4.8.8) */
DEFINE PATH='&1'
DEFINE SCHEMA='%'

DEFINE FILENAME = &PATH/abutton.htm


SET TERMOUT ON
PROMPT Erstelle abutton.htm ...
PROMPT
SET TERMOUT OFF
REM ##################################################################
REM Erstellen der uebersicht.htm
REM ##################################################################
SPOOL &FILENAME

DECLARE
   v_anzahl_module         VARCHAR2 (20)  := tvd_information.get_anzahl_module;
   v_gesamt_zeilen         VARCHAR2 (20)  := tvd_information.get_anzahl_zeilen;
   v_betroffene_zeilen     VARCHAR2 (20)
                                      := tvd_information.get_betroffene_zeilen;
   v_file_name             VARCHAR2 (2200);
   v_instance_name_title   VARCHAR2 (30);
   v_instance_name         VARCHAR2 (30);
   v_host_name             VARCHAR2 (80);
   v_version               VARCHAR2 (30);
   v_status                VARCHAR2 (30);
   v_parallel              VARCHAR2 (30);
   v_archiver              VARCHAR2 (30);
   v_log_switch_wait       VARCHAR2 (30);
   v_logins                VARCHAR2 (30);
   v_shutdown_pending      VARCHAR2 (30);
   v_database_status       VARCHAR2 (30);
   v_sep                   VARCHAR2 (2)    := db_report_output.g_separator;
   x                       NUMBER (2)      := 0;
BEGIN
   db_report_output.header (   'Forms Analyse Report vom '
                            || ' - '
                            || TO_CHAR (SYSDATE, 'DD.MM.RRRR HH24:MI:SS')
                           );
  
   db_report_output.title(tvd_information.v_text);
   db_report_output.text ('<b>Obsolete Items: </b><br>');
   db_report_output.text
        ('Es gibt eine Anzahl von Obsoleten Items die hier aufgefuert sind');
   db_report_output.html_table_start;
   db_report_output.html_table_header ('Name' || v_sep || 'Erklaerung');
   x := 0;

   FOR i IN (SELECT ITEM_TYPE.NAME, ITEM_TYPE.ERKLAERUNG
               FROM ITEM_TYPE 
              WHERE ITEM_TYPE.OBSOL = 'Y')
   LOOP
      -- alle obsoleten Trigger in der Auswahl.
      -- nun muessen dies auf den einzelnen wbenen gesucht werden.
      -- es gibt Form
      db_report_output.html_table (i.NAME || v_sep || i.erklaerung);
      -- block
      -- item
      x := 1;
   END LOOP;

   db_report_output.text ('</table>');
   db_report_output.br (2);
   db_report_output.text
                       ('Folgende Items  sind Obsolet');
   x := 0;

   FOR i IN (SELECT *
               FROM MOD_BLOCK_ITEM
              WHERE MOD_BLK_ITEM_TYPE in (select ITEM_TYPE.ID from ITEM_TYPE where ITEM_TYPE.OBSOL='Y'))
   LOOP
      -- item
      DECLARE
         x1   NUMBER (10) := 0;
      BEGIN
         -- es gibt Form
         db_report_output.text ('<b>Item Enbene Ebene: </b><br>');
         db_report_output.html_table_start;
         db_report_output.html_table_header (   'Modul Name'
                                             || v_sep
                                             || 'Block Name'
                                             || v_sep
                                             || 'Item Name'
                                            );
        
            db_report_output.html_table
               (   db_report_output.get_link
                      (tvd_information.get_html
                                      (tvd_information.get_modul_name (i.mod_id)
                                      ),
                       tvd_information.get_modul_name (i.mod_id)
                      )
                || v_sep
                || tvd_information.get_block_name (i.mod_blk_id)
                || v_sep
                || tvd_information.get_item_name (i.mod_blk_item_id)
                
               );
        
         db_report_output.text ('</table>');
      END;

     
   END LOOP;

  
   db_report_output.text ('</table>');
   db_report_output.br;
  
--   db_report_output.text (   '<p>Report wurde erstellt am: '
--                          || TO_CHAR (SYSDATE, 'DD.MM.RRRR HH24:MI:SS')
--                          || '</p>'
--                         );
--   db_report_output.text
--      ('<p class="footer"><a class="footer" href="mailto:jan.timmermann@trivadis.de">Jan-Peter Timmermann</a> 2010</p>'
--      );
--      
   db_report_output.absender_tvd;
   db_report_output.text ('  </body>');
   db_report_output.text ('</html>');
END;
/

SPOOL OFF