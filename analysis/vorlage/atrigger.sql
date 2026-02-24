/* Formatted on 2008/04/25 15:34 (Formatter Plus v4.8.8) */
DEFINE PATH='&1'
DEFINE SCHEMA='%'

DEFINE FILENAME = &PATH/atrigger.htm


SET TERMOUT ON
PROMPT Erstelle atrigger.htm ...
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
  
   v_sep                   VARCHAR2 (2)    := db_report_output.g_separator;
   x                       NUMBER (2)      := 0;
BEGIN
  db_report_output.header('Forms Analyse Report V2.0 vom '||' - '||TO_CHAR(SYSDATE, 'DD.MM.RRRR HH24:MI:SS'));
  db_report_output.title(tvd_information.v_text);
  db_report_output.text('<p>');
  db_report_output.text ('<table border="1"  width="100%" class="header">'); 
  db_report_output.text('<tr><td  colspan="6" align="center"><h1>Obsolete Triggere</h1></td></tr>');
  db_report_output.html_table_start;
  db_report_output.html_table_header ('Name' || v_sep || 'Ebene');
   x := 0;

   FOR i IN (SELECT *
               FROM obsolete_trigger ob
              WHERE ob.obso LIKE '%Y%')
   LOOP
      -- alle obsoleten Trigger in der Auswahl.
      -- nun muessen dies auf den einzelnen wbenen gesucht werden.
      -- es gibt Form
      db_report_output.html_table (i.NAME || v_sep || i.ebene);
      -- block
      -- item
      x := 1;
   END LOOP;
 db_report_output.html_table_end;
   IF x = 0
   THEN
      db_report_output.html_table ('Keine Daten' || v_sep || 'gefunden');
   END IF;

   db_report_output.text ('</table>');
   db_report_output.br (2);
   db_report_output.text
                       ('Folgende Module sind mit Obsoleten Triggern versehen');
   x := 0;

   FOR i IN (SELECT *
               FROM obsolete_trigger ob
              WHERE ob.obso LIKE '%Y%')
   LOOP
      DECLARE
         x1   NUMBER (10) := 0;
      BEGIN
         -- es gibt Form
         db_report_output.text ('<p><b>Forms Ebene: </b><br>');
         db_report_output.html_table_start;
         db_report_output.html_table_header (   'Modul Name'
                                             || v_sep
                                             || 'Trigger Name'
                                            );
         x1 := 0;

         FOR y IN (SELECT *
                     FROM mod_trigger
                    WHERE mod_trigger.mod_trg_name = i.NAME)
         LOOP
            db_report_output.html_table (y.mod_trg_name || v_sep || i.ebene);
            x1 := 1;
         END LOOP;

         IF x1 = 0
         THEN
            db_report_output.html_table ('Keine Daten' || v_sep || 'gefunden');
         END IF;

         db_report_output.text ('</table>');
      END;

      db_report_output.br (2);

      -- block
      DECLARE
         x1   NUMBER (10) := 0;
      BEGIN
         -- es gibt Form
         db_report_output.text ('<b>Block Enbene Ebene: </b><br>');
         db_report_output.html_table_start;
         db_report_output.html_table_header (   'Modul Name'
                                             || v_sep
                                             || 'Trigger Name'
                                            );
         x1 := 0;

         FOR y IN (SELECT *
                     FROM mod_block_trigger
                    WHERE mod_block_trigger.mod_blk_trg_name = i.NAME)
         LOOP
            db_report_output.html_table (y.mod_blk_trg_name || v_sep
                                         || i.ebene
                                        );
            x1 := 1;
         END LOOP;

         IF x1 = 0
         THEN
            db_report_output.html_table ('Keine Daten' || v_sep || 'gefunden');
         END IF;

         db_report_output.text ('</table>');
      END;

      db_report_output.br (2);

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
                                             || v_sep
                                             || 'Trigger Name'
                                            );
         x1 := 0;

         FOR y IN (SELECT *
                     FROM mod_block_item_trigger
                    WHERE mod_block_item_trigger.mod_blk_ite_trg_name = i.NAME)
         LOOP
            db_report_output.html_table
               (   db_report_output.get_link
                      (tvd_information.get_html
                                      (tvd_information.get_modul_name (y.mod_id)
                                      ),
                       tvd_information.get_modul_name (y.mod_id)
                      )
                || v_sep
                || tvd_information.get_block_name (y.mod_blk_id)
                || v_sep
                || tvd_information.get_item_name (y.mod_blk_item_id)
                || v_sep
                || y.mod_blk_ite_trg_name
               );
            x1 := 1;
         END LOOP;

         IF x1 = 0
         THEN
            db_report_output.html_table ('Keine Daten' || v_sep || 'gefunden');
         END IF;

         db_report_output.text ('</table>');
      END;

      x := 1;
   END LOOP;

   IF x = 0
   THEN
      db_report_output.html_table ('Keine Daten' || v_sep || 'gefunden');
   END IF;

   db_report_output.text ('</table>');
   db_report_output.br;
   
