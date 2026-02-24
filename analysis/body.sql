CREATE OR REPLACE PACKAGE BODY TVDMIG.tvd_information
IS
   FUNCTION get_mod_typ (p_mod_name IN VARCHAR2)
      RETURN VARCHAR2
   IS
      v_wert   module.mod_typ%TYPE;
   BEGIN
      SELECT   mod_typ
        INTO   v_wert
        FROM   module
       WHERE   mod_name = p_mod_name;

      RETURN v_wert;
   EXCEPTION
      WHEN NO_DATA_FOUND OR TOO_MANY_ROWS
      THEN
         v_wert := 'Keinen Type gefunden';
         RETURN v_wert;
   END get_mod_typ;

   FUNCTION get_zeilen_modul (p_mod_name IN VARCHAR2)
      RETURN NUMBER
   IS
      v_wert   NUMBER (10) := 0;
   BEGIN
      SELECT   COUNT ( * )
        INTO   v_wert
        FROM   (SELECT   mo.mod_id, mo.mod_name
                  FROM         betroffen_daten b
                            JOIN
                               mod_trigger_src m
                            ON (m.mod_trg_src_id = b.ID)
                         JOIN
                            module mo
                         ON (mo.mod_id = m.mod_id)
                UNION ALL
                SELECT   mo.mod_id, mo.mod_name
                  FROM         betroffen_daten b
                            JOIN
                               mod_block_trigger_source m
                            ON (b.ID = m.mod_blk_trg_src_id)
                         JOIN
                            module mo
                         ON (mo.mod_id = m.mod_id)
                UNION ALL
                SELECT   mo.mod_id, mo.mod_name
                  FROM         betroffen_daten b
                            JOIN
                               mod_block_item_trigger_src m
                            ON (b.ID = m.mod_blk_ite_trg_src_id)
                         JOIN
                            module mo
                         ON (mo.mod_id = m.mod_id)
                UNION ALL
                SELECT   mo.mod_id, mo.mod_name
                  FROM         betroffen_daten b
                            JOIN
                               mod_proc_src m
                            ON (b.ID = m.mod_prc_src_id)
                         JOIN
                            module mo
                         ON (mo.mod_id = m.mod_id))
       WHERE   mod_name = p_mod_name;

      RETURN v_wert;
   END get_zeilen_modul;

   FUNCTION get_zeilen_suchstring (p_suchstring IN VARCHAR2)
      RETURN NUMBER
   IS
      v_wert   NUMBER (10) := 0;
   BEGIN
      SELECT   COUNT ( * )
        INTO   v_wert
        FROM   betroffen_daten
       WHERE   betroffen_daten.suchstring = p_suchstring;

      RETURN v_wert;
   END get_zeilen_suchstring;

   FUNCTION get_suchstring_ersetztung (p_suchstring IN VARCHAR2)
      RETURN VARCHAR2
   IS
      v_wert   VARCHAR2 (2000) := NULL;
   BEGIN
      SELECT   DISTINCT (beschreibung)
        INTO   v_wert
        FROM   suchstring
       WHERE   suchstring.suchstring = p_suchstring;

      RETURN v_wert;
   END get_suchstring_ersetztung;

   FUNCTION get_suchstring_loesung (p_suchstring IN VARCHAR2)
      RETURN VARCHAR2
   IS
      v_wert   VARCHAR2 (2000) := NULL;
   BEGIN
      SELECT   loesung
        INTO   v_wert
        FROM   suchstring
       WHERE   suchstring.suchstring = p_suchstring;

      RETURN v_wert;
   END get_suchstring_loesung;

   PROCEDURE erstelle_mod_modul_sql (p_mod_name IN VARCHAR2)
   IS
      datei         UTL_FILE.file_type;
      v_datei_typ   module.mod_typ%TYPE := '###';
      v_datei_name VARCHAR2 (32)
            := SUBSTR (p_mod_name, 1, INSTR (p_mod_name, '.') - 1) ;
   BEGIN
      -- oeffnen der Datei
      BEGIN
         SELECT   mod_typ
           INTO   v_datei_typ
           FROM   module
          WHERE   UPPER (module.mod_name) = UPPER (p_mod_name);

         DBMS_OUTPUT.put_line (v_datei_name);
      EXCEPTION
         WHEN OTHERS
         THEN
            DBMS_OUTPUT.put_line (v_datei_name);
            v_datei_typ := '.pll';                             --v_datei_name;
      END;

      -- v_datei_typ:='pll';
      datei :=
         UTL_FILE.fopen ('MOD_MODULE', 'mod_' || v_datei_name || '.sql', 'W');
      -- Dateien sind angelegt
      UTL_FILE.put_line (datei, 'DEFINE PATH=''&1''');
      -- UTL_FILE.put_line (datei, 'DEFINE SCHEMA=''&2''');
      UTL_FILE.put_line (
         datei,
         'DEFINE FILENAME = &PATH/' || 'mod_' || v_datei_name || '.htm'
      );
      UTL_FILE.put_line (datei, 'SET TERMOUT ON');
      UTL_FILE.put_line (
         datei,
         'PROMPT Erstelle ' || 'mod_' || v_datei_name || '.htm ...'
      );
      UTL_FILE.put_line (datei, 'PROMPT');
      UTL_FILE.put_line (datei, 'SET TERMOUT OFF');
      UTL_FILE.put_line (
         datei,
         'REM ##################################################################'
      );
      UTL_FILE.put_line (datei,
                         'REM Erstellen der einzelnen HTML Seiten.htm');
      UTL_FILE.put_line (
         datei,
         'REM ##################################################################'
      );
      UTL_FILE.put_line (datei, 'SPOOL &FILENAME');
      UTL_FILE.put_line (datei, 'DECLARE');
      -- erster Cursor
      UTL_FILE.put_line (datei, 'CURSOR Modul_trigger  IS');
      UTL_FILE.put_line (datei,
                         '  SELECT t.mod_trg_name, m.zeilen_nr, m.zeile');
      UTL_FILE.put_line (datei, '    FROM betroffen_daten b ');
      UTL_FILE.put_line (
         datei,
         '    JOIN mod_trigger_src m ON (m.mod_trg_src_id = b.ID)'
      );
      UTL_FILE.put_line (
         datei,
         '   JOIN mod_trigger t ON (m.mod_trg_id = t.mod_trg_id)'
      );
      UTL_FILE.put_line (datei,
                         '   JOIN module mo ON (mo.mod_id = m.mod_id)');
      UTL_FILE.put_line (
         datei,
            '  WHERE upper(mod_name) = UPPER ('''
         || v_datei_name
         || '.'
         || v_datei_typ
         || ''') order by 1,2;'
      );
      ----
      UTL_FILE.put_line (datei, 'CURSOR Modul_blk_trigger  IS');
      UTL_FILE.put_line (
         datei,
         '  SELECT t.mod_blk_trg_name, m.zeilen_nr, m.zeile,blk.mod_blk_name'
      );
      UTL_FILE.put_line (datei, '    FROM betroffen_daten b ');
      UTL_FILE.put_line (
         datei,
         '    JOIN MOD_BLOCK_TRIGGER_SOURCE m    ON (m.MOD_BLK_TRG_SRC_ID = b.ID)'
      );
      UTL_FILE.put_line (
         datei,
         '   JOIN MOD_BLOCK_TRIGGER t ON (m.mod_blk_trg_id = t.mod_blk_trg_id)'
      );
      UTL_FILE.put_line (
         datei,
         '   JOIN MOD_BLOCK blk ON (blk.mod_blk_id = t.mod_blk_id)'
      );
      UTL_FILE.put_line (datei,
                         '   JOIN module mo ON (mo.mod_id = m.mod_id)');
      UTL_FILE.put_line (
         datei,
            '  WHERE upper(mod_name) = UPPER ('''
         || v_datei_name
         || '.'
         || v_datei_typ
         || ''') order by 4,1,2;'
      );
      --
      ----
      UTL_FILE.put_line (datei, 'CURSOR Modul_blk_ite_trigger  IS');
      UTL_FILE.put_line (
         datei,
         '  SELECT t.mod_blk_ite_trg_name, m.zeilen_nr, m.zeile,blk.mod_blk_name,blki.mod_blk_item_name'
      );
      UTL_FILE.put_line (datei, '    FROM betroffen_daten b ');
      UTL_FILE.put_line (
         datei,
         '    JOIN MOD_BLOCK_ITEM_TRIGGER_SRC m ON (m.MOD_BLK_ITE_TRG_SRC_ID = b.ID)'
      );
      UTL_FILE.put_line (
         datei,
         '   JOIN MOD_BLOCK_ITEM_TRIGGER t ON (m.mod_blk_ite_trg_id = t.mod_blk_ite_trg_id)'
      );
      UTL_FILE.put_line (
         datei,
         '   JOIN MOD_BLOCK_ITEM blkI ON (blkI.mod_blk_ITEM_id = t.mod_blk_ITEM_id)'
      );
      UTL_FILE.put_line (
         datei,
         '   JOIN MOD_BLOCK blk ON (blk.mod_blk_id = t.mod_blk_id)'
      );
      UTL_FILE.put_line (datei,
                         '   JOIN module mo ON (mo.mod_id = m.mod_id)');
      UTL_FILE.put_line (
         datei,
            '  WHERE upper(mod_name) = UPPER ('''
         || v_datei_name
         || '.'
         || v_datei_typ
         || ''');'
      );
      --

      ----
      UTL_FILE.put_line (datei, 'CURSOR Modul_proc  IS');
      UTL_FILE.put_line (datei,
                         '  SELECT t.mod_prc_name, m.zeilen_nr, m.zeile');
      UTL_FILE.put_line (datei, '    FROM betroffen_daten b ');
      UTL_FILE.put_line (
         datei,
         '    JOIN MOD_PROC_SRC m ON (m.MOD_PRC_SRC_ID = b.ID)'
      );
      UTL_FILE.put_line (
         datei,
         '   JOIN MOD_PROC t ON (m.MOD_PRC_ID = t.MOD_PRC_ID)'
      );
      UTL_FILE.put_line (datei,
                         '   JOIN module mo ON (mo.mod_id = m.mod_id)');
      UTL_FILE.put_line (
         datei,
            '  WHERE upper(mod_name) = UPPER ('''
         || v_datei_name
         || '.'
         || v_datei_typ
         || ''');'
      );
      --
      UTL_FILE.put_line (
         datei,
         ' v_sep   VARCHAR2 (2) := db_report_output.g_separator;'
      );
      UTL_FILE.put_line (datei, 'BEGIN');
      UTL_FILE.put_line (datei, '--' || p_mod_name);
      UTL_FILE.put_line (
         datei,
         'db_report_output.header (''Forms Analyse Report V2.0 vom - ''||TO_CHAR (SYSDATE, ''DD.MM.RRRR HH24:MI:SS''));'
      );
    UTL_FILE.put_line (
         datei,
            'db_report_output.title (''Uebersicht des Moduls : ''||'''
         || v_datei_name
         || ''');'
      );
      --      UTL_FILE.put_line (datei, 'db_report_output.anchor (''io_db'', ''I/O der Datenbank'');');
      UTL_FILE.put_line (datei, 'db_report_output.anchor ('''', '''');');
      UTL_FILE.put_line (datei, 'db_report_output.anchor ('''', '''');');
      UTL_FILE.put_line (datei, 'db_report_output.br;');
      UTL_FILE.put_line (datei, 'db_report_output.html_table_start;');
      UTL_FILE.put_line (
         datei,
         'db_report_output.html_table_header ( ''Bereich''|| v_sep ||''Block Name''||v_sep||''Item Name''||v_sep||''Trigger / Progname''|| v_sep  || ''Zeilen Nr.''|| v_sep  || ''Zeile:'');'
      );
      UTL_FILE.put_line (datei, 'FOR c IN modul_trigger');
      UTL_FILE.put_line (datei, '       LOOP');
      UTL_FILE.put_line (
         datei,
         'db_report_output.html_table (''Forms Trigger''|| v_sep||'' ''||v_sep||'' ''||v_sep ||c.mod_trg_name || v_sep||c.zeilen_nr || v_sep||c.zeile );'
      );
      UTL_FILE.put_line (datei, ' END LOOP;');
      UTL_FILE.put_line (datei, 'FOR c IN Modul_blk_trigger');
      UTL_FILE.put_line (datei, '       LOOP');
      UTL_FILE.put_line (
         datei,
         'db_report_output.html_table (''Block Trigger''|| v_sep ||c.mod_blk_name||v_sep||'' ''||v_sep||c.mod_blk_trg_name || v_sep||c.zeilen_nr || v_sep||c.zeile );'
      );
      UTL_FILE.put_line (datei, ' END LOOP;');
      UTL_FILE.put_line (datei, 'FOR c IN Modul_blk_ite_trigger');
      UTL_FILE.put_line (datei, '       LOOP');
      UTL_FILE.put_line (
         datei,
         'db_report_output.html_table (''Item Trigger''|| v_sep ||c.mod_blk_name||v_sep||c.mod_blk_item_name||v_sep||c.mod_blk_ite_trg_name || v_sep||c.zeilen_nr || v_sep||c.zeile );'
      );
      UTL_FILE.put_line (datei, ' END LOOP;');
      --
      UTL_FILE.put_line (datei, 'FOR c IN Modul_Proc');
      UTL_FILE.put_line (datei, '       LOOP');
      UTL_FILE.put_line (
         datei,
         'db_report_output.html_table (''Procedure''|| v_sep ||c.mod_prc_name||v_sep||'' ''||v_sep||'' ''|| v_sep||c.zeilen_nr || v_sep||c.zeile );'
      );
      UTL_FILE.put_line (datei, ' END LOOP;');
      UTL_FILE.put_line (datei, 'db_report_output.html_table_end;');
      UTL_FILE.put_line (datei, 'DB_REPORT_OUTPUT.text(''<br>'');');
      UTL_FILE.put_line (datei, 'DB_REPORT_OUTPUT.text(''<br>'');');
      UTL_FILE.put_line (datei, 'DB_REPORT_OUTPUT.ABSCHLUSS;');
      UTL_FILE.put_line (datei, 'END;');
      UTL_FILE.put_line (datei, '/');
      UTL_FILE.put_line (datei, 'SPOOL OFF');
      UTL_FILE.fclose (datei);
   END;

   PROCEDURE erstelle_mod_such_sql (p_mod_such IN VARCHAR2)
   IS
      datei        UTL_FILE.file_type;
      v_mod_such   VARCHAR2 (255) := RTRIM (LTRIM (LOWER (p_mod_such)));
   BEGIN
      -- oeffnen der Datei
      datei :=
         UTL_FILE.fopen ('MOD_MODULE', 'mod_' || v_mod_such || '.sql', 'W');
      -- Dateien sind angelegt
      UTL_FILE.put_line (datei, 'DEFINE PATH=''&1''');
      --  UTL_FILE.put_line (datei, 'DEFINE SCHEMA=''&2''');
      UTL_FILE.put_line (
         datei,
         'DEFINE FILENAME = &PATH/' || 'mod_' || v_mod_such || '.htm'
      );
      UTL_FILE.put_line (datei, 'SET TERMOUT ON');
      UTL_FILE.put_line (
         datei,
         'PROMPT Erstelle ' || 'mod_' || v_mod_such || '.htm ...'
      );
      UTL_FILE.put_line (datei, 'PROMPT');
      UTL_FILE.put_line (datei, 'SET TERMOUT OFF');
      UTL_FILE.put_line (
         datei,
         'REM ##################################################################'
      );
      UTL_FILE.put_line (datei, 'REM Erstellen der uebersicht.htm');
      UTL_FILE.put_line (
         datei,
         'REM ##################################################################'
      );
      UTL_FILE.put_line (datei, 'SPOOL &FILENAME');
      UTL_FILE.put_line (datei, 'DECLARE');
      -- erster Cursor
      UTL_FILE.put_line (datei, 'CURSOR Modul_such  IS');
      UTL_FILE.put_line (
         datei,
         '  SELECT MOD_NAME,TYP,BLOCKNAME,ITEMNAME,TRIGGER_NAME,ZEILEN_NR,ZEILE'
      );
      UTL_FILE.put_line (datei, '    FROM module_komplett b ');
      UTL_FILE.put_line (
         datei,
         '  WHERE suchstring = UPPER (''' || p_mod_such || ''')'
      );
      UTL_FILE.put_line (datei, '  order by mod_id;');
      UTL_FILE.put_line (
         datei,
         ' v_sep   VARCHAR2 (2) := db_report_output.g_separator;'
      );
      UTL_FILE.put_line (
         datei,
         'function get_html (p_mod_name in varchar2) return varchar2'
      );
      UTL_FILE.put_line (datei, 'is ');
      UTL_FILE.put_line (datei, '');
      UTL_FILE.put_line (
         datei,
         'v_mod_name varchar2(255):=rtrim(ltrim(LOWER (p_mod_name)));'
      );
      UTL_FILE.put_line (datei, ' begin');
      UTL_FILE.put_line (
         datei,
         '  return ''mod_''||substr (v_mod_name,1, instr(v_mod_name,''.'')-1) ||''.htm'' ;'
      );
      -- substr('hall.fmb',1, instr('hall.fmb','.')-1)||'.htm'
      UTL_FILE.put_line (datei, ' end;');
      UTL_FILE.put_line (datei, 'BEGIN');
      UTL_FILE.put_line (
         datei,
         'db_report_output.header (''Forms Analyse Report vom - ''||TO_CHAR (SYSDATE, ''DD.MM.RRRR HH24:MI:SS''));'
      );
      UTL_FILE.put_line (
         datei,
            'db_report_output.title (''Uebersicht des Build_Ins : ''||'''
         || p_mod_such
         || ''');'
      );
      --      UTL_FILE.put_line (datei, 'db_report_output.anchor (''io_db'', ''I/O der Datenbank'');');
      --      UTL_FILE.put_line (datei, 'db_report_output.anchor ('''', '''');');
      --      UTL_FILE.put_line (datei, 'db_report_output.anchor ('''', '''');');
      UTL_FILE.put_line (datei, 'db_report_output.br;');
      UTL_FILE.put_line (datei, 'db_report_output.html_table_start;');
      UTL_FILE.put_line (
         datei,
         'db_report_output.html_table_header ( ''Modul Name''|| v_sep ||''Typ ''||v_sep||''Block''||v_sep||''ItemName''||v_sep||''Trigger / Progname''|| v_sep  || ''Zeilen Nr.''|| v_sep  || ''Zeile:'');'
      );
      UTL_FILE.put_line (datei, 'FOR c IN modul_such');
      UTL_FILE.put_line (datei, '       LOOP');
      -- '<a href="c.Mod_name">'||c.Mod_name||'</a>'
      UTL_FILE.put_line (
         datei,
         'db_report_output.html_table (''<a href="''||tvd_information.get_html (c.Mod_name)||''">''||c.mod_name ||''</a>''|| v_sep||c.typ||v_sep||c.blockname||v_sep||c.itemname||v_sep ||c.trigger_name || v_sep||c.zeilen_nr || v_sep||c.zeile );'
      );
      UTL_FILE.put_line (datei, ' END LOOP;');
      UTL_FILE.put_line (datei, 'db_report_output.html_table_end;');
      --    UTL_FILE.put_line (datei, ' db_report_output.subtitle(''io_fs'', ''I/O des Filesystems'');');
      UTL_FILE.put_line (datei, 'db_report_output.top;');
      UTL_FILE.put_line (datei, 'db_report_output.absender_tvd;');
      UTL_FILE.put_line (datei, 'db_report_output.footer;');
      UTL_FILE.put_line (datei, 'END;');
      UTL_FILE.put_line (datei, '/');
      UTL_FILE.put_line (datei, 'SPOOL OFF');
      --UTL_FILE.put_line (datei, 'EXIT');

      UTL_FILE.fclose (datei);
   END;

   FUNCTION get_anzahl_module (p_mod_typ IN VARCHAR2 DEFAULT NULL )
      RETURN VARCHAR2
   IS
      v_wert   VARCHAR2 (20);
   BEGIN
      IF p_mod_typ IS NULL
      THEN
         SELECT   TO_CHAR (COUNT (mod_id)) INTO v_wert FROM module;
      ELSIF p_mod_typ = 'FMB'
      THEN
         SELECT   TO_CHAR (COUNT (mod_id))
           INTO   v_wert
           FROM   module
          WHERE   mod_typ = 'FMB';
      ELSIF p_mod_typ = 'MMB'
      THEN
         SELECT   TO_CHAR (COUNT (mod_id))
           INTO   v_wert
           FROM   module
          WHERE   mod_typ = 'MMB';
      ELSIF p_mod_typ = 'PLL'
      THEN
         SELECT   TO_CHAR (COUNT (mod_id))
           INTO   v_wert
           FROM   module
          WHERE   mod_typ = 'PLL';
      ELSIF p_mod_typ = 'RDF'
      THEN
         SELECT   TO_CHAR (COUNT (mod_id))
           INTO   v_wert
           FROM   module
          WHERE   mod_typ = 'RDF';
      END IF;

      RETURN v_wert;
   END;

   FUNCTION get_anzahl_zeilen
      RETURN VARCHAR2
   IS
      v_wert   VARCHAR2 (20);
   BEGIN
      SELECT   TO_CHAR (COUNT ( * )) INTO v_wert FROM v_daten;

      RETURN v_wert;
   END;

   FUNCTION get_anzahl_canvas
      RETURN VARCHAR2
   IS
      v_wert   VARCHAR2 (20);
   BEGIN
      SELECT   TO_CHAR (COUNT ( * )) INTO v_wert FROM MOD_CANVAS;

      RETURN v_wert;
   END;

   FUNCTION get_anzahl_stacked
      RETURN VARCHAR2
   IS
      v_wert   VARCHAR2 (20);
   BEGIN
      SELECT   TO_CHAR (COUNT ( * ))
        INTO   v_wert
        FROM   MOD_CANVAS
       WHERE   MOD_CANVAS_SUBTYP = 1;

      RETURN v_wert;
   END;

   FUNCTION get_anzahl_tab
      RETURN VARCHAR2
   IS
      v_wert   VARCHAR2 (20);
   BEGIN
      SELECT   TO_CHAR (COUNT ( * ))
        INTO   v_wert
        FROM   MOD_CANVAS
       WHERE   MOD_CANVAS_SUBTYP = 4;

      RETURN v_wert;
   END;

   FUNCTION get_anzahl_content
      RETURN VARCHAR2
   IS
      v_wert   VARCHAR2 (20);
   BEGIN
      SELECT   TO_CHAR (COUNT ( * ))
        INTO   v_wert
        FROM   MOD_CANVAS
       WHERE   MOD_CANVAS_SUBTYP = 0;

      RETURN v_wert;
   END;

   FUNCTION get_anzahl_fmb
      RETURN VARCHAR2
   IS
      v_wert   VARCHAR2 (20);
   BEGIN
      SELECT   TO_CHAR (COUNT ( * ))
        INTO   v_wert
        FROM   module
       WHERE   MOD_TYP = 'FMB';

      RETURN v_wert;
   END;

   FUNCTION get_anzahl_mmb
      RETURN VARCHAR2
   IS
      v_wert   VARCHAR2 (20);
   BEGIN
      SELECT   TO_CHAR (COUNT ( * ))
        INTO   v_wert
        FROM   module
       WHERE   MOD_TYP = 'MMB';

      RETURN v_wert;
   END;

   FUNCTION get_anzahl_pll
      RETURN VARCHAR2
   IS
      v_wert   VARCHAR2 (20);
   BEGIN
      SELECT   TO_CHAR (COUNT ( * ))
        INTO   v_wert
        FROM   module
       WHERE   MOD_TYP = 'PLL';

      RETURN v_wert;
   END;
FUNCTION get_anzahl_rdf
      RETURN VARCHAR2
   IS
      v_wert   VARCHAR2 (20);
   BEGIN
      SELECT   TO_CHAR (COUNT ( * ))
        INTO   v_wert
        FROM   module
       WHERE   MOD_TYP = 'RDF';

      RETURN v_wert;
   END;
   FUNCTION get_betroffene_zeilen
      RETURN VARCHAR2
   IS
      v_wert   VARCHAR2 (20);
   BEGIN
      SELECT   TO_CHAR (COUNT ( * )) INTO v_wert FROM betroffen_daten;

      RETURN v_wert;
   END;

   FUNCTION get_anzahl_bloecke
      RETURN VARCHAR2
   IS
      v_wert   VARCHAR2 (20);
   BEGIN
      SELECT   TO_CHAR (COUNT ( * )) INTO v_wert FROM mod_block;

      RETURN v_wert;
   END;

   FUNCTION get_html (p_mod_name IN VARCHAR2)
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN    'mod_'
             || SUBSTR (p_mod_name, 1, INSTR (p_mod_name, '.') - 1)
             || '.htm';
   -- substr('hall.fmb',1, instr('hall.fmb','.')-1)||'.htm'
   END;

   PROCEDURE aktive_log_prc (p_loginfo IN VARCHAR2)
   IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      INSERT INTO aktions_log (ID, loginformation)
        VALUES   (aktive_log_seq.NEXTVAL, p_loginfo);

      COMMIT;
   END;

   FUNCTION get_modul_name (p_mod_id IN NUMBER)
      RETURN VARCHAR2
   IS
      v_wert   VARCHAR2 (255);
   BEGIN
      SELECT   mod_name
        INTO   v_wert
        FROM   module
       WHERE   module.mod_id = p_mod_id;

      RETURN v_wert;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN ' ';
   END;

   FUNCTION get_block_name (p_mod_blk_id IN NUMBER)
      RETURN VARCHAR2
   IS
      v_wert   VARCHAR2 (255);
   BEGIN
      SELECT   mod_blk_name
        INTO   v_wert
        FROM   mod_block
       WHERE   mod_block.mod_blk_id = p_mod_blk_id;

      RETURN v_wert;
   END;

   FUNCTION get_item_name (p_mod_blk_item_id IN NUMBER)
      RETURN VARCHAR2
   IS
      v_wert   VARCHAR2 (255);
   BEGIN
      SELECT   mod_blk_item_name
        INTO   v_wert
        FROM   mod_block_item
       WHERE   mod_block_item.mod_blk_item_id = p_mod_blk_item_id;

      RETURN v_wert;
   END;

   FUNCTION v_text
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN 'Analyse Forms Module V4.0';
   END;

   FUNCTION get_option_number (p_name IN VARCHAR2)
      RETURN NUMBER
   IS
      v_wert   OPTIONEN.WERTN%TYPE;
   BEGIN
      SELECT   wertn
        INTO   v_wert
        FROM   optionen
       WHERE   OPTIONEN.NAME = UPPER (p_name);

      RETURN v_wert;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN 0;
   END;

   FUNCTION get_option_char (p_name IN VARCHAR2)
      RETURN VARCHAR2
   IS
      v_wert   OPTIONEN.WERT%TYPE;
   BEGIN
      SELECT   wert
        INTO   v_wert
        FROM   optionen
       WHERE   OPTIONEN.NAME = UPPER (p_name);

      RETURN v_wert;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN NULL;
   END;
END;
/
