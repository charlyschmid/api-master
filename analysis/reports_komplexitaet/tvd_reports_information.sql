set define off
prompt Creating package TVD_REPORTS_INFORMATION

create or replace package tvd_reports_information
is
   /**
    *<p><b>
    *   Trivadis Forms and Reports Analysis
    *   Get information from repository for Reports Module Analysis
    *</b></p>
    *
    *   @author Perry Pakull, Trivadis AG
    *   @version 1.0.0
    *   @since 02.06.2014
    *
    *<pre><b>
    *   Version   Date       Who      Description         </b>
    *
    *</pre>
    *@headcom
    */
   function get_mod_typ (p_mod_name in varchar2)
      return varchar2;

   function get_zeilen_modul (p_mod_name in varchar2)
      return number;

   function get_zeilen_suchstring (p_suchstring in varchar2)
      return number;

   function get_suchstring_ersetztung (p_suchstring in varchar2)
      return varchar2;

   function get_suchstring_loesung (p_suchstring in varchar2)
      return varchar2;

   procedure erstelle_mod_modul_sql (p_mod_name in varchar2);

   procedure erstelle_mod_such_sql (p_mod_such in varchar2);

   function get_anzahl_module (p_mod_typ in varchar2 default null)
      return varchar2;

   function get_anzahl_zeilen
      return varchar2;

   function get_anzahl_canvas
      return varchar2;

   function get_anzahl_stacked
      return varchar2;

   function get_anzahl_tab
      return varchar2;

   function get_anzahl_content
      return varchar2;

   function get_anzahl_fmb
      return varchar2;

   function get_anzahl_mmb
      return varchar2;

   function get_anzahl_pll
      return varchar2;

   function get_anzahl_rdf
      return varchar2;

   function get_betroffene_zeilen
      return varchar2;

   function get_anzahl_bloecke
      return varchar2;

   function get_html (
      p_mod_name                    in varchar2,
      p_prefix                      in varchar2 default 'mod_',
      p_suffix                      in varchar2 default '.htm'
   )
      return varchar2;

   procedure aktive_log_prc (p_loginfo in varchar2);

   function get_modul_name (p_mod_id in number)
      return varchar2;

   function get_block_name (p_mod_blk_id in number)
      return varchar2;

   function get_item_name (p_mod_blk_item_id in number)
      return varchar2;

   function header_text
      return varchar2;

   function get_option_number (p_name in varchar2)
      return number;

   function get_option_char (p_name in varchar2)
      return varchar2;

   function get_complex_value_application
      return varchar2;

   procedure erstelle_mod_modul_stat_sql (p_mod_name in varchar2);

   function get_complex_application_fbs
      return varchar2;

   procedure erstelle_modul_stat_fbs_sql (p_mod_name in varchar2);
end tvd_reports_information;
/

show errors
prompt Creating package body tvd_reports_information