-- Trigger mit anderer auspraegung.
-- Es gibt trigger die duerfen jtetzt nicht mehr auf item ebene sein
   db_report_output.text ('<b>Trigger auf falscher Ebene: </b><br>');
   db_report_output.text
        ('Es gibt eine Anzahl von Triggern die nicht mehr auf Item Ebene sein duerfen');
   db_report_output.html_table_start;
   db_report_output.html_table_header ('Name' || v_sep || 'Ebene');
   x := 0;
  FOR i IN (SELECT *
               FROM obsolete_trigger ob
              WHERE ob.obso LIKE '%N%' and ob.ebene='ITEM') loop

      db_report_output.html_table (i.NAME || v_sep || i.ebene);
      -- block
      -- item
      x := 1;
end loop;
   db_report_output.text ('</table>');
   db_report_output.br;
 FOR i IN (SELECT *
               FROM obsolete_trigger ob
              WHERE ob.obso LIKE '%N%' and ob.ebene='ITEM') loop

      -- item
      x := 1;
      -- pruefen ob diese Trigger auf item ebene vorhanden sind
      DECLARE
         x1   NUMBER (10) := 0;
      BEGIN
         -- es gibt Form
         db_report_output.text ('<b>Trigger : '||i.Name||' </b><br>');
         db_report_output.html_table_start;
         db_report_output.html_table_header (   'Modul Name'
                                             || v_sep
                                             || 'Block Name'
                                             || v_sep
                                             || 'Item Name'
                                             || v_sep
                                             || 'Trigger Name'
                                            );
         x1 := 0;

         FOR y IN (SELECT *
                     FROM mod_block_item_trigger
                    WHERE mod_block_item_trigger.mod_blk_ite_trg_name = i.NAME)
         LOOP
            db_report_output.html_table
               (   db_report_output.get_link
                      (tvd_information.get_html
                                      (tvd_information.get_modul_name (y.mod_id)
                                      ),
                       tvd_information.get_modul_name (y.mod_id)
                      )
                || v_sep
                || tvd_information.get_block_name (y.mod_blk_id)
                || v_sep
                || tvd_information.get_item_name (y.mod_blk_item_id)
                || v_sep
                || y.mod_blk_ite_trg_name
               );
            x1 := 1;
         END LOOP;

         IF x1 = 0
         THEN
            db_report_output.html_table ('Keine Daten' || v_sep || 'gefunden');
         END IF;

         db_report_output.text ('</table>');
      END;



end loop;
  

   db_report_output.text ('</table>');
   db_report_output.br;


-- Das ganze auf Block ebene

-- Trigger mit anderer auspraegung.
-- Es gibt trigger die duerfen jtetzt nicht mehr auf item ebene sein
   db_report_output.text ('<b>Trigger auf falscher Ebene: </b><br>');
   db_report_output.text
        ('Es gibt eine Anzahl von Triggern die nicht mehr auf Block Ebene sein duerfen');
   db_report_output.html_table_start;
   db_report_output.html_table_header ('Name' || v_sep || 'Ebene');
   x := 0;
  FOR i IN (SELECT *
               FROM obsolete_trigger ob
              WHERE ob.obso LIKE '%N%' and ob.ebene='BLOCK') loop

      db_report_output.html_table (i.NAME || v_sep || i.ebene);
      -- block
      -- item
      x := 1;
end loop;
   db_report_output.text ('</table>');
   db_report_output.br;
 FOR i IN (SELECT *
               FROM obsolete_trigger ob
              WHERE ob.obso LIKE '%N%' and ob.ebene='BLOCK') loop

      -- item
      x := 1;
      -- pruefen ob diese Trigger auf item ebene vorhanden sind
      DECLARE
         x1   NUMBER (10) := 0;
      BEGIN
         -- es gibt Form
         db_report_output.text ('<b>Trigger : '||i.Name||' </b><br>');
         db_report_output.html_table_start;
         db_report_output.html_table_header (   'Modul Name'
                                             || v_sep
                                             || 'Block Name'
                                             || v_sep
                                             || 'Trigger Name'
                                            );
         x1 := 0;

         FOR y IN (SELECT *
                     FROM mod_block_trigger
                    WHERE mod_block_trigger.MOD_BLK_TRG_NAME = i.NAME)
         LOOP
            db_report_output.html_table
               (   db_report_output.get_link
                      (tvd_information.get_html
                                      (tvd_information.get_modul_name (y.mod_id)
                                      ),
                       tvd_information.get_modul_name (y.mod_id)
                      )
                || v_sep
                || tvd_information.get_block_name (y.mod_blk_id)
                || v_sep
                || y.mod_blk_trg_name
               );
            x1 := 1;
         END LOOP;

         IF x1 = 0
         THEN
            db_report_output.html_table ('Keine Daten' || v_sep || 'gefunden');
         END IF;

         db_report_output.text ('</table>');
      END;



end loop; 
  db_report_output.text ('</table>');
  DB_REPORT_OUTPUT.text('<br>');
  DB_REPORT_OUTPUT.text('<br>');
  DB_REPORT_OUTPUT.ABSCHLUSS;
END;
/

SPOOL OFF