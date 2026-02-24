/* Formatted on 2006/12/22 08:26 (Formatter Plus v4.8.7) */
DEFINE PATH='&1'
DEFINE SCHEMA='%'


DEFINE FILENAME = &PATH/uebersicht.htm
DEFINE MOD_BETRACHTUNG  = script\betrachtung.sql
SET TERMOUT ON
PROMPT Erstelle uebersicht.htm ...
PROMPT
SET TERMOUT OFF
REM ##################################################################
REM Erstellen der uebersicht.htm
REM ##################################################################
SPOOL &FILENAME

DECLARE
  v_sep             VARCHAR2 (2)  := db_report_output.g_separator;

   CURSOR c_module
   IS
      SELECT DISTINCT mo.mod_name modul
                 FROM betroffen_daten b JOIN mod_trigger_src m
                      ON (m.mod_trg_src_id = b.ID)
                      JOIN module mo ON (mo.mod_id = m.mod_id)
      UNION
      SELECT DISTINCT mo.mod_name
                 FROM betroffen_daten b JOIN mod_block_trigger_source m
                      ON (b.ID = m.mod_blk_trg_src_id)
                      JOIN module mo ON (mo.mod_id = m.mod_id)
      UNION
      SELECT DISTINCT mo.mod_name
                 FROM betroffen_daten b JOIN mod_block_item_trigger_src m
                      ON (b.ID = m.mod_blk_ite_trg_src_id)
                      JOIN module mo ON (mo.mod_id = m.mod_id)
      UNION
      SELECT DISTINCT mo.mod_name
                 FROM betroffen_daten b JOIN mod_proc_src m
                      ON (b.ID = m.mod_prc_src_id)
                      JOIN module mo ON (mo.mod_id = m.mod_id)
             ORDER BY 1 asc;

     
BEGIN
   db_report_output.header('Forms Analyse Report V2.1 vom '||' - '||TO_CHAR(SYSDATE, 'DD.MM.RRRR HH24:MI:SS'));
   db_report_output.title(tvd_information.v_text);
   db_report_output.br;
   db_report_output.subtitle ('module', 'Module die betroffen sind');
   db_report_output.html_table_start;
   db_report_output.html_table_header (   'Modul'
                                       || v_sep
                                       || 'Modul Typ'
                                       || v_sep
                                       || 'Anzahl betroffener Zeilen'
                                       || v_sep
                                       || 'Betrachtung'									   
                                      );
   FOR c IN c_module
   LOOP
      db_report_output.html_table (   c.modul
                                   || v_sep
                                   || tvd_information.get_mod_typ (c.modul)
                                   || v_sep
                                   || tvd_information.get_zeilen_modul(c.modul)
                                   || v_sep
				|| db_report_output.get_link('mod_'||lower(c.modul)||'.htm', lower(c.modul)||'.htm')
                                  );
   END LOOP;
   db_report_output.html_table_end;
   DB_REPORT_OUTPUT.text('<br>');
   DB_REPORT_OUTPUT.text('<br>');
   DB_REPORT_OUTPUT.ABSCHLUSS;
END;
/

SPOOL OFF

SET TERMOUT ON
prompt Erstellen des betrachtung.sql.... 

SET TERMOUT OFF

 
SPOOL &MOD_BETRACHTUNG
DECLARE
   CURSOR c_module
   IS
      SELECT DISTINCT mo.mod_name modul
                 FROM betroffen_daten b JOIN mod_trigger_src m
                      ON (m.mod_trg_src_id = b.ID)
                      JOIN module mo ON (mo.mod_id = m.mod_id)
      UNION
      SELECT DISTINCT mo.mod_name
                 FROM betroffen_daten b JOIN mod_block_trigger_source m
                      ON (b.ID = m.mod_blk_trg_src_id)
                      JOIN module mo ON (mo.mod_id = m.mod_id)
      UNION
      SELECT DISTINCT mo.mod_name
                 FROM betroffen_daten b JOIN mod_block_item_trigger_src m
                      ON (b.ID = m.mod_blk_ite_trg_src_id)
                      JOIN module mo ON (mo.mod_id = m.mod_id)
      UNION
      SELECT DISTINCT mo.mod_name
                 FROM betroffen_daten b JOIN mod_proc_src m
                      ON (b.ID = m.mod_prc_src_id)
                      JOIN module mo ON (mo.mod_id = m.mod_id)
             ORDER BY 1 asc;
BEGIN
   FOR c IN c_module
   LOOP
    dbms_output.put_line('@@mod_'||lower(c.modul)||'.sql');
    tvd_information.erstelle_mod_modul_sql(c.modul);
   END LOOP;
END;
/

SPOOL OFF