create or replace package body tvd_reports_information
is
   /**
    * Get the module type from the repository for a given module name
    *
    * @param p_mod_name Given module name
    * @return varchar2 Module Type
    **/
   function get_mod_typ (p_mod_name in varchar2)
      return varchar2
   is
      l_value                        module.mod_typ%type;
   begin
      select mod_typ
        into l_value
        from module
       where mod_name = p_mod_name;
      return l_value;
   end get_mod_typ;

   function get_zeilen_modul (p_mod_name in varchar2)
      return number
   is
      l_value                        number (10) := 0;
   begin
      select count (*)
        into l_value
        from (select mo.mod_id, mo.mod_name
                from betroffen_daten b
                     join mod_trigger_src m
                        on (m.mod_trg_src_id = b.id)
                     join module mo
                        on (mo.mod_id = m.mod_id)
              union all
              select mo.mod_id, mo.mod_name
                from betroffen_daten b
                     join mod_block_trigger_source m
                        on (b.id = m.mod_blk_trg_src_id)
                     join module mo
                        on (mo.mod_id = m.mod_id)
              union all
              select mo.mod_id, mo.mod_name
                from betroffen_daten b
                     join mod_block_item_trigger_src m
                        on (b.id = m.mod_blk_ite_trg_src_id)
                     join module mo
                        on (mo.mod_id = m.mod_id)
              union all
              select mo.mod_id, mo.mod_name
                from betroffen_daten b
                     join mod_proc_src m
                        on (b.id = m.mod_prc_src_id)
                     join module mo
                        on (mo.mod_id = m.mod_id))
       where mod_name = p_mod_name;
      return l_value;
   end get_zeilen_modul;

   function get_zeilen_suchstring (p_suchstring in varchar2)
      return number
   is
      l_value                        number (10) := 0;
   begin
      select count (*)
        into l_value
        from betroffen_daten
       where betroffen_daten.suchstring = p_suchstring;
      return l_value;
   end get_zeilen_suchstring;

   function get_suchstring_ersetztung (p_suchstring in varchar2)
      return varchar2
   is
      l_value                        varchar2 (2000) := null;
   begin
      select distinct (beschreibung)
        into l_value
        from suchstring
       where suchstring.suchstring = p_suchstring;
      return l_value;
   end get_suchstring_ersetztung;

   function get_suchstring_loesung (p_suchstring in varchar2)
      return varchar2
   is
      l_value                        varchar2 (2000) := null;
   begin
      select loesung
        into l_value
        from suchstring
       where suchstring.suchstring = p_suchstring;
      return l_value;
   end get_suchstring_loesung;

   /**
    * Create SQL file for module
    *
    * @param p_mod_name Module name
    **/
   procedure erstelle_mod_modul_sql (p_mod_name in varchar2)
   is
      datei                          utl_file.file_type;
      l_mod_name                     module.mod_name%type;
      l_datei_typ                    module.mod_typ%type;
      l_datei_name                   varchar2 (32);
   begin
      l_mod_name := p_mod_name;
      l_datei_typ := tvd_reports_information.get_mod_typ (l_mod_name);
      l_datei_name := lower (replace (l_mod_name, '.', '_'));
      -- Open File
      datei := utl_file.fopen ('MOD_MODULE', 'mod_' || l_datei_name || '.sql', 'W');
      -- Dateien sind angelegt
      utl_file.put_line (datei, 'DEFINE PATH=''&1''');
      utl_file.put_line (datei, 'DEFINE FILENAME = &PATH/' || 'mod_' || l_datei_name || '.htm');
      utl_file.put_line (datei, 'SET TERMOUT ON');
      utl_file.put_line (datei, 'PROMPT Erstelle ' || 'mod_' || l_datei_name || '.htm ...');
      utl_file.put_line (datei, 'PROMPT');
      utl_file.put_line (datei, 'SET TERMOUT OFF');
      utl_file.put_line (datei, 'SPOOL &FILENAME');
      utl_file.put_line (datei, 'DECLARE');
      utl_file.put_line (datei, 'CURSOR Modul_trigger  IS');
      utl_file.put_line (datei, '  SELECT t.mod_trg_name, m.zeilen_nr, m.zeile');
      utl_file.put_line (datei, '    FROM betroffen_daten b ');
      utl_file.put_line (datei, '    JOIN mod_trigger_src m ON (m.mod_trg_src_id = b.ID)');
      utl_file.put_line (datei, '   JOIN mod_trigger t ON (m.mod_trg_id = t.mod_trg_id)');
      utl_file.put_line (datei, '   JOIN module mo ON (mo.mod_id = m.mod_id)');
      utl_file.put_line (datei, '  WHERE upper(mod_name) = UPPER (''' || l_mod_name || ''') order by 1,2;');
      --
      utl_file.put_line (datei, 'CURSOR Modul_blk_trigger  IS');
      utl_file.put_line (datei, '  SELECT t.mod_blk_trg_name, m.zeilen_nr, m.zeile,blk.mod_blk_name');
      utl_file.put_line (datei, '    FROM betroffen_daten b ');
      utl_file.put_line (datei, '    JOIN MOD_BLOCK_TRIGGER_SOURCE m    ON (m.MOD_BLK_TRG_SRC_ID = b.ID)');
      utl_file.put_line (datei, '   JOIN MOD_BLOCK_TRIGGER t ON (m.mod_blk_trg_id = t.mod_blk_trg_id)');
      utl_file.put_line (datei, '   JOIN MOD_BLOCK blk ON (blk.mod_blk_id = t.mod_blk_id)');
      utl_file.put_line (datei, '   JOIN module mo ON (mo.mod_id = m.mod_id)');
      utl_file.put_line (datei, '  WHERE upper(mod_name) = UPPER (''' || l_mod_name || ''') order by 4,1,2;');
      --
      utl_file.put_line (datei, 'CURSOR Modul_blk_ite_trigger  IS');
      utl_file.put_line (datei, '  SELECT t.mod_blk_ite_trg_name, m.zeilen_nr, m.zeile,blk.mod_blk_name,blki.mod_blk_item_name');
      utl_file.put_line (datei, '    FROM betroffen_daten b ');
      utl_file.put_line (datei, '    JOIN MOD_BLOCK_ITEM_TRIGGER_SRC m ON (m.MOD_BLK_ITE_TRG_SRC_ID = b.ID)');
      utl_file.put_line (datei, '   JOIN MOD_BLOCK_ITEM_TRIGGER t ON (m.mod_blk_ite_trg_id = t.mod_blk_ite_trg_id)');
      utl_file.put_line (datei, '   JOIN MOD_BLOCK_ITEM blkI ON (blkI.mod_blk_ITEM_id = t.mod_blk_ITEM_id)');
      utl_file.put_line (datei, '   JOIN MOD_BLOCK blk ON (blk.mod_blk_id = t.mod_blk_id)');
      utl_file.put_line (datei, '   JOIN module mo ON (mo.mod_id = m.mod_id)');
      utl_file.put_line (datei, '  WHERE upper(mod_name) = UPPER (''' || l_mod_name || ''');');
      --
      utl_file.put_line (datei, 'CURSOR Modul_proc  IS');
      utl_file.put_line (datei, '  SELECT t.mod_prc_name, m.zeilen_nr, m.zeile');
      utl_file.put_line (datei, '    FROM betroffen_daten b ');
      utl_file.put_line (datei, '    JOIN MOD_PROC_SRC m ON (m.MOD_PRC_SRC_ID = b.ID)');
      utl_file.put_line (datei, '   JOIN MOD_PROC t ON (m.MOD_PRC_ID = t.MOD_PRC_ID)');
      utl_file.put_line (datei, '   JOIN module mo ON (mo.mod_id = m.mod_id)');
      utl_file.put_line (datei, '  WHERE upper(mod_name) = UPPER (''' || l_mod_name || ''');');
      --
      utl_file.put_line (datei, ' l_sep   VARCHAR2 (2) := db_report_output.g_separator;');
      utl_file.put_line (datei, 'BEGIN');
      utl_file.put_line (datei, '--' || p_mod_name);
      utl_file.put_line (datei, 'db_report_output.header (''Forms Analyse Report V2.0 vom - ''||TO_CHAR (SYSDATE, ''DD.MM.RRRR HH24:MI:SS''));');
      utl_file.put_line (datei, 'db_report_output.title (''Uebersicht des Moduls : ''||''' || l_mod_name || ''');');
      utl_file.put_line (datei, 'db_report_output.anchor ('''', '''');');
      utl_file.put_line (datei, 'db_report_output.anchor ('''', '''');');
      utl_file.put_line (datei, 'db_report_output.br;');
      utl_file.put_line (datei, 'db_report_output.html_table_start;');
      utl_file.put_line (
         datei,
         'db_report_output.html_table_header ( ''Bereich''|| l_sep ||''Block Name''||l_sep||''Item Name''||l_sep||''Trigger / Progname''|| l_sep  || ''Zeilen Nr.''|| l_sep  || ''Zeile:'');'
      );
      utl_file.put_line (datei, 'FOR c IN modul_trigger');
      utl_file.put_line (datei, '       LOOP');
      utl_file.put_line (
         datei,
         'db_report_output.html_table (''Forms Trigger''|| l_sep||'' ''||l_sep||'' ''||l_sep ||c.mod_trg_name || l_sep||c.zeilen_nr || l_sep||c.zeile );'
      );
      utl_file.put_line (datei, ' END LOOP;');
      utl_file.put_line (datei, 'FOR c IN Modul_blk_trigger');
      utl_file.put_line (datei, '       LOOP');
      utl_file.put_line (
         datei,
         'db_report_output.html_table (''Block Trigger''|| l_sep ||c.mod_blk_name||l_sep||'' ''||l_sep||c.mod_blk_trg_name || l_sep||c.zeilen_nr || l_sep||c.zeile );'
      );
      utl_file.put_line (datei, ' END LOOP;');
      utl_file.put_line (datei, 'FOR c IN Modul_blk_ite_trigger');
      utl_file.put_line (datei, '       LOOP');
      utl_file.put_line (
         datei,
         'db_report_output.html_table (''Item Trigger''|| l_sep ||c.mod_blk_name||l_sep||c.mod_blk_item_name||l_sep||c.mod_blk_ite_trg_name || l_sep||c.zeilen_nr || l_sep||c.zeile );'
      );
      utl_file.put_line (datei, ' END LOOP;');
      --
      utl_file.put_line (datei, 'FOR c IN Modul_Proc');
      utl_file.put_line (datei, '       LOOP');
      utl_file.put_line (
         datei,
         'db_report_output.html_table (''Procedure''|| l_sep ||c.mod_prc_name||l_sep||'' ''||l_sep||'' ''|| l_sep||c.zeilen_nr || l_sep||c.zeile );'
      );
      utl_file.put_line (datei, ' END LOOP;');
      utl_file.put_line (datei, 'db_report_output.html_table_end;');
      utl_file.put_line (datei, 'DB_REPORT_OUTPUT.text(''<br>'');');
      utl_file.put_line (datei, 'DB_REPORT_OUTPUT.text(''<br>'');');
      utl_file.put_line (datei, 'DB_REPORT_OUTPUT.ABSCHLUSS;');
      utl_file.put_line (datei, 'END;');
      utl_file.put_line (datei, '/');
      utl_file.put_line (datei, 'SPOOL OFF');
      utl_file.fclose (datei);
   end;

   procedure erstelle_mod_such_sql (p_mod_such in varchar2)
   is
      datei                          utl_file.file_type;
      l_mod_such                     varchar2 (255) := rtrim (ltrim (lower (p_mod_such)));
   begin
      -- oeffnen der Datei
      datei := utl_file.fopen ('MOD_MODULE', 'mod_' || l_mod_such || '.sql', 'W');
      -- Dateien sind angelegt
      utl_file.put_line (datei, 'DEFINE PATH=''&1''');
      --  UTL_FILE.put_line (datei, 'DEFINE SCHEMA=''&2''');
      utl_file.put_line (datei, 'DEFINE FILENAME = &PATH/' || 'mod_' || l_mod_such || '.htm');
      utl_file.put_line (datei, 'SET TERMOUT ON');
      utl_file.put_line (datei, 'PROMPT Erstelle ' || 'mod_' || l_mod_such || '.htm ...');
      utl_file.put_line (datei, 'PROMPT');
      utl_file.put_line (datei, 'SET TERMOUT OFF');
      utl_file.put_line (datei, 'REM ##################################################################');
      utl_file.put_line (datei, 'REM Erstellen der uebersicht.htm');
      utl_file.put_line (datei, 'REM ##################################################################');
      utl_file.put_line (datei, 'SPOOL &FILENAME');
      utl_file.put_line (datei, 'DECLARE');
      -- erster Cursor
      utl_file.put_line (datei, 'CURSOR Modul_such  IS');
      utl_file.put_line (datei, '  SELECT MOD_NAME,TYP,BLOCKNAME,ITEMNAME,TRIGGER_NAME,ZEILEN_NR,ZEILE');
      utl_file.put_line (datei, '    FROM module_komplett b ');
      utl_file.put_line (datei, '  WHERE suchstring = UPPER (''' || p_mod_such || ''')');
      utl_file.put_line (datei, '  order by mod_id;');
      utl_file.put_line (datei, ' l_sep   VARCHAR2 (2) := db_report_output.g_separator;');
      utl_file.put_line (datei, 'BEGIN');
      utl_file.put_line (datei, 'db_report_output.header (''Forms Analyse Report vom - ''||TO_CHAR (SYSDATE, ''DD.MM.RRRR HH24:MI:SS''));');
      utl_file.put_line (datei, 'db_report_output.title (''Uebersicht des Build_Ins : ''||''' || p_mod_such || ''');');
      utl_file.put_line (datei, 'db_report_output.br;');
      utl_file.put_line (datei, 'db_report_output.html_table_start;');
      utl_file.put_line (
         datei,
         'db_report_output.html_table_header ( ''Modul Name''|| l_sep ||''Typ ''||l_sep||''Block''||l_sep||''ItemName''||l_sep||''Trigger / Progname''|| l_sep  || ''Zeilen Nr.''|| l_sep  || ''Zeile:'');'
      );
      utl_file.put_line (datei, 'FOR c IN modul_such');
      utl_file.put_line (datei, '       LOOP');
      -- '<a href="c.Mod_name">'||c.Mod_name||'</a>'
      utl_file.put_line (
         datei,
         'db_report_output.html_table (''<a href="''||tvd_reports_information.get_html (c.Mod_name)||''">''||c.mod_name ||''</a>''|| l_sep||c.typ||l_sep||c.blockname||l_sep||c.itemname||l_sep ||c.trigger_name || l_sep||c.zeilen_nr || l_sep||c.zeile );'
      );
      utl_file.put_line (datei, ' END LOOP;');
      utl_file.put_line (datei, 'db_report_output.html_table_end;');
      utl_file.put_line (datei, 'db_report_output.top;');
      utl_file.put_line (datei, 'db_report_output.absender_tvd;');
      utl_file.put_line (datei, 'db_report_output.footer;');
      utl_file.put_line (datei, 'END;');
      utl_file.put_line (datei, '/');
      utl_file.put_line (datei, 'SPOOL OFF');
      utl_file.fclose (datei);
   end erstelle_mod_such_sql;

   function get_anzahl_module (p_mod_typ in varchar2 default null)
      return varchar2
   is
      l_value                        varchar2 (20);
   begin
      if p_mod_typ is null
      then
         select to_char (count (mod_id)) into l_value from module;
      elsif p_mod_typ = 'FMB'
      then
         select to_char (count (mod_id))
           into l_value
           from module
          where mod_typ = 'FMB';
      elsif p_mod_typ = 'MMB'
      then
         select to_char (count (mod_id))
           into l_value
           from module
          where mod_typ = 'MMB';
      elsif p_mod_typ = 'PLL'
      then
         select to_char (count (mod_id))
           into l_value
           from module
          where mod_typ = 'PLL';
      elsif p_mod_typ = 'RDF'
      then
         select to_char (count (mod_id))
           into l_value
           from module
          where mod_typ = 'RDF';
      end if;
      return l_value;
   end;

   function get_anzahl_zeilen
      return varchar2
   is
      l_value                        varchar2 (20);
   begin
      select to_char (count (*)) into l_value from v_daten;
      return l_value;
   end;

   function get_anzahl_canvas
      return varchar2
   is
      l_value                        varchar2 (20);
   begin
      select to_char (count (*)) into l_value from mod_canvas;
      return l_value;
   end;

   function get_anzahl_stacked
      return varchar2
   is
      l_value                        varchar2 (20);
   begin
      select to_char (count (*))
        into l_value
        from mod_canvas
       where mod_canvas_subtyp = 1;
      return l_value;
   end;

   function get_anzahl_tab
      return varchar2
   is
      l_value                        varchar2 (20);
   begin
      select to_char (count (*))
        into l_value
        from mod_canvas
       where mod_canvas_subtyp = 4;
      return l_value;
   end;

   function get_anzahl_content
      return varchar2
   is
      l_value                        varchar2 (20);
   begin
      select to_char (count (*))
        into l_value
        from mod_canvas
       where mod_canvas_subtyp = 0;
      return l_value;
   end;

   function get_anzahl_fmb
      return varchar2
   is
      l_value                        varchar2 (20);
   begin
      select to_char (count (*))
        into l_value
        from module
       where mod_typ = 'FMB';
      return l_value;
   end;

   function get_anzahl_mmb
      return varchar2
   is
      l_value                        varchar2 (20);
   begin
      select to_char (count (*))
        into l_value
        from module
       where mod_typ = 'MMB';
      return l_value;
   end;

   function get_anzahl_pll
      return varchar2
   is
      l_value                        varchar2 (20);
   begin
      select to_char (count (*))
        into l_value
        from module
       where mod_typ = 'PLL';
      return l_value;
   end;

   function get_anzahl_rdf
      return varchar2
   is
      l_value                        varchar2 (20);
   begin
      select to_char (count (*))
        into l_value
        from module
       where mod_typ = 'RDF';
      return l_value;
   end;

   function get_betroffene_zeilen
      return varchar2
   is
      l_value                        varchar2 (20);
   begin
      select to_char (count (*)) into l_value from betroffen_daten;
      return l_value;
   end;

   function get_anzahl_bloecke
      return varchar2
   is
      l_value                        varchar2 (20);
   begin
      select to_char (count (*)) into l_value from mod_block;
      return l_value;
   end;

   function get_html (
      p_mod_name                    in varchar2,
      p_prefix                      in varchar2 default 'mod_',
      p_suffix                      in varchar2 default '.htm'
   )
      return varchar2
   is
   begin
      return p_prefix || lower (replace (p_mod_name, '.', '_')) || p_suffix;
   end;

   procedure aktive_log_prc (p_loginfo in varchar2)
   is
      pragma autonomous_transaction;
   begin
      insert into aktions_log (
                     id,
                     loginformation
                  )
      values (
                aktive_log_seq.nextval,
                p_loginfo
             );
      commit;
   end;

   function get_modul_name (p_mod_id in number)
      return varchar2
   is
      l_value                        varchar2 (255);
   begin
      select mod_name
        into l_value
        from module
       where module.mod_id = p_mod_id;
      return l_value;
   exception
      when no_data_found
      then
         return ' ';
   end get_modul_name;

   function get_block_name (p_mod_blk_id in number)
      return varchar2
   is
      l_value                        varchar2 (255);
   begin
      select mod_blk_name
        into l_value
        from mod_block
       where mod_block.mod_blk_id = p_mod_blk_id;
      return l_value;
   end get_block_name;

   function get_item_name (p_mod_blk_item_id in number)
      return varchar2
   is
      l_value                        varchar2 (255);
   begin
      select mod_blk_item_name
        into l_value
        from mod_block_item
       where mod_block_item.mod_blk_item_id = p_mod_blk_item_id;
      return l_value;
   end;

   function header_text
      return varchar2
   is
   begin
      return 'Analyse Reports Module Version 1.0';
   end header_text;

   function get_option_number (p_name in varchar2)
      return number
   is
      l_value                        optionen.wertn%type;
   begin
      select wertn
        into l_value
        from optionen
       where optionen.name = upper (p_name);
      return l_value;
   exception
      when others
      then
         return 0;
   end get_option_number;

   function get_option_char (p_name in varchar2)
      return varchar2
   is
      l_value                        optionen.wert%type;
   begin
      select wert
        into l_value
        from optionen
       where optionen.name = upper (p_name);
      return l_value;
   exception
      when others
      then
         return null;
   end get_option_char;

   function get_complex_value_application
      return varchar2
   is
      l_value                        number (4);
   begin
      select round (avg (complexity), 1) avg_app_modul_complexity
        into l_value
        from (select a.mod_id, sum (a.complexity) complexity
                from reports_modul_complexity_view a
              group by a.mod_id);
      return l_value;
   exception
      when others
      then
         return null;
   end get_complex_value_application;

   procedure erstelle_mod_modul_stat_sql (p_mod_name in varchar2)
   is
      datei                          utl_file.file_type;
      l_mod_name                     module.mod_name%type;
      l_datei_typ                    module.mod_typ%type;
      l_datei_name                   varchar2 (32);
   begin
      l_mod_name := p_mod_name;
      l_datei_typ := tvd_reports_information.get_mod_typ (l_mod_name);
      l_datei_name := lower (replace (l_mod_name, '.', '_'));
      datei := utl_file.fopen ('MOD_MODULE', 'mod_stat_' || l_datei_name || '.sql', 'W');
      -- Dateien sind angelegt
      utl_file.put_line (datei, 'DEFINE PATH=''&1''');
      utl_file.put_line (datei, 'DEFINE FILENAME = &PATH/' || 'mod_stat_' || l_datei_name || '.htm');
      utl_file.put_line (datei, 'SET TERMOUT ON');
      utl_file.put_line (datei, 'PROMPT Erstelle ' || 'mod_stat_' || l_datei_name || '.htm ...');
      utl_file.put_line (datei, 'PROMPT');
      utl_file.put_line (datei, 'SET TERMOUT OFF');
      utl_file.put_line (datei, 'SPOOL &FILENAME');
      utl_file.put_line (datei, 'DECLARE');
      utl_file.put_line (datei, '   cursor c_module is');
      utl_file.put_line (datei, '        select rmc.object_description, ');
      utl_file.put_line (datei, '               rmc.statistic_value, ');
      utl_file.put_line (datei, '               round (rmc.complexity, 2) complexity ');
      utl_file.put_line (datei, '          from reports_modul_complexity_view rmc');
      utl_file.put_line (datei, '         where rmc.mod_name = ''' || p_mod_name || '''');
      utl_file.put_line (datei, '      order by rmc.rss_id;');
      utl_file.put_line (datei, '   --');
      utl_file.put_line (datei, '   l_sep   VARCHAR2 (2) := db_report_output.g_separator;');
      utl_file.put_line (datei, '   l_modul_complexity   number(20);');
      utl_file.put_line (datei, '   --');
      utl_file.put_line (datei, '   l_srclenall                    reports_statistic.statistic_value%type;');
      utl_file.put_line (datei, '   l_srclencode                   reports_statistic.statistic_value%type;');
      utl_file.put_line (datei, '   l_srclencomments               reports_statistic.statistic_value%type;');
      utl_file.put_line (datei, '   l_srclencode_pct               number (20);');
      utl_file.put_line (datei, '   l_srclencomments_pct           number (20);');
      utl_file.put_line (datei, '   --');
      utl_file.put_line (datei, '   l_stmtplsql                    reports_statistic.statistic_value%type;');
      utl_file.put_line (datei, '   l_stmtselect                   reports_statistic.statistic_value%type;');
      utl_file.put_line (datei, '   l_stmtinsert                   reports_statistic.statistic_value%type;');
      utl_file.put_line (datei, '   l_stmtupdate                   reports_statistic.statistic_value%type;');
      utl_file.put_line (datei, '   l_stmtdelete                   reports_statistic.statistic_value%type;');
      utl_file.put_line (datei, '   l_stmtread                     reports_statistic.statistic_value%type;');
      utl_file.put_line (datei, '   l_stmtwrite                    reports_statistic.statistic_value%type;');
      utl_file.put_line (datei, '   l_stmtread_pct                 number (20);');
      utl_file.put_line (datei, '   l_stmtwrite_pct                number (20);');
      utl_file.put_line (datei, '   l_stmt_pct                     number (20);');
      utl_file.put_line (datei, '   --');
      utl_file.put_line (datei, '   l_statframes                   reports_statistic.statistic_value%type;');
      utl_file.put_line (datei, '   l_repframes                    reports_statistic.statistic_value%type;');
      utl_file.put_line (datei, '   l_frames                       reports_statistic.statistic_value%type;');
      utl_file.put_line (datei, '   l_statframes_pct               number (20);');
      utl_file.put_line (datei, '   l_repframes_pct                number (20);');
      utl_file.put_line (datei, '   --');
      utl_file.put_line (datei, '   type appvalues_array is table of reports_statistic.statistic_value%type');
      utl_file.put_line (datei, '                              index by varchar2 (50);');
      utl_file.put_line (datei, '   t_appvalues                    appvalues_array;');
      utl_file.put_line (datei, 'BEGIN');
      utl_file.put_line (datei, '   --' || p_mod_name);
      utl_file.put_line (datei, '   select round (sum (rc.complexity), 2) complexity');
      utl_file.put_line (datei, '     into l_modul_complexity');
      utl_file.put_line (datei, '     from reports_modul_complexity_view rc');
      utl_file.put_line (datei, '    where rc.mod_name = ''' || p_mod_name || ''';');
      utl_file.put_line (datei, '   --');
      utl_file.put_line (datei, '   for r_app in (select rmc.object_name, rmc.statistic_value');
      utl_file.put_line (datei, '                   from reports_modul_complexity_view rmc');
      utl_file.put_line (datei, '                  where rmc.mod_name = ''' || p_mod_name || ''')');
      utl_file.put_line (datei, '   loop');
      utl_file.put_line (datei, '      t_appvalues (r_app.object_name) := r_app.statistic_value;');
      utl_file.put_line (datei, '   end loop;');
      utl_file.put_line (datei, '   --');
      utl_file.put_line (datei, '   l_srclenall := t_appvalues (''SRCLENALL'');');
      utl_file.put_line (datei, '   l_srclencode := t_appvalues (''SRCLENCODE'');');
      utl_file.put_line (datei, '   l_srclencomments := t_appvalues (''SRCLENCOMMENTS'');');
      utl_file.put_line (datei, '   l_srclencode_pct := round ( (l_srclencode / l_srclenall * 100), 0);');
      utl_file.put_line (datei, '   l_srclencomments_pct := round ( (l_srclencomments / l_srclenall * 100), 0);');
      utl_file.put_line (datei, '   --');
      utl_file.put_line (datei, '   l_stmtplsql := t_appvalues (''STMTPLSQL'');');
      utl_file.put_line (datei, '   l_stmtselect := t_appvalues (''STMTSELECT'');');
      utl_file.put_line (datei, '   l_stmtinsert := t_appvalues (''STMTINSERT'');');
      utl_file.put_line (datei, '   l_stmtupdate := t_appvalues (''STMTUPDATE'');');
      utl_file.put_line (datei, '   l_stmtdelete := t_appvalues (''STMTDELETE'');');
      utl_file.put_line (datei, '   l_stmtread := l_stmtselect;');
      utl_file.put_line (datei, '   l_stmtwrite := l_stmtinsert + l_stmtupdate + l_stmtdelete;');
      utl_file.put_line (datei, '   l_stmtread_pct := round ( (l_stmtread / l_stmtplsql * 100), 0);');
      utl_file.put_line (datei, '   l_stmtwrite_pct := round ( (l_stmtwrite / l_stmtplsql * 100), 0);');
      utl_file.put_line (datei, '   l_stmt_pct := round ( ( (l_stmtplsql - (l_stmtread + l_stmtwrite)) / l_stmtplsql * 100), 0);');
      utl_file.put_line (datei, '   --');
      utl_file.put_line (datei, '   l_statframes := t_appvalues (''STATFRAME'');');
      utl_file.put_line (datei, '   l_repframes := t_appvalues (''REPFRAME'');');
      utl_file.put_line (datei, '   l_frames := l_statframes + l_repframes;');
      utl_file.put_line (datei, '   l_statframes_pct := round ( (l_statframes / l_frames * 100), 0);');
      utl_file.put_line (datei, '   l_repframes_pct := round ( (l_repframes / l_frames * 100), 0);');
      utl_file.put_line (datei, '   --');
      utl_file.put_line (datei, '   db_report_output.headerj (''Reports Analyse Report Version 1.0 vom - ''||TO_CHAR (SYSDATE, ''DD.MM.RRRR HH24:MI:SS''));');
      utl_file.put_line (datei, '   db_report_output.title(tvd_reports_information.header_text);');
      utl_file.put_line (datei, '   db_report_output.subtitle (''anzahl'', ''Komplexität Standard Modul ''||upper(''' || p_mod_name || '''));');
      utl_file.put_line (datei, '   db_report_output.text (''<table border="1"  width="100%" class="header">'');');
      utl_file.put_line (datei, '   if l_modul_complexity between 35 and 60 then');
      utl_file.put_line (datei, '      db_report_output.text(''<td  bgcolor="#FFF000" width="60%" colspan="2" align="center">'');');
      utl_file.put_line (datei, '   elsif l_modul_complexity > 60 then');
      utl_file.put_line (datei, '      db_report_output.text(''<td  bgcolor="#FF0000" width="60%" colspan="2" align="center">'');');
      utl_file.put_line (datei, '   else');
      utl_file.put_line (datei, '      db_report_output.text(''<td  bgcolor="#00FF00" width="60%" colspan="2" align="center">'');');
      utl_file.put_line (datei, '   end if;');
      utl_file.put_line (datei, '   db_report_output.text (''<b><font size="7">''||l_modul_complexity||''%</font></b><br>'');');
      utl_file.put_line (datei, '   db_report_output.text(''</td>'');');
      utl_file.put_line (datei, '   db_report_output.text(''<td  width="40%" colspan="2" align="center">'');');
      utl_file.put_line (datei, '   db_report_output.text (''<b>Komplexitätszusammensetzung</b><br>'');');
      utl_file.put_line (datei, '   db_report_output.html_table_start;');
      utl_file.put_line (
         datei,
         '   db_report_output.html_table_header (''Merkmal'' || l_sep || ''gew. Komplexität in Prozent''|| l_sep || ''Anzahl im Modul'');'
      );
      utl_file.put_line (datei, '   for c in c_module loop');
      utl_file.put_line (datei, '       db_report_output.html_table (c.object_description');
      utl_file.put_line (datei, '                                 || l_sep');
      utl_file.put_line (datei, '                                 || to_char(c.complexity,''90D0'')');
      utl_file.put_line (datei, '                                 || l_sep');
      utl_file.put_line (datei, '                                 || to_char(c.statistic_value)');
      utl_file.put_line (datei, '                                );');
      utl_file.put_line (datei, '   end loop;');
      utl_file.put_line (datei, '   db_report_output.html_table_end;');
      utl_file.put_line (datei, '   db_report_output.text(''</td>'');');
      utl_file.put_line (datei, '   db_report_output.html_table_end;');
      utl_file.put_line (datei, '   --');
      utl_file.put_line (datei, '   db_report_output.subtitle (''anzahl'', ''Dokumentation im Code'');');
      utl_file.put_line (datei, '   db_report_output.text (''<table border="1"  width="100%" class="header">'');');
      utl_file.put_line (datei, '   db_report_output.text(''<td width="60%" colspan="2" align="center">'');');
      utl_file.put_line (datei, '   db_report_output.text(''<div id="doku" style="width:600px;height:300px;"></div>''); ');
      utl_file.put_line (datei, '   db_report_output.text(''</td>'');');
      utl_file.put_line (datei, '   db_report_output.text(''<td width="40%" colspan="2" align="center">'');');
      utl_file.put_line (datei, '   db_report_output.html_table_start;');
      utl_file.put_line (datei, '   db_report_output.html_table_header (''Merkmal'' || l_sep || ''Anzahl'');');
      utl_file.put_line (datei, '   db_report_output.html_table (   ''Gesamtlänge Sourcecode''');
      utl_file.put_line (datei, '                                 || l_sep');
      utl_file.put_line (datei, '                                 || l_srclenall');
      utl_file.put_line (datei, '                                );');
      utl_file.put_line (datei, '   db_report_output.html_table (   ''davon Kommentare''');
      utl_file.put_line (datei, '                                 || l_sep');
      utl_file.put_line (datei, '                                 || l_srclencomments');
      utl_file.put_line (datei, '                                );');
      utl_file.put_line (datei, '   db_report_output.html_table_end;');
      utl_file.put_line (datei, '   db_report_output.text(''</td>'');');
      utl_file.put_line (datei, '   db_report_output.text (''</table>''); ');
      utl_file.put_line (datei, '   db_report_output.subtitle (''anzahl'', ''Datenbankzugriff im Code'');');
      utl_file.put_line (datei, '   db_report_output.text (''<table border="1"  width="100%" class="header">'');');
      utl_file.put_line (datei, '   db_report_output.text(''<td width="60%" colspan="2" align="center">'');');
      utl_file.put_line (datei, '   db_report_output.text(''<div id="dbc" style="width:600px;height:300px;"></div>'');');
      utl_file.put_line (datei, '   db_report_output.text(''</td>'');');
      utl_file.put_line (datei, '   db_report_output.text(''<td width="40%" colspan="2" align="center">'');');
      utl_file.put_line (datei, '   db_report_output.html_table_start;');
      utl_file.put_line (datei, '   db_report_output.html_table_header (''Merkmal'' || l_sep || ''Anzahl'');');
      utl_file.put_line (datei, '   db_report_output.html_table (   ''Gesamtmenge Statements''');
      utl_file.put_line (datei, '                                 || l_sep');
      utl_file.put_line (datei, '                                 || l_stmtplsql');
      utl_file.put_line (datei, '                                );');
      utl_file.put_line (datei, '   db_report_output.html_table (   ''Datenbankzugriffe schreibend''');
      utl_file.put_line (datei, '                                 || l_sep');
      utl_file.put_line (datei, '                                 || l_stmtwrite');
      utl_file.put_line (datei, '                                );');
      utl_file.put_line (datei, '   db_report_output.html_table (   ''Datenbankzugriffe lesend''');
      utl_file.put_line (datei, '                                 || l_sep');
      utl_file.put_line (datei, '                                 || l_stmtread');
      utl_file.put_line (datei, '                                );');
      utl_file.put_line (datei, '   db_report_output.html_table_end;');
      utl_file.put_line (datei, '   db_report_output.text(''</td>'');');
      utl_file.put_line (datei, '   db_report_output.text (''</table>''); ');
      utl_file.put_line (datei, '   db_report_output.subtitle (''anzahl'', ''Layout Frames'');');
      utl_file.put_line (datei, '   db_report_output.text (''<table border="1"  width="100%" class="header">'');');
      utl_file.put_line (datei, '   db_report_output.text(''<td width="60%" colspan="2" align="center">'');');
      utl_file.put_line (datei, '   db_report_output.text(''<div id="dbb" style="width:600px;height:300px;"></div>'');');
      utl_file.put_line (datei, '   db_report_output.text(''</td>'');');
      utl_file.put_line (datei, '   db_report_output.text(''<td width="40%" colspan="2" align="center">'');');
      utl_file.put_line (datei, '   db_report_output.html_table_start;');
      utl_file.put_line (datei, '   db_report_output.html_table_header (''Merkmal'' || l_sep || ''Anzahl'');');
      utl_file.put_line (datei, '   db_report_output.html_table (   ''Gesamtmenge Frames''');
      utl_file.put_line (datei, '                                 || l_sep');
      utl_file.put_line (datei, '                                 || l_frames');
      utl_file.put_line (datei, '                                );');
      utl_file.put_line (datei, '   db_report_output.html_table (   ''Statische Frames''');
      utl_file.put_line (datei, '                                 || l_sep');
      utl_file.put_line (datei, '                                 || l_statframes');
      utl_file.put_line (datei, '                                );');
      utl_file.put_line (datei, '   db_report_output.html_table (   ''Repeating Frames''');
      utl_file.put_line (datei, '                                 || l_sep');
      utl_file.put_line (datei, '                                 || l_repframes');
      utl_file.put_line (datei, '                                );');
      utl_file.put_line (datei, '   db_report_output.html_table_end;');
      utl_file.put_line (datei, '   db_report_output.text(''</td>'');');
      utl_file.put_line (datei, '   db_report_output.text (''</table>'');');
      utl_file.put_line (datei, '   DB_REPORT_OUTPUT.text(''<br>'');');
      utl_file.put_line (datei, '   DB_REPORT_OUTPUT.text(''<br>'');');
      utl_file.put_line (datei, '   DB_REPORT_OUTPUT.ABSCHLUSS;');
      --
      -- Javascript Part
      --
      utl_file.put_line (datei, 'db_report_output.text(''<script id="source">'');');
      utl_file.put_line (datei, 'db_report_output.text(''    var data_doku = ['');');
      utl_file.put_line (datei, 'db_report_output.text(''        { label: "Dokumentation",  data: ''||to_char (l_srclencomments_pct)||''},'');');
      utl_file.put_line (datei, 'db_report_output.text(''        { label: "Sourcecode",  data: ''||to_char (l_srclencode_pct)||''}'');');
      utl_file.put_line (datei, 'db_report_output.text(''    ];'');');
      utl_file.put_line (datei, 'db_report_output.text(''    $.plot($("#doku"), data_doku, '');');
      utl_file.put_line (datei, 'db_report_output.text(''    {'');');
      utl_file.put_line (datei, 'db_report_output.text(''        series: {'');');
      utl_file.put_line (datei, 'db_report_output.text(''            pie: { '');');
      utl_file.put_line (datei, 'db_report_output.text(''                show: true,'');');
      utl_file.put_line (datei, 'db_report_output.text(''                radius: 1,'');');
      utl_file.put_line (datei, 'db_report_output.text(''                label: {'');');
      utl_file.put_line (datei, 'db_report_output.text(''                    show: true,'');');
      utl_file.put_line (datei, 'db_report_output.text(''                    radius: 1,'');');
      utl_file.put_line (datei, 'db_report_output.text(''                    formatter: function(label, series){'');');
      utl_file.put_line (datei, 'db_report_output.text(''return ''''<div style="font-size:8pt;text-align:center;padding:2px;color:black;">'''''');');
      utl_file.put_line (datei, 'db_report_output.text(''+label+''''<br/>''''+Math.round(series.percent)+''''%</div>'''';'');');
      utl_file.put_line (datei, 'db_report_output.text(''                    },'');');
      utl_file.put_line (datei, 'db_report_output.text(''                    background: { opacity: 0.8 }'');');
      utl_file.put_line (datei, 'db_report_output.text(''                }'');');
      utl_file.put_line (datei, 'db_report_output.text(''            }'');');
      utl_file.put_line (datei, 'db_report_output.text(''        },'');');
      utl_file.put_line (datei, 'db_report_output.text(''        legend: {'');');
      utl_file.put_line (datei, 'db_report_output.text(''            show: false'');');
      utl_file.put_line (datei, 'db_report_output.text(''        }'');');
      utl_file.put_line (datei, 'db_report_output.text(''    });'');');

      utl_file.put_line (datei, 'db_report_output.text(''    var data_dbc = ['');');
      utl_file.put_line (datei, 'db_report_output.text(''        { label: "schreibend",  data: ''||to_char (l_stmtwrite_pct)||''},'');');
      utl_file.put_line (datei, 'db_report_output.text(''        { label: "lesend",  data: ''||to_char (l_stmtread_pct)||''},'');');
      utl_file.put_line (datei, 'db_report_output.text(''        { label: "PL/SQL Statements",  data: ''||to_char (l_stmt_pct)||''}'');');
      utl_file.put_line (datei, 'db_report_output.text(''    ];'');');
      utl_file.put_line (datei, 'db_report_output.text(''    $.plot($("#dbc"), data_dbc, '');');
      utl_file.put_line (datei, 'db_report_output.text(''    {'');');
      utl_file.put_line (datei, 'db_report_output.text(''        series: {'');');
      utl_file.put_line (datei, 'db_report_output.text(''            pie: { '');');
      utl_file.put_line (datei, 'db_report_output.text(''                show: true,'');');
      utl_file.put_line (datei, 'db_report_output.text(''                radius: 1,'');');
      utl_file.put_line (datei, 'db_report_output.text(''                label: {'');');
      utl_file.put_line (datei, 'db_report_output.text(''                    show: true,'');');
      utl_file.put_line (datei, 'db_report_output.text(''                    radius: 1,'');');
      utl_file.put_line (datei, 'db_report_output.text(''                    formatter: function(label, series){'');');
      utl_file.put_line (datei, 'db_report_output.text(''return ''''<div style="font-size:8pt;text-align:center;padding:2px;color:black;">'''''');');
      utl_file.put_line (datei, 'db_report_output.text(''+label+''''<br/>''''+Math.round(series.percent)+''''%</div>'''';'');');
      utl_file.put_line (datei, 'db_report_output.text(''                    },'');');
      utl_file.put_line (datei, 'db_report_output.text(''                    background: { opacity: 0.8 }'');');
      utl_file.put_line (datei, 'db_report_output.text(''                }'');');
      utl_file.put_line (datei, 'db_report_output.text(''            }'');');
      utl_file.put_line (datei, 'db_report_output.text(''        },'');');
      utl_file.put_line (datei, 'db_report_output.text(''        legend: {'');');
      utl_file.put_line (datei, 'db_report_output.text(''            show: false'');');
      utl_file.put_line (datei, 'db_report_output.text(''        }'');');
      utl_file.put_line (datei, 'db_report_output.text(''    });'');');

      utl_file.put_line (datei, 'db_report_output.text(''    var data_dbb = ['');');
      utl_file.put_line (datei, 'db_report_output.text(''        { label: "Statische Frames",  data: ''||to_char (l_statframes_pct)||''},'');');
      utl_file.put_line (datei, 'db_report_output.text(''        { label: "Repeating Frames",  data: ''||to_char (l_repframes_pct)||''}'');');
      utl_file.put_line (datei, 'db_report_output.text(''    ];'');');
      utl_file.put_line (datei, 'db_report_output.text(''    $.plot($("#dbb"), data_dbb, '');');
      utl_file.put_line (datei, 'db_report_output.text(''    {'');');
      utl_file.put_line (datei, 'db_report_output.text(''        series: {'');');
      utl_file.put_line (datei, 'db_report_output.text(''            pie: { '');');
      utl_file.put_line (datei, 'db_report_output.text(''                show: true,'');');
      utl_file.put_line (datei, 'db_report_output.text(''                radius: 1,'');');
      utl_file.put_line (datei, 'db_report_output.text(''                label: {'');');
      utl_file.put_line (datei, 'db_report_output.text(''                    show: true,'');');
      utl_file.put_line (datei, 'db_report_output.text(''                    radius: 1,'');');
      utl_file.put_line (datei, 'db_report_output.text(''                    formatter: function(label, series){'');');
      utl_file.put_line (datei, 'db_report_output.text(''return ''''<div style="font-size:8pt;text-align:center;padding:2px;color:black;">'''''');');
      utl_file.put_line (datei, 'db_report_output.text(''+label+''''<br/>''''+Math.round(series.percent)+''''%</div>'''';'');');
      utl_file.put_line (datei, 'db_report_output.text(''                    },'');');
      utl_file.put_line (datei, 'db_report_output.text(''                    background: { opacity: 0.8 }'');');
      utl_file.put_line (datei, 'db_report_output.text(''                }'');');
      utl_file.put_line (datei, 'db_report_output.text(''            }'');');
      utl_file.put_line (datei, 'db_report_output.text(''        },'');');
      utl_file.put_line (datei, 'db_report_output.text(''       legend: {'');');
      utl_file.put_line (datei, 'db_report_output.text(''            show: false'');');
      utl_file.put_line (datei, 'db_report_output.text(''        }'');');
      utl_file.put_line (datei, 'db_report_output.text(''    });'');');
      utl_file.put_line (datei, 'db_report_output.text(''</script>'');');

      utl_file.put_line (datei, 'END;');
      utl_file.put_line (datei, '/');
      utl_file.put_line (datei, 'SPOOL OFF');
      utl_file.fclose (datei);
   end erstelle_mod_modul_stat_sql;

   function get_complex_application_fbs
      return varchar2
   is
      l_value                        number (4);
   begin
      select round (avg (modul_gesammt)) into l_value from module_stat_fbs;
      return l_value;
   exception
      when others
      then
         return null;
   end;

   procedure erstelle_modul_stat_fbs_sql (p_mod_name in varchar2)
   is
      datei                          utl_file.file_type;
      l_mod_name                     module.mod_name%type;
      l_datei_typ                    module.mod_typ%type;
      l_datei_name                   varchar2 (32);
   begin
      l_mod_name := p_mod_name;
      l_datei_typ := tvd_reports_information.get_mod_typ (l_mod_name);
      l_datei_name := lower (replace (l_mod_name, '.', '_'));
      -- Open File
      datei := utl_file.fopen ('MOD_MODULE', 'mod_stat_fbs_' || l_datei_name || '.sql', 'W');
      -- Write statements
      utl_file.put_line (datei, 'DEFINE PATH=''&1''');
      utl_file.put_line (datei, 'DEFINE FILENAME = &PATH/' || 'mod_stat_fbs_' || l_datei_name || '.htm');
      utl_file.put_line (datei, 'SET TERMOUT ON');
      utl_file.put_line (datei, 'PROMPT Erstelle ' || 'mod_stat_fbs_' || l_datei_name || '.htm ...');
      utl_file.put_line (datei, 'PROMPT');
      utl_file.put_line (datei, 'SET TERMOUT OFF');
      utl_file.put_line (datei, 'REM ##################################################################');
      utl_file.put_line (datei, 'REM Erstellen der einzelnen HTML Seiten.htm');
      utl_file.put_line (datei, 'REM ##################################################################');
      utl_file.put_line (datei, 'SPOOL &FILENAME');
      utl_file.put_line (datei, 'DECLARE');
      utl_file.put_line (datei, '  cursor c_module');
      utl_file.put_line (datei, '    IS');
      utl_file.put_line (datei, '        select');
      utl_file.put_line (datei, '        m.mod_name');
      utl_file.put_line (datei, '        , ms.* ');
      utl_file.put_line (datei, '        , MDS.MDS_ITEMS');
      utl_file.put_line (datei, '        , MDS.MDS_LIBRARIES');
      utl_file.put_line (datei, '        , MDS.MDS_BLOCKS');
      utl_file.put_line (datei, '        , MDS.MDS_CANVASES');
      utl_file.put_line (datei, '        , MDS.MDS_WINDOWS');
      utl_file.put_line (datei, '        , MDS.MDS_VA');
      utl_file.put_line (datei, '        , MDS.MDS_PARAMETERS');
      utl_file.put_line (datei, '        , MDS.MDS_LOVS');
      utl_file.put_line (datei, '        , MDS.MDS_MENUS');
      utl_file.put_line (datei, '        , MDS.MDS_OBJECT_GROUPS');
      utl_file.put_line (datei, '        , MDS.MDS_PROGRAM_UNIT');
      utl_file.put_line (datei, '        , MDS.MDS_RECORD_GROUPS');
      utl_file.put_line (datei, '        , MDS.MDS_SOURCECODE_LENGTH');
      utl_file.put_line (datei, '        , MDS.MDS_COMMENT_LENGTH');
      utl_file.put_line (datei, '        , MDS.MDS_STATEMENTS');
      utl_file.put_line (datei, '        , MDS.MDS_UPDATE_STATEMENTS');
      utl_file.put_line (datei, '        , MDS.MDS_INSERT_STATEMENTS');
      utl_file.put_line (datei, '        , MDS.MDS_DELETE_STATEMENTS');
      utl_file.put_line (datei, '        , MDS.MDS_BLOCKS_DB');
      utl_file.put_line (datei, '        , MDS.MDS_TRIGGER');
      utl_file.put_line (datei, '        , MDS.MDS_SELECT_STATEMENTS');
      utl_file.put_line (datei, '        , MDS.MDS_CANVAS_BUTTONS');
      utl_file.put_line (datei, '        , MDS.MDS_CANVAS_ITEMS');
      utl_file.put_line (datei, '        , MDS.MDS_MENU_ITEMS');
      utl_file.put_line (datei, '   ,round(ms.modul_gesammt,1) modul_gesamt');
      utl_file.put_line (datei, '        from     module m');
      utl_file.put_line (datei, '                ,module_stat_fbs ms');
      utl_file.put_line (datei, '                ,module_statistic mds');
      utl_file.put_line (datei, '        where   M.MOD_ID = ms.MOD_ID');
      utl_file.put_line (datei, '        and     M.MOD_ID = mds.MOD_ID');
      utl_file.put_line (datei, '        and     upper(m.mod_name) = upper(''' || upper (p_mod_name) || ''');');
      utl_file.put_line (datei, '');
      utl_file.put_line (datei, '  cursor c_app_stat is');
      utl_file.put_line (datei, '    select * ');
      utl_file.put_line (datei, '   from module_statistic_view');
      utl_file.put_line (datei, '   where upper(mod_name) = upper(''' || upper (p_mod_name) || ''');');
      --
      utl_file.put_line (datei, ' l_sep   VARCHAR2 (2) := db_report_output.g_separator;');
      utl_file.put_line (datei, 'BEGIN');
      utl_file.put_line (datei, '--' || p_mod_name);
      utl_file.put_line (datei, 'db_report_output.headerj (''Reports Analyse Report Version 1.0 vom - ''||TO_CHAR (SYSDATE, ''DD.MM.RRRR HH24:MI:SS''));');
      utl_file.put_line (datei, 'db_report_output.title(tvd_reports_information.header_text);');
      utl_file.put_line (datei, 'for c in c_module loop');
      utl_file.put_line (datei, '    db_report_output.subtitle (''anzahl'', ''Komplexität FBS Modul ''||upper(c.mod_name));');
      utl_file.put_line (datei, '    db_report_output.text (''<table border="1"  width="100%" class="header">'');');
      utl_file.put_line (datei, 'if c.modul_gesamt between 35 and 60 then');
      utl_file.put_line (datei, '    db_report_output.text(''<td  bgcolor="#FFF000" width="60%" colspan="2" align="center">'');');
      utl_file.put_line (datei, 'elsif c.modul_gesamt > 60 then');
      utl_file.put_line (datei, '    db_report_output.text(''<td  bgcolor="#FF0000" width="60%" colspan="2" align="center">'');');
      utl_file.put_line (datei, 'else');
      utl_file.put_line (datei, '    db_report_output.text(''<td  bgcolor="#00FF00" width="60%" colspan="2" align="center">'');');
      utl_file.put_line (datei, 'end if;');
      utl_file.put_line (datei, '    db_report_output.text (''<b><font size="7">''||c.modul_gesamt||''%</font></b><br>'');');
      utl_file.put_line (datei, '  db_report_output.text(''</td>'');');
      utl_file.put_line (datei, 'db_report_output.text(''<td  width="40%" colspan="2" align="center">'');');
      utl_file.put_line (datei, '   db_report_output.text (''<b>Komplexitätszusammensetzung</b><br>'');');
      utl_file.put_line (datei, 'db_report_output.html_table_start;');
      utl_file.put_line (
         datei,
         '   db_report_output.html_table_header (''Merkmal'' || l_sep || ''gew. Komplexität in Prozent''|| l_sep || ''Anzahl im Modul'');'
      );
      utl_file.put_line (datei, '    db_report_output.html_table (   ''Bibliotheken''');
      utl_file.put_line (datei, '                                || l_sep');
      utl_file.put_line (datei, '                                || round(c.LIB,1)');
      utl_file.put_line (datei, '                                || l_sep');
      utl_file.put_line (datei, '                                || c.MDS_LIBRARIES');
      utl_file.put_line (datei, '                               );');
      utl_file.put_line (datei, '    db_report_output.html_table (   ''Items''');
      utl_file.put_line (datei, '                                || l_sep');
      utl_file.put_line (datei, '                                || round(c.ITM,1)');
      utl_file.put_line (datei, '                                || l_sep');
      utl_file.put_line (datei, '                                || c.MDS_ITEMS');
      utl_file.put_line (datei, '                               );');
      utl_file.put_line (datei, '    db_report_output.html_table (   ''Blöcke''');
      utl_file.put_line (datei, '                                || l_sep');
      utl_file.put_line (datei, '                                || to_char(c.BLOCKS,''90D0'')');
      utl_file.put_line (datei, '                                || l_sep');
      utl_file.put_line (datei, '                                || c.MDS_BLOCKS');
      utl_file.put_line (datei, '                               );');
      utl_file.put_line (datei, '    db_report_output.html_table (   ''Blöcke DB''');
      utl_file.put_line (datei, '                                || l_sep');
      utl_file.put_line (datei, '                                || to_char(c.BLOCKS_DB,''90D0'')');
      utl_file.put_line (datei, '                                || l_sep');
      utl_file.put_line (datei, '                                || c.MDS_BLOCKS_DB');
      utl_file.put_line (datei, '                               ); ');
      utl_file.put_line (datei, '     db_report_output.html_table (   ''Leinwände''');
      utl_file.put_line (datei, '                                || l_sep');
      utl_file.put_line (datei, '                                || to_char(c.Canvases,''90D0'')');
      utl_file.put_line (datei, '                                || l_sep');
      utl_file.put_line (datei, '                                || c.MDS_CANVASES');
      utl_file.put_line (datei, '                               );');
      utl_file.put_line (datei, '     db_report_output.html_table (   ''Fenster''');
      utl_file.put_line (datei, '                                || l_sep');
      utl_file.put_line (datei, '                                || to_char(c.windows,''90D0'')');
      utl_file.put_line (datei, '                                || l_sep');
      utl_file.put_line (datei, '                                || c.MDS_WINDOWS');
      utl_file.put_line (datei, '                               );');
      utl_file.put_line (datei, '     db_report_output.html_table (   ''Visuelle Attribute''');
      utl_file.put_line (datei, '                                || l_sep');
      utl_file.put_line (datei, '                                || to_char(round(c.va,1),''90D9'')');
      utl_file.put_line (datei, '                                || l_sep');
      utl_file.put_line (datei, '                                || c.MDS_VA');
      utl_file.put_line (datei, '                               );');
      utl_file.put_line (datei, '     db_report_output.html_table (   ''Parameter''');
      utl_file.put_line (datei, '                                || l_sep');
      utl_file.put_line (datei, '                                || to_char(c.parameters_,''90D0'')');
      utl_file.put_line (datei, '                                || l_sep');
      utl_file.put_line (datei, '                                || c.MDS_PARAMETERS');
      utl_file.put_line (datei, '                               );');
      utl_file.put_line (datei, '     db_report_output.html_table (   ''Wertelisten''');
      utl_file.put_line (datei, '                                || l_sep');
      utl_file.put_line (datei, '                                || to_char(c.lovs,''90D0'')');
      utl_file.put_line (datei, '                                || l_sep');
      utl_file.put_line (datei, '                                || c.MDS_LOVS');
      utl_file.put_line (datei, '                               );');
      utl_file.put_line (datei, '     db_report_output.html_table (   ''Menüs''');
      utl_file.put_line (datei, '                                || l_sep');
      utl_file.put_line (datei, '                                || to_char(c.menus,''90D0'')');
      utl_file.put_line (datei, '                                || l_sep');
      utl_file.put_line (datei, '                                || c.MDS_MENUS');
      utl_file.put_line (datei, '                               );');
      utl_file.put_line (datei, '     db_report_output.html_table (   ''Objekt Gruppen''');
      utl_file.put_line (datei, '                                || l_sep');
      utl_file.put_line (datei, '                                || to_char(c.ogs,''90D0'')');
      utl_file.put_line (datei, '                                || l_sep');
      utl_file.put_line (datei, '                                || c.MDS_OBJECT_GROUPS');
      utl_file.put_line (datei, '                               );');
      utl_file.put_line (datei, '     db_report_output.html_table (   ''Programm Einheiten''');
      utl_file.put_line (datei, '                                || l_sep');
      utl_file.put_line (datei, '                                || to_char(c.pus,''90D0'')');
      utl_file.put_line (datei, '                                || l_sep');
      utl_file.put_line (datei, '                                || c.MDS_PROGRAM_UNIT');
      utl_file.put_line (datei, '                               );');
      utl_file.put_line (datei, '      db_report_output.html_table (   ''Record Groups''');
      utl_file.put_line (datei, '                                 || l_sep');
      utl_file.put_line (datei, '                                 || to_char(c.rgs,''90D0'')');
      utl_file.put_line (datei, '                                 || l_sep');
      utl_file.put_line (datei, '                                 || c.MDS_RECORD_GROUPS');
      utl_file.put_line (datei, '                                );');
      utl_file.put_line (datei, '      db_report_output.html_table (   ''Sourcecode Länge''');
      utl_file.put_line (datei, '                                 || l_sep');
      utl_file.put_line (datei, '                                 || to_char(c.src_length,''90D0'')');
      utl_file.put_line (datei, '                                 || l_sep');
      utl_file.put_line (datei, '                                 || c.MDS_SOURCECODE_LENGTH');
      utl_file.put_line (datei, '                                );');
      utl_file.put_line (datei, '      db_report_output.html_table (   ''Sourcecode Kommentare''');
      utl_file.put_line (datei, '                                 || l_sep');
      utl_file.put_line (datei, '                                 || to_char(c.comment_,''90D0'')');
      utl_file.put_line (datei, '                                || l_sep');
      utl_file.put_line (datei, '                                 || (c.MDS_SOURCECODE_LENGTH-c.MDS_COMMENT_LENGTH)');
      utl_file.put_line (datei, '                                );');
      utl_file.put_line (datei, '      db_report_output.html_table (   ''Statements''');
      utl_file.put_line (datei, '                                 || l_sep');
      utl_file.put_line (datei, '                                 || to_char(c.satements,''90D0'')');
      utl_file.put_line (datei, '                                 || l_sep');
      utl_file.put_line (datei, '                                 || c.MDS_STATEMENTS');
      utl_file.put_line (datei, '                                );');
      utl_file.put_line (datei, '      db_report_output.html_table (   ''Statements UPDATE''');
      utl_file.put_line (datei, '                                 || l_sep');
      utl_file.put_line (datei, '                                 || to_char(c.statements_update,''90D0'')');
      utl_file.put_line (datei, '                                 || l_sep');
      utl_file.put_line (datei, '                                 || c.MDS_UPDATE_STATEMENTS');
      utl_file.put_line (datei, '                                );');
      utl_file.put_line (datei, '      db_report_output.html_table (   ''Statements INSERT''');
      utl_file.put_line (datei, '                                 || l_sep');
      utl_file.put_line (datei, '                                 || to_char(c.statements_insert,''90D0'')');
      utl_file.put_line (datei, '                                 || l_sep');
      utl_file.put_line (datei, '                                 || c.MDS_INSERT_STATEMENTS');
      utl_file.put_line (datei, '                                );');
      utl_file.put_line (datei, '      db_report_output.html_table (   ''Statements DELETE''');
      utl_file.put_line (datei, '                                 || l_sep');
      utl_file.put_line (datei, '                                 || to_char(c.statements_delete,''90D0'')');
      utl_file.put_line (datei, '                                 || l_sep');
      utl_file.put_line (datei, '                                 || c.MDS_DELETE_STATEMENTS');
      utl_file.put_line (datei, '                                );');
      utl_file.put_line (datei, '      db_report_output.html_table (   ''Statements SELECT''');
      utl_file.put_line (datei, '                                 || l_sep');
      utl_file.put_line (datei, '                                 || to_char(c.statements_select,''90D0'')');
      utl_file.put_line (datei, '                                 || l_sep');
      utl_file.put_line (datei, '                                 || c.MDS_SELECT_STATEMENTS');
      utl_file.put_line (datei, '                                );');
      utl_file.put_line (datei, '      db_report_output.html_table (   ''Trigger''');
      utl_file.put_line (datei, '                                 || l_sep');
      utl_file.put_line (datei, '                                 || to_char(c.trigger_,''90D0'')');
      utl_file.put_line (datei, '                                 || l_sep');
      utl_file.put_line (datei, '                                 || c.MDS_TRIGGER');
      utl_file.put_line (datei, '                                );');
      utl_file.put_line (datei, '      db_report_output.html_table (   ''Sichtbare Buttons''');
      utl_file.put_line (datei, '                                 || l_sep');
      utl_file.put_line (datei, '                                 || to_char(c.canvas_buttons,''90D0'')');
      utl_file.put_line (datei, '                                 || l_sep');
      utl_file.put_line (datei, '                                 || c.MDS_CANVAS_BUTTONS');
      utl_file.put_line (datei, '                                );');
      utl_file.put_line (datei, '      db_report_output.html_table (   ''Sichtbare Items''');
      utl_file.put_line (datei, '                                 || l_sep');
      utl_file.put_line (datei, '                                 || to_char(c.canvas_items,''90D0'')');
      utl_file.put_line (datei, '                                 || l_sep');
      utl_file.put_line (datei, '                                 || c.MDS_CANVAS_ITEMS');
      utl_file.put_line (datei, '                                );');
      utl_file.put_line (datei, '      db_report_output.html_table (   ''Menüeinträge''');
      utl_file.put_line (datei, '                                 || l_sep');
      utl_file.put_line (datei, '                                 || to_char(c.menu_items,''90D0'')');
      utl_file.put_line (datei, '                                 || l_sep');
      utl_file.put_line (datei, '                                 || c.MDS_MENU_ITEMS');
      utl_file.put_line (datei, '                                );');
      utl_file.put_line (datei, '  end loop;');
      utl_file.put_line (datei, '    db_report_output.html_table_end;');
      utl_file.put_line (datei, ' db_report_output.text(''</td>'');');
      utl_file.put_line (datei, '    db_report_output.html_table_end;');
      utl_file.put_line (datei, '  db_report_output.subtitle (''anzahl'', ''Dokumentation im Code'');');
      utl_file.put_line (datei, '  db_report_output.text (''<table border="1"  width="100%" class="header">'');');
      utl_file.put_line (datei, '  db_report_output.text(''<td width="60%" colspan="2" align="center">'');');
      utl_file.put_line (datei, '  db_report_output.text(''<div id="doku" style="width:600px;height:300px;"></div>''); ');
      utl_file.put_line (datei, '  db_report_output.text(''</td>'');');
      utl_file.put_line (datei, '  db_report_output.text(''<td width="40%" colspan="2" align="center">'');');
      utl_file.put_line (datei, '  db_report_output.html_table_start;');
      utl_file.put_line (datei, '  db_report_output.html_table_header (''Merkmal'' || l_sep || ''Anzahl'');');
      utl_file.put_line (datei, '  for c in c_app_stat loop   ');
      utl_file.put_line (datei, '      db_report_output.html_table (   ''Gesamtlänge Sourcecode''');
      utl_file.put_line (datei, '                                 || l_sep');
      utl_file.put_line (datei, '                                 || c.sourcecode_all');
      utl_file.put_line (datei, '                                );');
      utl_file.put_line (datei, '      db_report_output.html_table (   ''davon Kommentare''');
      utl_file.put_line (datei, '                                 || l_sep');
      utl_file.put_line (datei, '                                 || c.comment_length');
      utl_file.put_line (datei, '                                );');
      utl_file.put_line (datei, ' end loop;');
      utl_file.put_line (datei, '  db_report_output.html_table_end;');
      utl_file.put_line (datei, '  db_report_output.text(''</td>'');');
      utl_file.put_line (datei, '  db_report_output.text (''</table>''); ');
      utl_file.put_line (datei, '  db_report_output.subtitle (''anzahl'', ''Datenbankzugriff im Code'');');
      utl_file.put_line (datei, '  db_report_output.text (''<table border="1"  width="100%" class="header">'');');
      utl_file.put_line (datei, '  db_report_output.text(''<td width="60%" colspan="2" align="center">'');');
      utl_file.put_line (datei, '  db_report_output.text(''<div id="dbc" style="width:600px;height:300px;"></div>'');');
      utl_file.put_line (datei, '  db_report_output.text(''</td>'');');
      utl_file.put_line (datei, '  db_report_output.text(''<td width="40%" colspan="2" align="center">'');');
      utl_file.put_line (datei, '  db_report_output.html_table_start;');
      utl_file.put_line (datei, '  db_report_output.html_table_header (''Merkmal'' || l_sep || ''Anzahl'');');
      utl_file.put_line (datei, '  for c in c_app_stat loop');
      utl_file.put_line (datei, '      db_report_output.html_table (   ''Gesamtmenge Statements''');
      utl_file.put_line (datei, '                                 || l_sep');
      utl_file.put_line (datei, '                                 || c.statements');
      utl_file.put_line (datei, '                                );');
      utl_file.put_line (datei, '      db_report_output.html_table (   ''Datenbankzugriffe schreibend''');
      utl_file.put_line (datei, '                                 || l_sep');
      utl_file.put_line (datei, '                                 || c.db_statements_write');
      utl_file.put_line (datei, '                                );');
      utl_file.put_line (datei, '      db_report_output.html_table (   ''Datenbankzugriffe lesend''');
      utl_file.put_line (datei, '                                 || l_sep');
      utl_file.put_line (datei, '                                 || c.db_statements_read');
      utl_file.put_line (datei, '                                );');
      utl_file.put_line (datei, ' end loop;');
      utl_file.put_line (datei, '  db_report_output.html_table_end;');
      utl_file.put_line (datei, '  db_report_output.text(''</td>'');');
      utl_file.put_line (datei, '  db_report_output.text (''</table>''); ');
      utl_file.put_line (datei, '   db_report_output.subtitle (''anzahl'', ''Modul Blöcke'');');
      utl_file.put_line (datei, '  db_report_output.text (''<table border="1"  width="100%" class="header">'');');
      utl_file.put_line (datei, '  db_report_output.text(''<td width="60%" colspan="2" align="center">'');');
      utl_file.put_line (datei, '  db_report_output.text(''<div id="dbb" style="width:600px;height:300px;"></div>'');');
      utl_file.put_line (datei, '  db_report_output.text(''</td>'');');
      utl_file.put_line (datei, '  db_report_output.text(''<td width="40%" colspan="2" align="center">'');');
      utl_file.put_line (datei, '  db_report_output.html_table_start;');
      utl_file.put_line (datei, '  db_report_output.html_table_header (''Merkmal'' || l_sep || ''Anzahl'');');
      utl_file.put_line (datei, '  for c in c_app_stat loop    ');
      utl_file.put_line (datei, '      db_report_output.html_table (   ''Gesamtmenge Blöcke''');
      utl_file.put_line (datei, '                                 || l_sep');
      utl_file.put_line (datei, '                                 || c.blocks_all');
      utl_file.put_line (datei, '                                );');
      utl_file.put_line (datei, '      db_report_output.html_table (   ''Datenbank Blöcke''');
      utl_file.put_line (datei, '                                 || l_sep');
      utl_file.put_line (datei, '                                 || c.blocks_db');
      utl_file.put_line (datei, '                                );');
      utl_file.put_line (datei, '      db_report_output.html_table (   ''Control Blöcke''');
      utl_file.put_line (datei, '                                 || l_sep');
      utl_file.put_line (datei, '                                 || c.blocks_ctl');
      utl_file.put_line (datei, '                                );');
      utl_file.put_line (datei, ' end loop;');
      utl_file.put_line (datei, '  db_report_output.html_table_end;');
      utl_file.put_line (datei, '  db_report_output.text(''</td>'');');
      utl_file.put_line (datei, '  db_report_output.text (''</table>'');');
      utl_file.put_line (datei, '    DB_REPORT_OUTPUT.text(''<br>'');');
      utl_file.put_line (datei, '    DB_REPORT_OUTPUT.text(''<br>'');');
      utl_file.put_line (datei, '    DB_REPORT_OUTPUT.ABSCHLUSS;');
      --Javascript Part
      utl_file.put_line (datei, 'db_report_output.text(''<script id="source">'');');
      utl_file.put_line (datei, 'for c in c_app_stat loop');
      utl_file.put_line (datei, 'db_report_output.text(''    var data_doku = ['');');
      utl_file.put_line (datei, 'db_report_output.text(''        { label: "Dokumentation",  data: ''||c.comment_length||''},'');');
      utl_file.put_line (datei, 'db_report_output.text(''        { label: "Sourcecode",  data: ''||c.sourcecode_length||''}'');');
      utl_file.put_line (datei, 'db_report_output.text(''    ];'');');
      utl_file.put_line (datei, 'end loop;');
      utl_file.put_line (datei, 'db_report_output.text(''    $.plot($("#doku"), data_doku, '');');
      utl_file.put_line (datei, 'db_report_output.text(''    {'');');
      utl_file.put_line (datei, 'db_report_output.text(''        series: {'');');
      utl_file.put_line (datei, 'db_report_output.text(''            pie: { '');');
      utl_file.put_line (datei, 'db_report_output.text(''                show: true,'');');
      utl_file.put_line (datei, 'db_report_output.text(''                radius: 1,'');');
      utl_file.put_line (datei, 'db_report_output.text(''                label: {'');');
      utl_file.put_line (datei, 'db_report_output.text(''                    show: true,'');');
      utl_file.put_line (datei, 'db_report_output.text(''                    radius: 1,'');');
      utl_file.put_line (datei, 'db_report_output.text(''                    formatter: function(label, series){'');');
      utl_file.put_line (datei, 'db_report_output.text(''return ''''<div style="font-size:8pt;text-align:center;padding:2px;color:black;">'''''');');
      utl_file.put_line (datei, 'db_report_output.text(''+label+''''<br/>''''+Math.round(series.percent)+''''%</div>'''';'');');
      utl_file.put_line (datei, 'db_report_output.text(''                    },'');');
      utl_file.put_line (datei, 'db_report_output.text(''                    background: { opacity: 0.8 }'');');
      utl_file.put_line (datei, 'db_report_output.text(''                }'');');
      utl_file.put_line (datei, 'db_report_output.text(''            }'');');
      utl_file.put_line (datei, 'db_report_output.text(''        },'');');
      utl_file.put_line (datei, 'db_report_output.text(''        legend: {'');');
      utl_file.put_line (datei, 'db_report_output.text(''            show: false'');');
      utl_file.put_line (datei, 'db_report_output.text(''        }'');');
      utl_file.put_line (datei, 'db_report_output.text(''    });'');');
      utl_file.put_line (datei, 'for c in c_app_stat loop');
      utl_file.put_line (datei, 'db_report_output.text(''    var data_dbc = ['');');
      utl_file.put_line (datei, 'db_report_output.text(''        { label: "schreibend",  data: ''||c.db_statements_write||''},'');');
      utl_file.put_line (datei, 'db_report_output.text(''        { label: "lesend",  data: ''||c.db_statements_read||''},'');');
      utl_file.put_line (datei, 'db_report_output.text(''        { label: "PL/SQL Statements",  data: ''||c.statements_ohne_db||''}'');');
      utl_file.put_line (datei, 'db_report_output.text(''    ];'');');
      utl_file.put_line (datei, 'end loop;');
      utl_file.put_line (datei, 'db_report_output.text(''    $.plot($("#dbc"), data_dbc, '');');
      utl_file.put_line (datei, 'db_report_output.text(''    {'');');
      utl_file.put_line (datei, 'db_report_output.text(''        series: {'');');
      utl_file.put_line (datei, 'db_report_output.text(''            pie: { '');');
      utl_file.put_line (datei, 'db_report_output.text(''                show: true,'');');
      utl_file.put_line (datei, 'db_report_output.text(''                radius: 1,'');');
      utl_file.put_line (datei, 'db_report_output.text(''                label: {'');');
      utl_file.put_line (datei, 'db_report_output.text(''                    show: true,'');');
      utl_file.put_line (datei, 'db_report_output.text(''                    radius: 1,'');');
      utl_file.put_line (datei, 'db_report_output.text(''                    formatter: function(label, series){'');');
      utl_file.put_line (datei, 'db_report_output.text(''return ''''<div style="font-size:8pt;text-align:center;padding:2px;color:black;">'''''');');
      utl_file.put_line (datei, 'db_report_output.text(''+label+''''<br/>''''+Math.round(series.percent)+''''%</div>'''';'');');
      utl_file.put_line (datei, 'db_report_output.text(''                    },'');');
      utl_file.put_line (datei, 'db_report_output.text(''                    background: { opacity: 0.8 }'');');
      utl_file.put_line (datei, 'db_report_output.text(''                }'');');
      utl_file.put_line (datei, 'db_report_output.text(''            }'');');
      utl_file.put_line (datei, 'db_report_output.text(''        },'');');
      utl_file.put_line (datei, 'db_report_output.text(''        legend: {'');');
      utl_file.put_line (datei, 'db_report_output.text(''            show: false'');');
      utl_file.put_line (datei, 'db_report_output.text(''        }'');');
      utl_file.put_line (datei, 'db_report_output.text(''    });'');');
      utl_file.put_line (datei, 'for c in c_app_stat loop');
      utl_file.put_line (datei, 'db_report_output.text(''    var data_dbb = ['');');
      utl_file.put_line (datei, 'db_report_output.text(''        { label: "DB Blöcke",  data: ''||c.blocks_db||''},'');');
      utl_file.put_line (datei, 'db_report_output.text(''        { label: "Control Blöcke",  data: ''||c.blocks_ctl||''}'');');
      utl_file.put_line (datei, 'db_report_output.text(''    ];'');');
      utl_file.put_line (datei, 'end loop;');
      utl_file.put_line (datei, 'db_report_output.text(''    $.plot($("#dbb"), data_dbb, '');');
      utl_file.put_line (datei, 'db_report_output.text(''    {'');');
      utl_file.put_line (datei, 'db_report_output.text(''        series: {'');');
      utl_file.put_line (datei, 'db_report_output.text(''            pie: { '');');
      utl_file.put_line (datei, 'db_report_output.text(''                show: true,'');');
      utl_file.put_line (datei, 'db_report_output.text(''                radius: 1,'');');
      utl_file.put_line (datei, 'db_report_output.text(''                label: {'');');
      utl_file.put_line (datei, 'db_report_output.text(''                    show: true,'');');
      utl_file.put_line (datei, 'db_report_output.text(''                    radius: 1,'');');
      utl_file.put_line (datei, 'db_report_output.text(''                    formatter: function(label, series){'');');
      utl_file.put_line (datei, 'db_report_output.text(''return ''''<div style="font-size:8pt;text-align:center;padding:2px;color:black;">'''''');');
      utl_file.put_line (datei, 'db_report_output.text(''+label+''''<br/>''''+Math.round(series.percent)+''''%</div>'''';'');');
      utl_file.put_line (datei, 'db_report_output.text(''                    },'');');
      utl_file.put_line (datei, 'db_report_output.text(''                    background: { opacity: 0.8 }'');');
      utl_file.put_line (datei, 'db_report_output.text(''                }'');');
      utl_file.put_line (datei, 'db_report_output.text(''            }'');');
      utl_file.put_line (datei, 'db_report_output.text(''        },'');');
      utl_file.put_line (datei, 'db_report_output.text(''       legend: {'');');
      utl_file.put_line (datei, 'db_report_output.text(''            show: false'');');
      utl_file.put_line (datei, 'db_report_output.text(''        }'');');
      utl_file.put_line (datei, 'db_report_output.text(''    });'');');
      utl_file.put_line (datei, 'db_report_output.text(''</script>'');');
      utl_file.put_line (datei, 'END;');
      utl_file.put_line (datei, '/');
      utl_file.put_line (datei, 'SPOOL OFF');
      utl_file.fclose (datei);
   end erstelle_modul_stat_fbs_sql;
end tvd_reports_information;
/

show errors

