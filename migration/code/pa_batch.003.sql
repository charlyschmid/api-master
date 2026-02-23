PACKAGE BODY pa_batch
IS
   v_nom_prg     VARCHAR2(30)     := NULL;
   v_override    BOOLEAN          := FALSE;
   v_bat_yon     VARCHAR2(1); 
   
   w_nbr         NUMBER;
   w_usr         VARCHAR2(255);
   w_pwd         VARCHAR2(255);
   w_con         VARCHAR2(255)     := pa_var.v_conn_string; 
   w_log         VARCHAR2(765);
   w_load        VARCHAR2(100);
   w_fichier     VARCHAR2(255);
   w_queue       VARCHAR2(40)      := NULL;
   w_directory   VARCHAR2(512);
   w_nom_fic_imp VARCHAR2(512);
   w_cod_que     varchar2(2)   := '@';
   w_adr_ptr     varchar2(255) := NULL;
   
   TYPE c_rec_bat IS RECORD
   (  seq_bat                        	   ba_batch.seq_bat      %type
     ,cod_sta_bat                    	   ba_batch.cod_sta_bat	 %type
     ,num_job                        	   ba_batch.num_job    	 %type
     ,nom_fic                        	   ba_batch.nom_fic    	 %type
     ,nom_prg                        	   ba_batch.nom_prg    	 %type
     ,dir_prg                        	   ba_batch.dir_prg    	 %type
     ,tit_prg                        	   ba_batch.tit_prg    	 %type
     ,dat_lan                        	   ba_batch.dat_lan    	 %type
     ,idn_uti                        	   ba_batch.idn_uti    	 %type
     ,pwd_uti                        	   ba_batch.pwd_uti    	 %type
     ,nom_bdd                        	   ba_batch.nom_bdd    	 %type
     ,cod_typ_prg                    	   ba_batch.cod_typ_prg	 %type
     ,num_soc                        	   ba_batch.num_soc    	 %type
     ,cod_pri                        	   ba_batch.cod_pri    	 %type
     ,cod_que                        	   ba_batch.cod_que    	 %type
     ,cod_imp                        	   ba_batch.cod_imp    	 %type
     ,cod_fmt                        	   ba_batch.cod_fmt    	 %type
     ,cod_trt                        	   ba_batch.cod_trt    	 %type
     ,cod_bat                        	   ba_batch.cod_bat    	 %type
     ,cod_ort                        	   ba_batch.cod_ort    	 %type
     ,nbr_cop                        	   ba_batch.nbr_cop    	 %type
     ,cod_err                        	   ba_batch.cod_err    	 %type
     ,cod_par_yon                    	   ba_batch.cod_par_yon	 %type
     ,cod_fic_yon                    	   ba_batch.cod_fic_yon	 %type
     ,cod_hea_yon                    	   ba_batch.cod_hea_yon	 %type
     ,cod_trl_yon                    	   ba_batch.cod_trl_yon	 %type
     ,dat_trt                        	   ba_batch.dat_trt    	 %type
     ,dat_trt_com                    	   ba_batch.dat_trt_com	 %type
     ,dat_trt_fin                    	   ba_batch.dat_trt_fin	 %type
     ,nom_fic_imp                    	   ba_batch.nom_fic_imp	 %type
     ,cod_mod                        	   ba_batch.cod_mod    	 %type
     ,dir_ini                        	   ba_batch.dir_ini    	 %type
     ,dir_fmt														 varchar2(255)
     ,cop_arc_yon                        varchar2(1)
     ,NOM_FIC_ARC                      	 BA_BATCH.NOM_FIC_ARC%type	        
     );

   r_bat c_rec_bat;

   CURSOR cur1 ( p_nom_prg VARCHAR2
               , p_ref_cli NUMBER )
   IS
   SELECT u.nom_fic
        , u.nom_prg
        , u.tst_prd
        , u.dir_prg
        , REPLACE(u.tit_prg,'&',NULL) tit_prg
        , u.cod_typ_prg
        , u.cod_ver
        , user
        , r.cod_log
        , ','||c.lib_1er||','||c.lib_2em||','||c.lib_3em||',' log_act
    FROM ba_code_multi      c		-- ba_code_multi, c'est voulu on veut les valeurs par défaut
        ,ba_ref_client      r
        ,ba_v_programme_uti u
   WHERE u.nom_prg     = p_nom_prg
     AND r.ref_cli     = p_ref_cli
     AND c.nom_cod (+) = 'COD_LOG'
     AND c.dgn_cod (+) = r.cod_log;

   r_cur1 cur1%ROWTYPE;

   CURSOR cur2 (p_seq_bat NUMBER) IS
          SELECT COUNT(*)
            FROM ba_batch_par p
           WHERE p.seq_bat = p_seq_bat;
   
   CURSOR c_que (p_cod IN VARCHAR2, p_que IN VARCHAR2) IS
          SELECT lib_1er  /* web server report                                 / winger queue       */
                ,lib_2em  /* web directory archive                             / winger dir_prod    */
                ,lib_3em  /* web user password dans variable system            / winger dir_test    */
                ,rmq_cod  /* web url sur le directory d'archive pour preview   / winger pas utilisé */
            FROM ba_code_multi 
           WHERE nom_cod = p_cod
             AND dgn_cod = p_que;
   r_que c_que%ROWTYPE;
   

FUNCTION FU_DIRECTORY RETURN VARCHAR2
IS
/*
**  Recherche du nom de répertoire sélectionné 
*/
BEGIN
	
   z_trace.begin_procedure( p_package   => 'PA_BATCH', p_procedure => 'FU_DIRECTORY' );

   IF name_in('bl_bat.nom_fic_imp') is not null then
   	  w_directory := substr( name_in('bl_bat.nom_fic_imp'), 1, instr(name_in('bl_bat.nom_fic_imp'),NAME_IN('GLOBAL.G_INI_OFISA_GEFI_SYSTEM_DIRECTORY_SEPARATOR'),-1) );
   end if;
   
   z_trace.end_procedure( p_package   => 'PA_BATCH', p_procedure => 'FU_DIRECTORY' );

   return w_directory;
   
END FU_DIRECTORY;
	 

FUNCTION FU_WHICH_NAME 
         RETURN VARCHAR2
IS

BEGIN
   
   z_trace.begin_procedure( p_package   => 'PA_BATCH', p_procedure => 'FU_WHICH_NAME' );

   IF  v_override
   AND v_nom_prg IS NOT NULL 
   THEN
     RETURN (v_nom_prg);
   END IF; 

   z_trace.end_procedure( p_package   => 'PA_BATCH', p_procedure => 'FU_WHICH_NAME');

   RETURN (NAME_IN('parameter.nom_prg'));

END FU_WHICH_NAME;


FUNCTION FU_NOM_FIC ( p_nom_fic IN VARCHAR2
                    , p_num_fic IN NUMBER)
  RETURN VARCHAR2
IS

   v_num_fic  NUMBER := p_num_fic;

BEGIN
   
   RETURN(SUBSTR(p_nom_fic,1,INSTR(p_nom_fic,'.',-1)-1)||
          TO_CHAR(p_num_fic)||
          SUBSTR(p_nom_fic,INSTR(p_nom_fic,'.',-1)));

END FU_NOM_FIC;

PROCEDURE PR_NEW_NAME_OF_PRG ( p_prg_name IN VARCHAR2 := NULL, p_override IN BOOLEAN := FALSE)
IS
BEGIN
   
   z_trace.begin_procedure( p_package   => 'PA_BATCH', p_procedure => 'PR_NEW_NAME_OF_PRG' );

   v_nom_prg  := p_prg_name;
   v_override := p_override;

   z_trace.end_procedure( p_package   => 'PA_BATCH', p_procedure => 'PR_NEW_NAME_OF_PRG' );

END PR_NEW_NAME_OF_PRG;


PROCEDURE PR_RUN_CRYSTAL IS

/*
**  Lancement d'une liste Crystal Reports en mode Client/serveur
*/

   v_commande      VARCHAR2(512);
   v_ok		         BOOLEAN := FALSE;
   v_pathname		   VARCHAR2(255) := RTRIM(NAME_IN('GLOBAL.G_INI_OFISA_GEFI_EXE'),'\')||'\';

BEGIN
   
   z_trace.begin_procedure( p_package   => 'PA_BATCH', p_procedure => 'PR_RUN_CRYSTAL' );

   v_commande :=   v_pathname
                 ||'OI_Aff_CR.exe /num_seq='
                 ||TO_CHAR(r_bat.seq_bat)
                 ||' /user='
                 ||pa_var.v_user_name
                 ||' /pwd='
                 ||pa_var.v_password
                 ||' /db='
                 ||pa_var.v_conn_string
                 ;

   IF pa_var.v_debug THEN
   	  message('Lancement CR version c/s');
   	  message(v_commande);pause;
   END IF;	  
   	  
   v_ok := WINEXEC_OFISA.EXECUTE( v_commande, CLIENT_UTIL.SW_SHOWNORMAL );

   IF not v_ok THEN
      PA_MSG.AFF_MSG( 'STD', 197 , TRUE, 'STOP', TRUE, 1, v_commande );
   END IF;

   z_trace.end_procedure( p_package   => 'PA_BATCH', p_procedure => 'PR_RUN_CRYSTAL' );

END PR_RUN_CRYSTAL;


PROCEDURE PR_RUN_CRYSTAL_WEB IS

/*
**  Lancement d'une liste Crystal Reports en mode Client/serveur
*/

BEGIN
   
   z_trace.begin_procedure( p_package   => 'PA_BATCH', p_procedure => 'PR_RUN_CRYSTAL_WEB' );
	 NULL;
   z_trace.end_procedure( p_package   => 'PA_BATCH', p_procedure => 'PR_RUN_CRYSTAL_WEB' );

END PR_RUN_CRYSTAL_WEB;


FUNCTION FU_CONC ( p_var1 VARCHAR2
                 , p_var2 VARCHAR2) RETURN VARCHAR2
/*
** Permet de concaténer les deux paramètres à moins que le second parmètre soit NULL.
** Dans ce cas la fonction retourne NULL.
*/
IS
BEGIN
  IF p_var2 IS NULL THEN
    RETURN(NULL);
  END IF;
  RETURN(p_var1||p_var2);
END FU_CONC;


FUNCTION FU_PATH_EXISTS(p_path  IN VARCHAR2) RETURN BOOLEAN
/*
** NIC 04.02.2008 : Cette fonction permet de contrôler que le chemin passé en paramètre est valide
**                  Pour ce faire, on crée un fichier test qui est ensuite effacé.
*/
IS

  v_tst_fil  client_text_io.File_Type;
  v_filename VARCHAR2(2000) := p_path || 'testfile.txt';

BEGIN
   
   z_trace.begin_procedure( p_package   => 'PA_BATCH', p_procedure => 'FU_PATH_EXISTS' );

  IF pa_var.v_debug THEN
    message('Contrôle l''existence du chemin suivant:' || p_path);pause;
  END IF;
  
  v_tst_fil := client_text_io.FOPEN(v_filename, 'w');
  client_util.fclose(v_tst_fil);         
  CLIENT_UTIL.Delete_File (v_filename, TRUE);

   z_trace.end_procedure( p_package   => 'PA_BATCH', p_procedure => 'FU_PATH_EXISTS' );

  /* Le chemin est valide car on a pu créer un fichier */
  RETURN TRUE;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN RAISE;   /* Ne devrait pas se produire car on ne lit pas de données! */
    /*
    ** On doit obligatoirement utiliser "when others" pour la raison suivante (trouvée sur Metalink):
    ** The NO_DATA_FOUND exception signifies the end of a file when reading, but all other errors
    ** (file system full, file not found, etc.) raise the generic exception ORA 302000,
    ** which can be trapped by a when others exception handler.
    */
    WHEN OTHERS THEN RETURN FALSE;

END FU_PATH_EXISTS;

FUNCTION FU_DESTRIBUTION_LIST_FILE( p_dir_cpy     IN VARCHAR2   -- Emplacement (path) du fichier de destination
                                  , p_arc_nam_eff IN VARCHAR2   -- Nom du fichier de destination (sans l'extension)
                                  , p_des_nam_eff IN VARCHAR2   -- Nom du fichier destination demandé (sans l'extension)
                                  , p_nbr_cop     IN VARCHAR2   -- Nombre de copies spécifiées
                                  , p_dir_fmt     IN VARCHAR2   -- Format du fichier demandé
                                  , p_des_typ     IN VARCHAR2   -- Destination du report (file, printer, screen)
                                  , p_dir_common  IN VARCHAR2 DEFAULT NULL -- Destination commune des fichiers (pour fichiers DST)
                                  ) RETURN VARCHAR2
/*
** NIC 31.01.2008 : Cette fonction crée le fichier de distribution et retourne les bons paramètres
**                  afin de compléter la ligne de commande avec le nom du fichier créé.
** TEA 15.03.2011 : Ajout gestion des répertoires avec ou sans la classe pour archivage
*/
IS
  v_lig      NUMBER;
  --v_dir_dst  VARCHAR2(2000)        := p_dir_cpy  || 'dst\';
  v_dir_dst  VARCHAR2(2000)        := nvl(p_dir_common,p_dir_cpy)||'dst\';     -- Path de la liste de destination
  v_dst_fil  client_text_io.File_Type;
  
BEGIN
   
   z_trace.begin_procedure( p_package   => 'PA_BATCH', p_procedure => 'FU_DESTRIBUTION_LIST_FILE' );

  IF pa_var.v_debug THEN
    message('p_dir_cpy : '     ||p_dir_cpy     ||'<');pause;
    message('p_arc_nam_eff : ' ||p_arc_nam_eff ||'<');pause;
    message('p_nbr_cop : '     ||p_nbr_cop     ||'<');pause;
    message('p_dir_fmt : '     ||p_dir_fmt     ||'<');pause;
    message('p_dir_dst : '     ||v_dir_dst     ||'<');pause;
    message('p_dir_common : '  ||p_dir_common  ||'<');pause;
  END IF;
  
  /* Est-ce que le chemin pour le fichier destination est valide ? Les droits sont-ils suffisants ? */
  IF FU_PATH_EXISTS(v_dir_dst) THEN
  
    v_lig := 1;
    /* Création du fichier et écriture de la ligne */
    v_dst_fil := client_text_io.FOPEN( v_dir_dst || p_arc_nam_eff || '.dst', 'w' );
    client_util.put_line( v_dst_fil, TO_CHAR(v_lig) || ': desname=' || p_dir_cpy || p_arc_nam_eff || '.pdf desformat=PDF destype=File copies=1 level=Report');
    v_lig := v_lig + 1;

    /* Ce qui a été demandé par l'utilisateur                                    */
    /* Si le format (desformat) n'est pas spécifier, on force BITMAP. Car si on  */
    /* ne le fait pas, il est impossible d'envoyer directement à l'imprimante... */
    client_util.put_line( v_dst_fil, TO_CHAR(v_lig) || ': ' || FU_CONC('desname='   , p_des_nam_eff)
                                                      || FU_CONC(' desformat=', nvl(p_dir_fmt, 'BITMAP'))
                                                      || FU_CONC(' destype='  , p_des_typ)
                                                      || FU_CONC(' copies='   , p_nbr_cop)
                                                      || ' level=Report');
    client_util.fclose( v_dst_fil );
  ELSE
    PA_MSG.AFF_MSG( 'STD', 188, TRUE, 'STOP', TRUE, 1, v_dir_dst );  /* NIC4 : suppression des parenthèses à double */
  END IF;

  IF pa_var.v_debug THEN
    message('FU_DESTRIBUTION_LIST_FILE retourne : ' ||v_dir_dst||p_arc_nam_eff|| '.dst' || '<');pause;
  END IF;

   z_trace.end_procedure( p_package   => 'PA_BATCH', p_procedure => 'FU_DESTRIBUTION_LIST_FILE' );

  /* On retourne le fichier contenant la liste de distribution avec le path complet */
  RETURN v_dir_dst||p_arc_nam_eff||'.dst';
  
END FU_DESTRIBUTION_LIST_FILE;

FUNCTION FU_RUN_PRODUCT_WEB RETURN BOOLEAN
IS        

   v_rep_id       report_object;
   v_connect      VARCHAR2(255);   

   v_ok           BOOLEAN;

   v_des_nam      VARCHAR2(255);
   v_arc_nam      VARCHAR2(255);
   v_des_nam_eff  VARCHAR2(255);
   v_arc_nam_eff  VARCHAR2(255);
     
	 v_rep_sta      VARCHAR2(255);
	 v_job_id       VARCHAR2(255);
	 v_dir_fmt      VARCHAR2(255);
   v_dir_cpy      VARCHAR2(255) := NULL;
   v_dir_htt      VARCHAR2(2000):= NULL;

	 v_com          VARCHAR2(2000);
   v_srv          VARCHAR2(255);
   v_des_typ      VARCHAR2(255);
   v_upd          VARCHAR2(255);
   v_bat          VARCHAR2(255);
   
   v_client_file_dest		VARCHAR2(255);

-- NIC 31.01.2008 : variables plus nécessaires car la construction du fichier de distribution
--                  a été déplacé dans FU_CREATE_DESTINATION_FILE
--   v_lig      NUMBER;
--   v_dst_fil   Text_IO.File_Type;      
   
BEGIN
   
   z_trace.begin_procedure( p_package   => 'PA_BATCH', p_procedure => 'FU_RUN_PRODUCT_WEB' );

      IF  pa_var.v_debug THEN
	       message('Début de PR_RUN_PRODUCT_WEB'); pause;
      END IF;
   
      /*
      ** L'objet report dummy doit se trouver dans le forms sinon tintin
      */  
      v_srv     := r_que.lib_1er;
      v_dir_cpy := r_que.lib_2em;
      
      IF SUBSTR(v_dir_cpy,-1) <> NAME_IN('GLOBAL.G_INI_OFISA_GEFI_SYSTEM_DIRECTORY_SEPARATOR')
      THEN
        v_dir_cpy := v_dir_cpy || NAME_IN('GLOBAL.G_INI_OFISA_GEFI_SYSTEM_DIRECTORY_SEPARATOR');
      END IF;
      
      v_dir_cpy := lower(v_dir_cpy);
      v_dir_htt := r_que.rmq_cod;      
      v_upd     := NVL(r_que.lib_3em,'unpw'); 
      
      IF  pa_var.v_debug THEN
	       message('v_srv='||v_srv||' v_dir_cpy='||v_dir_cpy||' v_dir_htt='||v_dir_htt); pause;
      END IF;

      IF v_srv IS NULL
      OR v_dir_cpy IS NULL
      OR v_dir_htt IS NULL
      THEN
        PA_MSG.AFF_MSG('STD', 104, TRUE, 'STOP',  TRUE, 1, 'File batch obligatoire' );    
      END IF;
      
      v_des_nam     := R_BAT.NOM_FIC_IMP;
      v_dir_fmt     := lower(NVL(R_bat.dir_fmt,'pdf'));         
      v_des_typ     := NULL;
           
      IF UPPER( r_bat.cod_trt ) IN ('SCREEN', 'PREVIEW')
      THEN
             /* si screen, preview ...même combat...*/
             v_des_nam :=  v_dir_cpy||R_BAT.NOM_FIC_ARC||'.pdf'; 
             v_dir_fmt := 'pdf';          
             v_des_typ := 'FILE';
      ELSIF UPPER( r_bat.cod_trt ) = 'CACHE' THEN
             v_des_nam :=  ''; 
             v_dir_fmt := 'pdf';          
             v_des_typ := 'CACHE';      	
      ELSIF UPPER( r_bat.cod_trt ) = 'FILE' THEN
          	 v_des_nam := R_BAT.NOM_FIC_IMP;          	 
             v_des_typ := 'FILE';          	              
             IF v_dir_fmt IS NULL
             THEN
               v_dir_fmt:= PA_UTILITAIRE.FU_PIECE(v_des_nam,'.',2,2);
             END IF;          
      ELSIF UPPER( R_bat.cod_trt ) = 'MAIL' THEN
          	 v_des_nam := R_BAT.NOM_FIC_IMP;   
           	 v_des_typ := 'MAIL';
      ELSIF UPPER( r_bat.cod_trt ) = 'PRINTER' THEN
          	 v_des_nam := R_BAT.NOM_FIC_IMP;          	
          	 v_des_typ := 'PRINTER';
      END IF;  
                    
      v_arc_nam     := R_BAT.NOM_FIC_ARC;                          

      /* si pas batch */  
      IF    UPPER(R_BAT.COD_BAT) = 'NO' 
      /* les  mail et printer en direct ne marche pas si il y a une copie archive 
        FER:   supprimer FILE dans la liste IN */
      AND   NOT(UPPER( R_bat.cod_trt ) IN ( 'MAIL', 'PRINTER') AND R_BAT.COP_ARC_YON IS NOT NULL)
      /*   problème avec le cache sous solaris ==> web.show document */
      AND  NAME_IN('GLOBAL.G_INI_OFISA_GEFI_SYSTEM_OPERATING_SYSTEM') <> 'UNIX'	
		  THEN
            IF pa_var.v_debug then
            	 message('Pas batch');pause;
            END IF;
            v_rep_id  := FIND_REPORT_OBJECT( 'DUMMY' );
            SET_REPORT_OBJECT_PROPERTY( v_rep_id, REPORT_SERVER    , v_srv );
            		      
            SET_REPORT_OBJECT_PROPERTY( v_rep_id, REPORT_FILENAME  , w_fichier);

            SET_REPORT_OBJECT_PROPERTY( v_rep_id, REPORT_EXECUTION_MODE, RUNTIME );         
            SET_REPORT_OBJECT_PROPERTY( v_rep_id, REPORT_COMM_MODE, SYNCHRONOUS );
                
            IF UPPER( R_bat.cod_trt ) IN ('SCREEN', 'PREVIEW', 'CACHE')
            THEN
               /* si screen, preview, cache...même combat...*/
               SET_REPORT_OBJECT_PROPERTY( v_rep_id, REPORT_DESTYPE, CACHE );        
            ELSIF UPPER( R_bat.cod_trt ) = 'FILE' THEN
               SET_REPORT_OBJECT_PROPERTY( v_rep_id, REPORT_DESTYPE, FILE );                        
            ELSIF UPPER( R_bat.cod_trt ) = 'MAIL' THEN
               SET_REPORT_OBJECT_PROPERTY( v_rep_id, REPORT_DESTYPE, MAIL  );            
               v_des_nam:=''''||v_des_nam||'''';
            ELSIF UPPER( R_bat.cod_trt ) = 'PRINTER' THEN
               SET_REPORT_OBJECT_PROPERTY( v_rep_id, REPORT_DESTYPE, PRINTER ); 
               v_des_nam:=''''||v_des_nam||'''';         	
            END IF;  	

              	
            SET_REPORT_OBJECT_PROPERTY( v_rep_id, REPORT_DESFORMAT     	, v_dir_fmt );
            SET_REPORT_OBJECT_PROPERTY( v_rep_id, REPORT_OTHER         , 'P_SEQ_BAT='   || R_bat.seq_bat
                                                                         ||' BLANKPAGES=NO'            
                                                                     --  ||' COPIES='     || R_bat.nbr_cop
                                                                     --  ||' ORIENTATION='|| R_bat.cod_ort 
                                                                       );
                  
            
            IF  R_bat.cod_mod IN ('CHARACTER','BITMAP') THEN
                /*
                ** Le paramètre MODE ne marche pas sur NT 4.0 on ne le charge que si nécessaire...
                */
                SET_REPORT_OBJECT_PROPERTY( v_rep_id, REPORT_OTHER         , 'MODE='||R_bat.cod_mod );
            END IF;          
                                   
            FOR i IN 1..w_nbr
              LOOP 
              /*
              ** Si lancement groupé on fait plusieurs RUN_PRODUCT
              ** en incrémentant si nécessaire le nom du fichier
              ** de sortie afin de ne pas écraser les run précédent
              ** Eh! on est pas toujours sur VMS...
              */ 
              
              v_des_nam_eff:=v_des_nam;
              v_arc_nam_eff:=v_arc_nam; 
                            
              IF  w_nbr > 1
              THEN
                IF UPPER(R_bat.cod_trt) = 'FILE' THEN
                    v_des_nam := FU_NOM_FIC( R_bat.nom_fic_imp, i );
                END IF;
                v_arc_nam_eff:=v_arc_nam||'_'||to_char(i);
              END IF;
           /* ajout FER  */  
             IF UPPER( R_bat.cod_trt ) = 'FILE' THEN
                           SET_REPORT_OBJECT_PROPERTY( v_rep_id, REPORT_DESNAME  , 'c:\temp\'||v_des_nam );                
               --            SET_REPORT_OBJECT_PROPERTY( v_rep_id, REPORT_FILENAME  , 'c:\temp\'||v_des_nam );                
             else -- fin ajout FER
                           SET_REPORT_OBJECT_PROPERTY( v_rep_id, REPORT_DESNAME  , v_des_nam );                
              end if;
              v_job_id         := run_report_object   ( v_rep_id );	              
              IF pa_var.v_debug then
            	   message('Job_id='||v_job_id);pause;
              END IF;
              v_rep_sta        := REPORT_OBJECT_STATUS( v_job_id);
                  
              CLEAR_MESSAGE;
                  
              END LOOP;
              IF pa_var.v_debug then
            	   message('Statut report='||v_rep_sta);pause;
              END IF;
              IF v_rep_sta = 'FINISHED' 
              THEN
/* FER   ajout FILE dans la liste IN */              
                 IF UPPER( R_bat.cod_trt ) IN ('SCREEN', 'PREVIEW', 'CACHE', 'FILE')            	
                 THEN
 				             IF pa_var.v_debug then
				             	  message('Copie vers répertoire output:'||v_dir_cpy||v_arc_nam_eff||'.pdf');pause;
				             END IF;
                     copy_report_object_output( v_job_id, v_dir_cpy||v_arc_nam_eff||'.pdf');
 				             IF pa_var.v_debug then
				             	  message('Show_document:'||v_dir_htt||v_arc_nam_eff||'.pdf');pause;
				             END IF;
/* 
FER  ajout traitement fichier */
										 IF UPPER( R_bat.cod_trt ) = 'FILE' 
										 THEN
              		                     synchronize;
                                   
              					v_client_file_dest := 	webutil_file.file_save_dialog(	 
              																				 directory_name => 'C:\\TEMP'
              																				,file_name => v_des_nam_eff
              																				,file_filter => '*.'||v_dir_fmt);
              	
              				  if NOT webutil_file_transfer.AS_To_Client(v_client_file_dest, 'C:\TEMP\'||v_des_nam_eff) THEN
              					  	message('error transfer report to client');
              				  END IF;   -- fin ajout FER
              		   ELSE
/* 
FER   Appel a web.show_document pour visualiser ler résultat du reports sans passer par IIS
*/ 
                        WEB.SHOW_DOCUMENT('/reports/rwservlet/getjobid'||substr(v_job_id,instr(v_job_id,'_',-1)+1)||'?'||'server='||v_srv,'_blank');
                        synchronize;
              		   END IF;
                                          
                 END IF;
              ELSE
                 PA_MSG.AFF_MSG('STD', 104, TRUE, 'STOP',  FALSE, 1, v_rep_sta );               	 
              END IF;
            PR_NEW_NAME_OF_PRG;
		  ELSE
-- FER    mode batch aussi avec run_report_object
--
         IF  pa_var.v_debug THEN
	           message('Batch'); pause;
         END IF;

/* initialisation du REPORT_OBJECT */

            v_rep_id  := FIND_REPORT_OBJECT( 'DUMMY' );
            SET_REPORT_OBJECT_PROPERTY( v_rep_id, REPORT_SERVER    , v_srv );
            		      
            SET_REPORT_OBJECT_PROPERTY( v_rep_id, REPORT_FILENAME  , w_fichier);

            SET_REPORT_OBJECT_PROPERTY( v_rep_id, REPORT_EXECUTION_MODE, BATCH );         
            SET_REPORT_OBJECT_PROPERTY( v_rep_id, REPORT_COMM_MODE, ASYNCHRONOUS );

            IF UPPER( R_bat.cod_trt ) = 'FILE' THEN
               SET_REPORT_OBJECT_PROPERTY( v_rep_id, REPORT_DESTYPE, FILE );                        
            ELSIF UPPER( R_bat.cod_trt ) = 'MAIL' THEN
               SET_REPORT_OBJECT_PROPERTY( v_rep_id, REPORT_DESTYPE, MAIL  );            
               v_des_nam:=''''||v_des_nam||'''';
            ELSIF UPPER( R_bat.cod_trt ) = 'PRINTER' THEN
               SET_REPORT_OBJECT_PROPERTY( v_rep_id, REPORT_DESTYPE, PRINTER ); 
               v_des_nam:=''''||v_des_nam||'''';         	
            END IF;  	
              	
            SET_REPORT_OBJECT_PROPERTY( v_rep_id, REPORT_DESFORMAT     	, v_dir_fmt );
            SET_REPORT_OBJECT_PROPERTY( v_rep_id, REPORT_OTHER         , 'P_SEQ_BAT='   || R_bat.seq_bat
                                                                         ||' BLANKPAGES=NO'            
                                                                     --  ||' COPIES='     || R_bat.nbr_cop
                                                                     --  ||' ORIENTATION='|| R_bat.cod_ort 
                                                                       );
                  
            IF  R_bat.cod_mod IN ('CHARACTER','BITMAP') THEN
                /*
                ** Le paramètre MODE ne marche pas sur NT 4.0 on ne le charge que si nécessaire...
                */
                SET_REPORT_OBJECT_PROPERTY( v_rep_id, REPORT_OTHER         , 'MODE='||R_bat.cod_mod );
            END IF;          

            

	    /*
            **  Création dynamique du fichier de destination
            */
 
            IF UPPER( R_bat.cod_trt ) IN ('MAIL', 'PRINTER')
            THEN       
               v_des_nam:='"'||v_des_nam||'"';         	
            END IF; 

               
            FOR i IN 1..w_nbr
              LOOP 
              /*
              ** Si lancement groupé on fait plusieurs RUN_PRODUCT
              ** en incrémentant si nécessaire le nom du fichier
              ** de sortie afin de ne pas écraser les run précédent
              ** Eh! on est pas toujours sur VMS...
              */ 

              v_des_nam_eff:=v_des_nam;
              v_arc_nam_eff:=v_arc_nam;  
                     
              IF  w_nbr > 1
              THEN
                IF v_des_typ = 'FILE'
                THEN
                  v_des_nam_eff := FU_NOM_FIC( v_des_nam , i );
                END IF;
                v_arc_nam_eff := v_arc_nam || '_' || to_char(i);
              END IF;   
                                                                                                              
              /* partie commune de tous les lancements reports */                                        
              IF v_des_typ = 'FILE' THEN

                           SET_REPORT_OBJECT_PROPERTY( v_rep_id, REPORT_DESNAME  , v_dir_cpy||v_des_nam_eff );                
              ELSE	
	              
                           SET_REPORT_OBJECT_PROPERTY( v_rep_id, REPORT_DESNAME  , v_des_nam_eff );                

							END IF;
                                      
              /* si copie archive pour printer mail et file alors on fait une liste de distribution */                                      
              IF  r_BAT.cop_arc_yon      IS NOT NULL
              AND UPPER( R_bat.cod_trt ) IN ('PRINTER', 'MAIL', 'FILE')
              THEN
/*  NIC 31.01.2008 : La création du fichier de distribution est maintenant réalisée par la fonction FU_DESTRIBUTION_LIST_FILE.
                v_lig:=1;                
                v_dst_fil := TEXT_IO.FOPEN( v_dir_cpy||v_arc_nam_eff||'.dst', 'w' );                
                TEXT_IO.PUT_LINE( v_dst_fil,TO_CHAR(v_lig)||': desname='||v_dir_cpy||v_arc_nam_eff||'.pdf desformat=PDF destype=File copies=1 level=Report');
                v_lig:= v_lig+1;
                /* ce qui a été demandé */

                SET_REPORT_OBJECT_PROPERTY( v_rep_id, REPORT_DESNAME  , FU_DESTRIBUTION_LIST_FILE(v_dir_cpy, v_arc_nam_eff, v_des_nam_eff, R_bat.nbr_cop, v_dir_fmt, v_des_typ) );                
                SET_REPORT_OBJECT_PROPERTY( v_rep_id, REPORT_OTHER  , 'distribute=yes' );
              END IF;
              
              v_bat :=  UPPER(R_BAT.COD_BAT);
              
              v_job_id         := run_report_object   ( v_rep_id );	              

              

              IF FORM_SUCCESS
              THEN
                 IF UPPER( R_bat.cod_trt ) IN ('SCREEN', 'PREVIEW')
                 THEN
								   IF  pa_var.v_debug THEN
									    message('show_doc:'||v_dir_htt||v_arc_nam_eff||'.'||v_dir_fmt);pause;
								   END IF;
                     WEB.SHOW_DOCUMENT('/reports/rwservlet/getjobid'||substr(v_job_id,instr(v_job_id,'_',-1)+1)||'?'||'server='||v_srv,'_blank');
                     synchronize;
--                    web.show_document(v_dir_htt||v_arc_nam_eff||'.'||v_dir_fmt);
                 END IF;
              ELSE
              	 PA_MSG.AFF_MSG('STD', 104, TRUE, 'CAUTION', FALSE, 1, v_com);
              END IF;
              END LOOP;
        PR_NEW_NAME_OF_PRG;              

		END IF;		      

    /*
    ** EXEMPLES DE WEB.SHOW_DOCUMENT
    v_com := v_dir_htt||'rwcgi60?unpw2&report='||w_fichier
                             --  ||FU_CONC(' userid=',w_log)
                                 ||FU_CONC('&server=',v_srv)
                                 ||FU_CONC('&destination=',v_dir_cpy||R_bat.NOM_FIC_ARC||'_'||TO_CHAR(I)||'.dst')
                                 ||'&distribute=yes&background=yes'
                                 ||FU_CONC('&P_SEQ_BAT=',R_bat.seq_bat)
                                 ||FU_CONC('&COPIES=', R_bat.nbr_cop)
                                 ||FU_CONC('&ORIENTATION=',R_bat.cod_ort);
   WEB.SHOW_DOCUMENT(v_com);                                        
                
   v_com := v_dir_htt||'rwcgi60?'||v_upd||'&report='||w_fichier
                                 ||FU_CONC('&server=',v_srv)
                                 ||'&destype=cache&desformat=pdf'
                                 ||FU_CONC('&P_SEQ_BAT=',R_bat.seq_bat)
                                 ||FU_CONC('&COPIES=', R_bat.nbr_cop)
                                 ||FU_CONC('&ORIENTATION=',R_bat.cod_ort);                
   WEB.SHOW_DOCUMENT(v_com);                
   */

   z_trace.end_procedure( p_package   => 'PA_BATCH', p_procedure => 'FU_RUN_PRODUCT_WEB' );

   RETURN TRUE;

EXCEPTION
   WHEN FORM_TRIGGER_FAILURE THEN RETURN FALSE;
   WHEN OTHERS THEN RAISE;
	  
END FU_RUN_PRODUCT_WEB;


FUNCTION FU_RUN_PRODUCT_STD RETURN BOOLEAN
IS

   v_par_id       PARAMLIST;
   v_par_name     VARCHAR2(10)  := 'PAR_BATCH';
   v_ok           BOOLEAN;
   v_fic_imp      VARCHAR2(512);
   v_fic_arc      VARCHAR2(512);             -- NIC 31.01.2008 : Nom du fichier PDF pour l'archivage
   v_work         VARCHAR2(20);
   v_dir_cpy      VARCHAR2(255) := NULL;     -- NIC 31.01.2008 : Emplacement des fichiers pour l'archivage
   v_classe     	VARCHAR2(255) := NULL;		 -- TEA 15.03.2011 : Répertoire et nom supplémentaire (classe de document GED) - pour JOURNAL via UTI901
   v_des_nam      VARCHAR2(255);             -- NIC 31.01.2008 : Nom du fichier de distribution
   v_cod_app_ged  VARCHAR2(10);              -- NIC 09.05.2008 : Code de l'application GED utilisée
   v_seq_bat      BA_BATCH_PAR.SEQ_BAT%TYPE;

  CURSOR c_param (p_soc NUMBER) IS
  SELECT par_001
   FROM ba_parametre
  WHERE num_soc = p_soc
    AND cod_par = 'GED';
                                               
  CURSOR c_soc (p_soc NUMBER) IS
  SELECT upper(s.cod_app_ged)
    FROM ba_societe s
   WHERE s.num_soc  = p_soc;
   
  CURSOR c_classe (p_soc NUMBER, p_prog CHAR) IS
  SELECT des
   FROM ba_heading
	WHERE num_soc = p_soc
 		AND cod_app_ori = 'GED' 
		AND cod_lan = '1' 
  	AND nom_doc = p_prog;

  r_batch  BA_BATCH%ROWTYPE;
  	
BEGIN
   
   z_trace.begin_procedure( p_package   => 'PA_BATCH', p_procedure => 'FU_RUN_PRODUCT_STD' );

   /* Etant donné qu'il est désormais possible de lancer plusieurs fois un batch à partir d'un même
   ** form bat il faut s'assurer que la liste n'existe pas
   */
   v_par_id := Get_Parameter_List(v_par_name); 
   
   IF pa_var.v_debug THEN
   	 message('Paramètre NOM_FIC = '||r_bat.nom_fic);
   	 message('Paramètre NOM_PRG = '||r_bat.nom_prg);
   	 message('Paramètre DIR_PRG = '||r_bat.dir_prg);
   	 message('Paramètre TIT_PRG = '||r_bat.tit_prg);
   END IF;	  
   
   IF NOT Id_Null(v_par_id) 
   THEN 
     Destroy_Parameter_List(v_par_id); 
   END IF; 
   v_par_id  := migprint.mig_create_parameter_list( v_par_name ); 
   
   migprint.mig_add_parameter( v_par_id, 'PARAMFORM'  , TEXT_PARAMETER, 'NO' );

   --
   -- P_SEQ_BAT créé ici seulement si pas de lancement groupé autrement il est dans la boucle
   -- mais comme ça on ne modifie rien à la logique quand c'est un lancement simple, ça évite les risques

   v_seq_bat := r_bat.seq_bat;
   
   IF  w_nbr = 1 THEN
     migprint.mig_add_parameter( v_par_id, 'P_SEQ_BAT'  , TEXT_PARAMETER, v_seq_bat );
   END IF;

   migprint.mig_add_parameter( v_par_id, 'DESTYPE'    , TEXT_PARAMETER, r_bat.cod_trt );
   IF  r_bat.dir_fmt IS NOT NULL THEN
       migprint.mig_add_parameter( v_par_id, 'DESFORMAT'  , TEXT_PARAMETER, r_bat.dir_fmt );
   END IF;
   IF  UPPER(r_bat.dir_fmt) = 'DELIMITEDDATA' THEN -- Report 6 et + seulement
       migprint.mig_add_parameter( v_par_id, 'DELIMITER'      , TEXT_PARAMETER, ';' );
--       ADD_PARAMETER( v_par_id, 'CELLWRAPPER'    , TEXT_PARAMETER, '"' ); NE MARCHE PAS IL FAUT LE METTRE A LA FIN / RAI 6.4.2005
       migprint.mig_add_parameter( v_par_id, 'DATEFORMATMASK' , TEXT_PARAMETER, 'dd.mm.yyyy' );
   END IF;
   
   migprint.mig_add_parameter( v_par_id, 'COPIES'     , TEXT_PARAMETER, r_bat.nbr_cop );
   migprint.mig_add_parameter( v_par_id, 'ORIENTATION', TEXT_PARAMETER, r_bat.cod_ort );

   /*
   ** VUL - 30.12.2005 On interdit la fonction File -> Generate to file car elle réexécute le report
   **                  ce qui pourrait faire des horreurs dans ceux qui font de la mise à jour
   */
   migprint.mig_add_parameter( v_par_id, 'DISABLEFILE', TEXT_PARAMETER, 'YES' );

   /* Chargement de la destination où seront stockés les fichiers pour l'archivage */
   open c_soc(r_bat.num_soc);
   fetch c_soc into v_cod_app_ged;
   close c_soc;

   /*
   ** NIC - 31.01.2008 On interdit l'impression depuis l'aperçu si la liste doit être archivée.
   **                  De cette manière on évite d'oublier d'archiver des documents.
   */
   IF pa_var.v_debug THEN
   	  message('avant le DISABLEPRINT');pause;
   END IF;	  
   IF v_cod_app_ged in ('INFOSTORE', 'KENDOX') and r_BAT.cop_arc_yon IS NOT NULL AND UPPER( R_bat.cod_trt ) IN ('SCREEN', 'PREVIEW') THEN
     migprint.mig_add_parameter( v_par_id, 'DISABLEPRINT', TEXT_PARAMETER, 'YES' );
   END IF;
   IF pa_var.v_debug THEN
   	  message('après le DISABLEPRINT');pause;
   END IF;	  

   IF  r_cur1.cod_ver IN ( 'R2B', 'RMB', 'RWB' ) THEN
   /*
   ** Pour ce programme on veut forcer le paramètre NONBLOCKSQL
   */ 
      v_work := 'NO';
   ELSE
      v_work := UPPER(NAME_IN('GLOBAL.G_INI_OFISA_GEFI_R25_NONBLOCK'));
   END IF;  
   IF  UPPER(v_work) IN ('YES','NO') THEN
       migprint.mig_add_parameter( v_par_id, 'NONBLOCKSQL',     TEXT_PARAMETER, v_work );
   END IF;
   
   migprint.mig_add_parameter( v_par_id, 'BLANKPAGES', TEXT_PARAMETER, 'NO' );   

   IF  r_bat.cod_mod IN ('CHARACTER','BITMAP') THEN
       /*
       ** Le paramètre MODE ne marche pas sur NT 4.0 on ne le charge que si nécessaire...
       */
       migprint.mig_add_parameter( v_par_id, 'MODE', TEXT_PARAMETER, r_bat.cod_mod );
   END IF;

   IF  w_queue IS NOT NULL THEN
     /*
     ** On execute le report sur un autre PC
     */
     migprint.mig_add_parameter( v_par_id, 'SERVER', TEXT_PARAMETER, w_queue );
     v_work := pa_internal.fu_schedule(NAME_IN('BL_BAT.DAY_TRT'), NAME_IN('BL_BAT.TIM_TRT'));
     IF  v_work IS NOT NULL THEN
       migprint.mig_add_parameter( v_par_id, 'SCHEDULE', TEXT_PARAMETER, v_work );
     END IF;

   ELSE
 	    v_work := INITCAP(NAME_IN('GLOBAL.G_INI_OFISA_GEFI_R25_SHUTDOWN'));

      IF  UPPER(v_work) = 'YES' THEN
         migprint.mig_add_parameter( v_par_id, 'ORACLE_SHUTDOWN', TEXT_PARAMETER, 'Yes' );
      END IF;

   END IF;   
  
   IF pa_var.v_debug THEN
   	  message('avant la boucle pour lancements groupés');pause;
   END IF;	  

   FOR i IN 1..w_nbr
     LOOP 
     /*
     ** Si lancement groupé on fait plusieurs RUN_PRODUCT
     ** en incrémentant si nécessaire le nom du fichier
     ** de sortie afin de ne pas écraser les run précédent
     ** Eh! on est pas toujours sur VMS...
     */ 
     IF  w_nbr > 1
     AND UPPER(r_bat.cod_trt) = 'FILE' THEN
         v_fic_imp := FU_NOM_FIC( r_bat.nom_fic_imp, i );
         v_fic_arc := FU_CONC( r_bat.nom_fic_arc, to_char(i) );
     ELSE
         v_fic_imp := r_bat.nom_fic_imp;
         v_fic_arc := r_bat.nom_fic_arc;
     END IF;
     IF  Instr(v_fic_imp,' ') <> 0 THEN
         v_fic_imp := '"'||v_fic_imp||'"';
     END IF;

     IF pa_var.v_debug THEN
     	  message('desname ('||to_char(i)||') ='||v_fic_imp||' DESTYPE='||r_bat.cod_trt );pause;
     END IF;	  

     migprint.mig_add_parameter( v_par_id, 'DESNAME', TEXT_PARAMETER, v_fic_imp );

     /* NIC 31.01.2008 : Création d'une liste de distribution également si pas Web pour alimenter archivage. */
     /* si copie archive pour printer mail et file alors on fait une liste de distribution */                                      
     IF v_cod_app_ged in ('INFOSTORE', 'KENDOX') AND r_BAT.cop_arc_yon IS NOT NULL AND UPPER(R_bat.cod_trt) IN ('PRINTER', 'MAIL', 'FILE') THEN

       /* Chargement de la destination où seront stockés les fichiers pour l'archivage */
       open c_param(r_bat.num_soc);
       fetch c_param into v_dir_cpy;
       close c_param;
       
       /* Chargement de la classe de destination */
       open c_classe(r_bat.num_soc,r_bat.nom_fic);
       fetch c_classe into v_classe;
       close c_classe;

       IF pa_var.v_debug THEN
     	   message('1. v_dir_cpy = '||v_dir_cpy);
     	   message('1b. v_classe = '||v_classe);
       END IF;	  

       v_dir_cpy := RTRIM(v_dir_cpy, '\') || '\';
       if v_classe is not null then
       	v_classe  := RTRIM(v_classe, '\') || '\';
       end if;
       
       IF pa_var.v_debug THEN
     	   message('2. v_dir_cpy = '||v_dir_cpy);
     	   message('2b. v_classe = '||v_classe);
	       message('Path construit = '||v_dir_cpy||v_classe);
       END IF;	  

       v_des_nam := FU_DESTRIBUTION_LIST_FILE(v_dir_cpy||v_classe, v_fic_arc, v_fic_imp, r_bat.nbr_cop, r_bat.dir_fmt, r_bat.cod_trt, v_dir_cpy);
       
       IF pa_var.v_debug THEN
     	   message('v_des_nam=' ||v_des_nam);
       END IF;

       migprint.mig_add_parameter( v_par_id, 'DESTINATION', TEXT_PARAMETER , v_des_nam);
       IF pa_var.v_debug THEN
         message('après DESTINATION');pause;
       END IF;	  
       migprint.mig_add_parameter( v_par_id, 'DISTRIBUTE' , TEXT_PARAMETER , 'YES');
       IF pa_var.v_debug THEN
     	   message('après DISTRIBUTE');pause;
       END IF;
     END IF;

     IF  UPPER(r_bat.dir_fmt) = 'DELIMITEDDATA' THEN -- Report 6 et + seulement
     	   /*
     	   ** Bug Oracle : Ce paramètre doit être le dernier sinon reports ne comprend rien / RAI 6.4.2005
     	   */
         migprint.mig_add_parameter( v_par_id, 'CELLWRAPPER', TEXT_PARAMETER, '"' );
     END IF;

     -- Traitement de p_Seq_bat dans le cas des lancements groupés. 
     --
     -- Comme ca ne marche plus en 64 bits car les reports partent en parallèle et attrappent tous le 1er jeu de paramètres
     -- on génére non plus une sequence batch avec plusieurs records dans batch_par mais des sequences batch independantes
     -- pour chaque jeu de paramètres.
     -- Ca oblige à renuméroter la sequence dans BA_BATCH_PAR et insérer un nouveau record dans BA_BATCH avec le nouveau numéro
     -- y compris pour le 1er jeu de parametres sans quoi on fait des locks...

     IF  w_nbr > 1 THEN
     	 --
       IF pa_var.v_debug THEN
   	    message('Ajout p_seq_bat avec la valeur '||TO_CHAR( v_seq_bat) );pause;
       END IF;
       --
       	 v_Seq_bat := Pa_Ba_Report.FU_RENUMEROTE_SEQ_BAT(r_bat.seq_bat, i );
         IF pa_var.v_debug THEN
     	      message('Saisie no '||to_char(i)|| ' --> nouvelle valeur de seq_bat = '||to_char(v_seq_bat));pause;
         END IF;
       --
       CLEAR_MESSAGE;
       COMMIT_FORM;
       CLEAR_MESSAGE;
       migprint.mig_add_parameter( v_par_id, 'P_SEQ_BAT'  , TEXT_PARAMETER, v_seq_bat );
       --
     END IF;
     
     IF pa_var.v_debug THEN
   	   message('avant RUNPRODUCT');pause;
     END IF;
     migprint.mig_run_product( REPORTS, w_fichier, ASYNCHRONOUS, RUNTIME, FILESYSTEM, v_par_name, NULL );
     IF pa_var.v_debug THEN
   	   message('après RUNPRODUCT');pause;
     END IF;	  
         
     CLEAR_MESSAGE;
         
     IF UPPER(r_bat.dir_fmt) = 'DELIMITEDDATA' THEN -- Report 6 et + seulement
       DELETE_PARAMETER( v_par_id, 'CELLWRAPPER');
     END IF;
     DELETE_PARAMETER( v_par_id, 'DESNAME');

     /*----------------------------------------------------------------------------------------------*/
     /* NIC 06.02.2008 : Il faut supprimer à chaque itération de la boucle les paramètres créés pour */
     /*                  une liste de distribution car ceux-ci ne peuvent pas être créés s'ils       */
     /*                  existent déjà. Or cela se produit dans le cas d'un lancement multiple!      */
     /*----------------------------------------------------------------------------------------------*/
     /* NIC 29.05.2009 : Il faut tester également si la GED est active => on détruit les paramètre   */
     /*                  dans les mêmes conditions que lors de leur création. NIC3                   */
     /*----------------------------------------------------------------------------------------------*/
--     IF r_BAT.cop_arc_yon IS NOT NULL AND UPPER( R_bat.cod_trt ) IN ('PRINTER', 'MAIL', 'FILE') THEN
     IF v_cod_app_ged in ('INFOSTORE', 'KENDOX') AND r_BAT.cop_arc_yon IS NOT NULL AND UPPER( R_bat.cod_trt ) IN ('PRINTER', 'MAIL', 'FILE') THEN
       DELETE_PARAMETER( v_par_id, 'DESTINATION');
       DELETE_PARAMETER( v_par_id, 'DISTRIBUTE');
     END IF;

     IF  w_nbr > 1 THEN

        IF pa_var.v_debug THEN
           message('Destruction du paramètre P_SEQ_BAT');pause;
        END IF;	  

        DELETE_PARAMETER( v_par_id, 'P_SEQ_BAT');

     END IF;

    END LOOP;
     
   IF pa_var.v_debug THEN
   	  message('apres la boucle pour lancements groupés');pause;
   END IF;	  

   z_trace.end_procedure( p_package   => 'PA_BATCH', p_procedure => 'FU_RUN_PRODUCT_STD' );

   RETURN TRUE;

EXCEPTION
   WHEN FORM_TRIGGER_FAILURE THEN RETURN FALSE;
   WHEN OTHERS THEN RAISE;
   
END FU_RUN_PRODUCT_STD;   

PROCEDURE PR_LOAD_PAR_BATCH ( p_cod_que IN VARCHAR2 )
IS

  v_ok  BOOLEAN;
  v_prx VARCHAR2(2);
  v_tmp VARCHAR2(255);
  
   
BEGIN
   
   z_trace.begin_procedure( p_package   => 'PA_BATCH', p_procedure => 'PR_LOAD_PAR_BATCH' );
	
  OPEN  cur2 ( NAME_IN('bl_bat.seq_bat'));
  FETCH cur2 INTO w_nbr;
  CLOSE cur2;
  
  IF  NAME_IN( 'parameter.cod_grp_yon' ) IS NULL
  AND w_nbr > 0 THEN
      /*
      ** Lancement groupé interdit...
      */
      w_nbr := 1;
  END IF;

  OPEN  c_que ( p_cod_que, NAME_IN('BL_BAT.COD_QUE'));
  FETCH c_que INTO r_que;
  CLOSE c_que;

  IF  w_nbr > 0 THEN 
      /*
      ** Ne faire qqechose que si il y a des records dans BA_BATCH_PAR...
      */       
      COPY( r_cur1.nom_fic,     'BL_BAT.NOM_FIC' );
      COPY( r_cur1.nom_prg,     'BL_BAT.NOM_PRG' );
      COPY( w_fichier,          'BL_BAT.DIR_PRG' );
  --    COPY( r_cur1.tit_prg,     'BL_BAT.TIT_PRG' ); 
      IF NAME_IN('BL_BAT.TIT_PRG') IS NULL
      THEN
        COPY( r_cur1.tit_prg,     'BL_BAT.TIT_PRG' );         
      END IF;
      
      
      COPY( r_cur1.cod_typ_prg, 'BL_BAT.COD_TYP_PRG' );
      COPY( r_cur1.user,        'BL_BAT.IDN_UTI' );
      COPY( w_con    ,          'BL_BAT.NOM_BDD' );
      COPY( NAME_IN('GLOBAL.G_INI_OFISA_GEFI_PATHNAME'),'BL_BAT.DIR_INI' );
       
      PA_LOG.PR_LOG_MSG( '010'
                       , substr(w_fichier ,-least(NVL(length(w_fichier), 0),30))
                       , NULL 
                       , TO_NUMBER( NAME_IN('bl_bat.seq_bat')) );
          
      /*
      ** Code différent en 4.5 et en 6 car Wiztom que en Reports 6
      **
      ** FORMS 6:
      **
      **IF    record1.cod_ver NOT IN ('RM','RMB')            -- Forms 4.5
      */
      IF    r_cur1.cod_ver NOT IN ('RM','RMB','RW','RWB') -- Forms 6
      THEN
            COPY ('T', 'bl_bat.cod_lan_trt');
            set_item_property('bl_bat.cod_lan_trt', ITEM_IS_VALID, PROPERTY_TRUE);
      ELSIF NAME_IN('bl_bat.cod_lan_trt') = 'S' THEN
            COPY (NAME_IN('parameter.cod_lan_soc'), 'bl_bat.cod_lan_trt');
            set_item_property('bl_bat.cod_lan_trt', ITEM_IS_VALID, PROPERTY_TRUE);
      ELSIF NAME_IN('bl_bat.cod_lan_trt') = 'U' THEN
            COPY (NAME_IN('parameter.cod_lan_uti'), 'bl_bat.cod_lan_trt');
            set_item_property('bl_bat.cod_lan_trt', ITEM_IS_VALID, PROPERTY_TRUE);
      END IF;


      -- Sauvegarde des options utilisées

      -- VUL 26.05.2007 Différencier entre Web et C/S --> utiliser v_user_int
      --                et utiliser pa_ba_favoris au lieu d'avoir les insert/update ici
               
      -- Code traitement (Ecran, Fichier, Imprimante)

      PA_BA_FAVORIS.PR_SAVE_TYPE( user, pa_var.v_user_int, name_in('bl_bat.cod_trt') ); 

      -- Queue batch

      IF upper(name_in('bl_bat.cod_trt')) <> 'PREVIEW' THEN
         PA_BA_FAVORIS.PR_SAVE_QUEUE( user, pa_var.v_user_int, name_in('bl_bat.cod_que') ); 
      END IF;
     

      -- Imprimante

      V_TMP := name_in('bl_bat.nom_fic_imp');     

      IF upper(name_in('bl_bat.cod_trt')) in ('PREVIEW','PRINTER') AND v_tmp is not null THEN
         PA_BA_FAVORIS.PR_SAVE_PRINTER( user, pa_var.v_user_int, v_tmp ); 
      END IF;
      
      -- Répertoire pour fichier

      IF upper(name_in('bl_bat.cod_trt')) = 'FILE' AND nvl(instr(v_tmp,NAME_IN('GLOBAL.G_INI_OFISA_GEFI_SYSTEM_DIRECTORY_SEPARATOR'),-1),0) <> 0 THEN
         v_tmp := fu_directory;
         PA_BA_FAVORIS.PR_SAVE_DIRECTORY( user, pa_var.v_user_int, v_tmp ); 
      END IF;

      
      /*
      **  NE PAS FAIRE DE POST SINON RUNPRODUCT NE VERRA PAS LES PARAMETRES
      */

      COMMIT_FORM;
      PR_CHK_BUILTIN;
      CLEAR_MESSAGE;   
          
      r_bat.seq_bat              :=name_in('bl_bat.seq_bat');      
      r_bat.cod_sta_bat          :=name_in('bl_bat.cod_sta_bat');  
     -- r_bat.num_job              :=name_in('bl_bat.num_job'); -n'existe pas dans le block
      r_bat.nom_fic              :=name_in('bl_bat.nom_fic');      
      r_bat.nom_prg              :=name_in('bl_bat.nom_prg');      
      r_bat.dir_prg              :=name_in('bl_bat.dir_prg');      
      r_bat.tit_prg              :=name_in('bl_bat.tit_prg');      
  --    r_bat.dat_lan              :=name_in('bl_bat.dat_lan');     	message('76');
      r_bat.idn_uti              :=name_in('bl_bat.idn_uti');      
      r_bat.pwd_uti              :=name_in('bl_bat.pwd_uti');      
      r_bat.nom_bdd              :=name_in('bl_bat.nom_bdd');      
      r_bat.cod_typ_prg          :=name_in('bl_bat.cod_typ_prg');  
      r_bat.num_soc              :=name_in('bl_bat.num_soc');      
      --r_bat.cod_pri              :=name_in('bl_bat.cod_pri'); -n'existe pas dans le block    
      r_bat.cod_que              :=name_in('bl_bat.cod_que');     	
      --r_bat.cod_imp              :=name_in('bl_bat.cod_imp'); -n'existe pas dans le block    
      r_bat.cod_fmt              :=name_in('bl_bat.cod_fmt');     	
      r_bat.cod_trt              :=name_in('bl_bat.cod_trt');     	
      r_bat.cod_bat              :=name_in('bl_bat.cod_bat');     	
      r_bat.cod_ort              :=name_in('bl_bat.cod_ort');     	
      r_bat.nbr_cop              :=name_in('bl_bat.nbr_cop');     	
      --r_bat.cod_err              :=name_in('bl_bat.cod_err');     
      r_bat.cod_par_yon          :=name_in('bl_bat.cod_par_yon'); 	
      r_bat.cod_fic_yon          :=name_in('bl_bat.cod_fic_yon'); 	
      r_bat.cod_hea_yon          :=name_in('bl_bat.cod_hea_yon'); 	
      r_bat.cod_trl_yon          :=name_in('bl_bat.cod_trl_yon'); 	

 --     r_bat.dat_trt              :=to_date(name_in('bl_bat.dat_trt'),'dd.mm.yyyy');     	message('93');
 --     r_bat.dat_trt_com          :=to_date(name_in('bl_bat.dat_trt_com'),'dd.mm.yyyy'); 	message('94');
 --     r_bat.dat_trt_fin          :=to_date(name_in('bl_bat.dat_trt_fin'),'dd.mm.yyyy'); 	message('95');

      r_bat.nom_fic_imp          :=name_in('bl_bat.nom_fic_imp'); 	
      r_bat.cod_mod              :=name_in('bl_bat.cod_mod');     
      r_bat.dir_ini              :=name_in('bl_bat.dir_ini');     
      r_bat.dir_fmt              :=name_in('bl_bat.dir_fmt'); 		    
      r_bat.nom_fic_arc          :=lower(name_in('bl_bat.nom_fic_arc'));
      r_bat.cop_arc_yon          :=name_in('bl_bat.cop_arc_yon');

      v_prx := 'a_';
            
      IF r_bat.cop_arc_yon IS NULL 
      THEN
        v_prx := 'w_';
      END IF;
      
      IF r_bat.nom_fic_arc IS NULL
      THEN
         r_bat.nom_fic_arc := v_prx||lower(w_load)||'_'||to_char(sysdate,'yyyymmdd_hh24miss')||'_'||to_char(r_bat.seq_bat);
      ELSE
      	 r_bat.nom_fic_arc := v_prx||lower(w_load)||'_'||r_bat.nom_fic_arc||'_'||to_char(sysdate,'yyyymmdd_hh24miss')||'_'||to_char(r_bat.seq_bat);
      END IF;
      
  ELSE
  	  w_nbr := 0;
      Clear_Form(No_Validate); 
  END IF;

   z_trace.end_procedure( p_package   => 'PA_BATCH', p_procedure => 'PR_LOAD_PAR_BATCH' );

END PR_LOAD_PAR_BATCH;

PROCEDURE pr_run_product
( p_new BOOLEAN )
IS
  v_ok BOOLEAN;
BEGIN
   
   z_trace.begin_procedure( p_package   => 'PA_BATCH', p_procedure => 'PR_RUN_PRODUCT' );

  w_usr   := Get_Application_Property(USERNAME);
  w_pwd   := Get_Application_Property(PASSWORD);
--w_con   := Get_Application_Property(CONNECT_STRING);    
  w_log   := w_usr||'/'||w_pwd;
  w_queue := NULL;
  
  IF w_con IS NOT NULL
  THEN
    w_log:=w_log||'@'||w_con;
  END IF;     
  w_load:=FU_WHICH_NAME;	
  w_nbr := 1;
  
  OPEN cur1 ( w_load
             , TO_NUMBER( NAME_IN( 'parameter.ref_cli' ))
             );
  FETCH cur1 INTO r_cur1;
  v_ok:=cur1%FOUND;
  CLOSE cur1;
      
  IF  v_ok THEN
      	
      pa_var.v_cod_log := r_cur1.cod_log;
      pa_var.v_log_act := r_cur1.log_act;
      
      IF pa_var.v_user_int = 'WEB' 
      THEN
        w_fichier := PA_INTERNAL.FU_FILE_NAME( r_cur1.tst_prd 
                                           , r_cur1.dir_prg 
                                           , NVL( v_nom_prg, r_cur1.nom_fic ) );      
      ELSE
        /* 
        ** queuing mode client-server
        */
        IF  NAME_IN('BL_BAT.COD_QUE') <> '@' THEN
            /*
            ** Code queue <> Aucun, on execute le report sur un autre PC
            */
            OPEN  c_que ( 'COD_QUE_BAT', NAME_IN('BL_BAT.COD_QUE'));
            FETCH c_que INTO r_que; --v_queue, v_dir_prod, v_dir_test; 
            IF  c_que%NOTFOUND THEN
                w_queue := NULL;
            --    
            -- VUL - 16.07.04 - Début
            --    
            ELSE
            	  w_queue := r_que.lib_1er;
            --    
            -- VUL - 16.07.04 - Fin
            --    
            END IF;
            CLOSE c_que;
        ELSE
            w_queue := NULL;
        END IF;
        IF  w_queue IS NULL THEN
            w_fichier := PA_INTERNAL.FU_FILE_NAME( r_cur1.tst_prd , r_cur1.dir_prg ,  NVL( v_nom_prg, r_cur1.nom_fic ) );
        ELSE
            IF  r_cur1.tst_prd = 'PROD' THEN
                w_fichier := r_que.lib_2em||PA_INTERNAL.FU_FILE_NAME( 'BATCH' , r_cur1.dir_prg ,  NVL( v_nom_prg, r_cur1.nom_fic ) );
            ELSE
                w_fichier := r_que.lib_3em||NAME_IN('GLOBAL.G_INI_OFISA_GEFI_SYSTEM_DIRECTORY_SEPARATOR')||NVL( v_nom_prg, r_cur1.nom_fic );
            END IF;
        END IF;
      END IF;

      w_fichier := lower(w_fichier || SUBSTR( NAME_IN('bl_bat.cod_ort'), 1, 1)); -- lower POUR SOLARIS 
      
      IF NOT ID_NULL(FIND_BLOCK('BL_BAT'))
      THEN
         IF pa_var.v_user_int = 'WEB' THEN
            PR_LOAD_PAR_BATCH('COD_QUE');
         ELSE   
            PR_LOAD_PAR_BATCH('COD_QUE_BAT');
         END IF;
         
      /* programme de lancement batch standard */
      ELSE
      /* lancement directe */
        null;
      END IF;
  
      IF r_cur1.cod_typ_prg = 'CR' THEN 
      	
      	 -- Crystal Reports C/S
      	PR_RUN_CRYSTAL;
      	      
      ELSIF r_cur1.cod_typ_prg = 'CRW' THEN 
      	
      	 -- Crystal Reports Web
      	PR_RUN_CRYSTAL;

      ELSE
      	
         IF pa_var.v_user_int = 'WEB' 
         THEN
           -- message('web');
           v_ok := NVL( FU_RUN_PRODUCT_WEB, FALSE );
         ELSE
           v_ok := NVL( FU_RUN_PRODUCT_STD, FALSE );
         END IF;
         
         IF NOT v_ok THEN
         	  RAISE FORM_TRIGGER_FAILURE;
         END IF;

      END IF;
      
      PR_NEW_NAME_OF_PRG;
  
   
  ELSE
      Clear_Form(No_Validate); 
  END IF;     

  IF p_new THEN
   	PA_CALL.PR_FORM( 'N', UPPER(NAME_IN('PARAMETER.nom_prg')), p_ext_aft_cmt => FALSE );
  ELSE
  	EXECUTE_TRIGGER('OFI_EXIT_PRG');
   END IF;

   z_trace.end_procedure( p_package   => 'PA_BATCH', p_procedure => 'PR_RUN_PRODUCT' );

END pr_run_product;

PROCEDURE PR_SET_LSC_POR (p_blk_bat_nam IN VARCHAR2 := 'bl_bat')
IS

  CURSOR c_lsc ( p_nom_prg VARCHAR2) IS
         SELECT p.cod_ort
               ,DECODE(u.exp_xls_yon
                          ,null,'preview'
                          ,decode(p.cod_trt
                                    ,'@','preview'
                                    ,     p.cod_trt)) cod_trt
               ,DECODE(p.cod_mod,'@','DEFAULT',p.cod_mod) cod_mod
               ,p.cod_fmt
               ,p.nom_fic_imp
               ,p.cod_que
               ,p.cop_arc_yon
               ,fa.zon_chr     adr_ptr
               ,p.cod_tmt_ett
               ,p.cod_hea_trl
              , REPLACE(
                NVL(DECODE(u.cod_lan,'1',p.tit_prg_001,
                                     '2',p.tit_prg_002,
                                     '3',p.tit_prg_003,
                                     '4',p.tit_prg_004,
                                     '5',p.tit_prg_005)
                                        ,nvl(p.tit_prg_001,p.tit_prg)),'&',NULL) tit_prg
               ,u.cod_que cod_que_uti  
               ,p.cod_que cod_que_prg           
               ,fd.zon_chr dir
         FROM   ba_favoris_uti ft
               ,ba_favoris_uti fa
               ,ba_favoris_uti fd
               ,ba_utilisateur u
               ,ba_programme   p
         WHERE p.nom_prg         = p_nom_prg
         AND   u.idn_uti         = user
         AND   ft.idn_uti(+)     = u.idn_uti
         AND   ft.cod_typ_par(+) = 'T'
         AND   ft.nom_prg    (+) = NVL(pa_var.v_user_int,'%')
         AND   ft.seq        (+) = 1
         AND   fa.idn_uti(+)     = u.idn_uti       
         AND   fa.cod_typ_par(+) = 'P'
         AND   fa.nom_prg    (+) = NVL(pa_var.v_user_int,'%')
         AND   fa.seq        (+) = 1
         AND   fd.idn_uti(+)     = u.idn_uti       
         AND   fd.cod_typ_par(+) = 'D'
         AND   fd.nom_prg    (+) = NVL(pa_var.v_user_int,'%')
         AND   fd.seq        (+) = 1;

   record1 c_lsc%ROWTYPE;
   v_def_val VARCHAR2(10);
   
   /* print server utilisateur */
/*   
   CURSOR c_svr (p_cod_lan IN VARCHAR2)IS
    select nvl(f.zon_chr,c.dgn_cod) cod_que
    from  ba_favoris_uti f
        , ba_utilisateur u
        , ba_code        c
   where c.nom_cod        = 'COD_QUE'
     and c.cod_lan        = p_cod_lan
     and u.idn_uti        = user
     and f.idn_uti(+)     = u.idn_uti
     and f.cod_typ_par(+) = 'Q'
     and f.nom_prg    (+) = '%'
     and f.seq        (+) = 1
--    si je le trouve dans ba_favoris je le prends sinon je prends un par défaut sinon je prends @
   ORDER BY decode(c.dgn_cod, f.zon_chr,0,'@',2,1);   
*/

   CURSOR c_svr IS
    select f.zon_chr cod_que
    from  ba_favoris_uti f
        , ba_utilisateur u
   where u.idn_uti        = user
     and f.idn_uti        = u.idn_uti
     and f.cod_typ_par    = 'Q'
     and f.nom_prg        = NVL(pa_var.v_user_int,'%')
     and f.seq            = 1;
   r_svr c_svr%rowtype;
    
   CURSOR c_ptr IS
    select adr_ptr
    from  ba_printer     i
        , ba_pflptr_lig  l
        , ba_pflptr      p
        , ba_utilisateur u
   where u.idn_uti     = user
   and   p.num_pfl_ptr = u.num_pfl_ptr
   and   l.num_pfl_ptr = p.num_pfl_ptr
   and   i.seq_ptr     = l.seq_ptr;
   
   r_ptr c_ptr%rowtype;
    
BEGIN
   
   z_trace.begin_procedure( p_package   => 'PA_BATCH', p_procedure => 'PR_SET_LSC_POR' );

   IF NOT ID_NULL( FIND_ITEM( 'BL_VAL.COD_ORT' ) ) THEN
      v_def_val := NAME_IN ('BL_VAL.COD_ORT' );
   ELSE
      v_def_val := NULL;
   END IF;

   IF NVL( v_def_val, '!') NOT IN ('LANDSCAPE', 'PORTRAIT') THEN
      v_def_val := 'PORTRAIT';
   END IF;

  OPEN c_lsc(FU_WHICH_NAME);

  FETCH c_lsc INTO record1;

  IF c_lsc%FOUND
  THEN
    
    IF  pa_var.v_num_ett THEN
        pa_site_regie.pr_cod_tmt_ett (NVL(record1.cod_tmt_ett,'@'));
    END IF;  
    w_adr_ptr    := record1.adr_ptr;
    w_directory  := record1.dir;

    IF w_adr_ptr IS NULL
    THEN
      OPEN c_ptr;
      FETCH c_ptr INTO r_ptr;
      IF c_ptr%FOUND
      THEN
        w_adr_ptr := r_ptr.adr_ptr;
      END IF;
      CLOSE c_ptr;
    END IF;
    
    COPY(record1.cop_arc_yon  ,p_blk_bat_nam||'.COP_ARC_YON');
    
    COPY(record1.tit_prg      ,p_blk_bat_nam||'.TIT_PRG');    
    
    IF  record1.cod_ort = 'BOTH'
    THEN
      COPY( v_def_val, p_blk_bat_nam||'.COD_ORT');
      IF  NVL(INSTR(pa_var.v_chp_pro,p_blk_bat_nam||'.COD_ORT'),0) = 0 THEN
          PA_SET_ITEM.PR_PROPERTY(p_blk_bat_nam||'.COD_ORT', ENABLED, PROPERTY_TRUE);
      END IF;
    ELSIF  record1.cod_ort = 'PORTRAIT'
    THEN
      COPY('PORTRAIT', p_blk_bat_nam||'.COD_ORT');
      PA_SET_ITEM.PR_PROPERTY(p_blk_bat_nam||'.COD_ORT', ENABLED, PROPERTY_FALSE);
    ELSIF record1.cod_ort = 'LANDSCAPE'
    THEN
      COPY('LANDSCAPE', p_blk_bat_nam||'.COD_ORT');
      PA_SET_ITEM.PR_PROPERTY(p_blk_bat_nam||'.COD_ORT', ENABLED, PROPERTY_FALSE);
    ELSIF  record1.cod_ort = '@'
    THEN
      /*
      ** en théorie pas possible mais en pratique si
      ** compatibilité avec l'ancienne version
      ** car la valeur par défaut se trouve dans BL_VAL.COD_ORT
      ** et peut être initialisée dans GLOBALE
      */
      COPY(v_def_val, p_blk_bat_nam||'.COD_ORT');
      PA_SET_ITEM.PR_PROPERTY(p_blk_bat_nam||'.COD_ORT', ENABLED, PROPERTY_TRUE);
    ELSE
      COPY(v_def_val, p_blk_bat_nam||'.COD_ORT');
      PA_SET_ITEM.PR_PROPERTY(p_blk_bat_nam||'.COD_ORT', ENABLED, PROPERTY_TRUE);
    END IF;
    
    IF    record1.cod_hea_trl = 'H' THEN
            COPY('X', p_blk_bat_nam||'.COD_HEA_YON');
    ELSIF record1.cod_hea_trl = 'T' THEN
            COPY('X', p_blk_bat_nam||'.COD_TRL_YON');
    ELSIF record1.cod_hea_trl = 'B' THEN
            COPY('X', p_blk_bat_nam||'.COD_HEA_YON');
            COPY('X', p_blk_bat_nam||'.COD_TRL_YON');
    END IF;


    IF  record1.cop_arc_yon IS NOT NULL THEN
        COPY('X', p_blk_bat_nam||'.COD_FIC_YON');
    END IF;    
    
  --  message('cod_trt '||record1.cod_trt||'/'||NAME_IN(p_blk_bat_nam||'.cod_trt'));
  --  IF  record1.cod_trt <> NAME_IN(p_blk_bat_nam||'.cod_trt') THEN
  --      COPY(record1.cod_trt, p_blk_bat_nam||'.COD_TRT' );
  --  END IF;

    IF    GET_MENU_ITEM_PROPERTY('MN_FAV.FAV_OPT_6', CHECKED) = 'TRUE' THEN
          v_def_val := 'printer';
    ELSE
          v_def_val := record1.cod_trt;
    END IF;
    IF  NAME_IN(p_blk_bat_nam||'.cod_trt') <> v_def_val THEN
        COPY(v_def_val, p_blk_bat_nam||'.COD_TRT' );
    END IF;

    IF  record1.cod_mod <> NAME_IN(p_blk_bat_nam||'.cod_mod') THEN
        COPY(record1.cod_mod, p_blk_bat_nam||'.COD_MOD' );
    END IF;
  
    IF  record1.cod_fmt <> NAME_IN(p_blk_bat_nam||'.cod_fmt') THEN
        COPY(record1.cod_fmt, p_blk_bat_nam||'.COD_FMT' );
    END IF;
  
    IF  record1.nom_fic_imp IS NOT NULL THEN
        COPY(record1.nom_fic_imp, p_blk_bat_nam||'.NOM_FIC_IMP' );
        COPY('F-'||NAME_IN(p_blk_bat_nam||'.COD_QUE'), p_blk_bat_nam||'.TYP_FIC_IMP');
    END IF;
  
    IF pa_var.v_user_int = 'WEB'
    THEN /* si on est en web on a besoin d'un server report */

       OPEN  c_svr;
       FETCH c_svr INTO r_svr;
       IF c_svr%FOUND
       THEN       
         record1.cod_que:=r_svr.cod_que;
       ELSIF record1.cod_que_uti <> '@'
       THEN
         record1.cod_que:= record1.cod_que_uti; 
       ELSIF record1.cod_que_prg <> '@'
       THEN
         record1.cod_que:= record1.cod_que_prg; 
       END IF;
       
       IF record1.cod_que IS NULL
       THEN
         recorD1.cod_que:='@';
       END IF;
       COPY(record1.cod_que, p_blk_bat_nam||'.COD_QUE' );       
       CLOSE c_svr;
    ELSE

      IF    v_bat_yon IS NULL THEN
            w_cod_que := '@';
      ELSIF record1.cod_que <> '@' THEN
            w_cod_que := record1.cod_que;
      ELSIF record1.cod_que_uti <> '@' THEN
            w_cod_que := record1.cod_que_uti;
      END IF;

      /*
      ** VUL - 18.04.2007 Contrôler que la valeur de COD_QUE existe bien dans celles autorisées
      **                  Ca pose problème quand on passe de WEB à C/S ou inversément. On a stocké
      **                  la queue dans les favoris et on la propose mais dans ce cas elle n'existe 
      **                  pas forcément
      */
      
      IF      w_cod_que <> '@' 
          AND NAME_IN(p_blk_bat_nam||'.cod_trt') <> 'preview'
          AND pa_list_item.fu_value_in_list(  p_blk_bat_nam||'.COD_QUE', w_cod_que )  
      THEN
--          message('COPY (3) '||w_cod_que||' to '||p_blk_bat_nam||'.COD_QUE' );pause;
          COPY(w_cod_que, p_blk_bat_nam||'.COD_QUE' );
      END IF;
      
    END IF;
  
  END IF;  
  CLOSE c_lsc;

   z_trace.end_procedure( p_package   => 'PA_BATCH', p_procedure => 'PR_SET_LSC_POR' );

END PR_SET_LSC_POR;

PROCEDURE PR_VALID_FMT (p_blk_bat_nam IN VARCHAR2 := 'bl_bat'
                      , p_blk_prb_nam IN VARCHAR2 := 'bl_prb')

IS
  v_fld VARCHAR2(61) := UPPER(NAME_IN('system.trigger_item'));
BEGIN
   
   z_trace.begin_procedure( p_package   => 'PA_BATCH', p_procedure => 'PR_VALID_FMT' );

  IF    NAME_IN(p_blk_bat_nam||'.cod_trt') IN ('screen','preview') THEN
  	    Set_Item_Property(p_blk_bat_nam||'.nom_fic_imp',       PROMPT_TEXT, pa_var.v_imprimante);
        COPY( 'no',       p_blk_bat_nam||'.cod_bat' );
        IF  NAME_IN(p_blk_bat_nam||'.typ_fic_imp') <> 'P-'||NAME_IN(p_blk_bat_nam||'.COD_QUE') THEN
            COPY( NULL,   p_blk_bat_nam||'.nom_fic_imp' );
            COPY( '@',    p_blk_bat_nam||'.typ_fic_imp' );
        END IF;
        IF  pa_var.v_user_int <> 'WEB' THEN
            COPY( '@',    p_blk_bat_nam||'.cod_que' );
        END IF;
        COPY( NULL,       p_blk_bat_nam||'.day_trt' );
        COPY( NULL,       p_blk_bat_nam||'.tim_trt' );
        PA_SET_ITEM.PR_PROPERTY(p_blk_bat_nam||'.cod_bat',         ENABLED,  PROPERTY_FALSE);
        IF  pa_var.v_user_int <> 'WEB'
        AND v_fld <> UPPER(p_blk_bat_nam||'.COD_QUE') THEN
            PA_SET_ITEM.PR_PROPERTY(p_blk_bat_nam||'.cod_que',     ENABLED,  PROPERTY_FALSE);
        END IF;
        IF  NAME_IN(p_blk_bat_nam||'.cod_mod') <> 'CHARACTER' THEN
            PA_SET_ITEM.PR_PROPERTY(p_blk_bat_nam||'.nom_fic_imp', ENABLED,  PROPERTY_TRUE);
            PA_SET_ITEM.PR_PROPERTY(p_blk_bat_nam||'.nom_fic_imp', REQUIRED, PROPERTY_FALSE);
            IF  pa_var.v_user_int NOT IN ( 'WEB', 'MSWINDOWS' ) THEN
                 SET_ITEM_PROPERTY(p_blk_bat_nam||'.nom_fic_imp',  ENABLED,  PROPERTY_FALSE);
            END IF;
            IF  v_fld <> UPPER(p_blk_bat_nam||'.FMT') THEN
                PA_SET_ITEM.PR_PROPERTY(p_blk_bat_nam||'.fmt',     ENABLED,  PROPERTY_FALSE);
            END IF;
            SET_ITEM_PROPERTY(p_blk_bat_nam||'.fmt',        LOV_VALIDATION,  PROPERTY_FALSE);
            COPY( pa_var.v_default, p_blk_bat_nam||'.fmt' );
            COPY( '@',              p_blk_bat_nam||'.cod_fmt' );
            COPY( NULL,             p_blk_bat_nam||'.dir_fmt' );
        ELSE 
            PA_SET_ITEM.PR_PROPERTY(p_blk_bat_nam||'.nom_fic_imp', ENABLED,  PROPERTY_FALSE);
            IF  v_fld <> UPPER(p_blk_bat_nam||'.FMT') THEN
                PA_SET_ITEM.PR_PROPERTY(p_blk_bat_nam||'.fmt',     ENABLED,  PROPERTY_TRUE);
            END IF;
            PA_SET_ITEM.PR_PROPERTY(p_blk_bat_nam||'.fmt',        REQUIRED,  PROPERTY_TRUE);
            SET_ITEM_PROPERTY(p_blk_bat_nam||'.fmt',        LOV_VALIDATION,  PROPERTY_TRUE);
        END IF;

  /* Impression dans un fichier */
  ELSIF NAME_IN(p_blk_bat_nam||'.cod_trt') = 'file' THEN
  	    Set_Item_Property(p_blk_bat_nam||'.nom_fic_imp',        PROMPT_TEXT, pa_var.v_fichier);
        COPY( 'yes',      p_blk_bat_nam||'.cod_bat' );
        IF  NAME_IN(p_blk_bat_nam||'.typ_fic_imp') <> 'F-'||NAME_IN('BL_BAT.COD_QUE') THEN
            COPY( NULL,   p_blk_bat_nam||'.nom_fic_imp' );
            COPY( '@',    p_blk_bat_nam||'.typ_fic_imp' );
        END IF;
        IF  pa_var.v_user_int = 'WEB' THEN
        	/* 
        	
        	 FER    si mode WEB alors impression dans fichier en direct 
        	
        	*/
            COPY( 'no',      p_blk_bat_nam||'.cod_bat' );
            PA_SET_ITEM.PR_PROPERTY(p_blk_bat_nam||'.cod_bat',     ENABLED,  PROPERTY_TRUE);
        END IF;
        IF  v_fld <> UPPER(p_blk_bat_nam||'.COD_QUE') THEN
            PA_SET_ITEM.PR_PROPERTY(p_blk_bat_nam||'.cod_que',     ENABLED,  PROPERTY_TRUE);
        END IF;
        /* NIC_20060214 : Utilisation d'une file batch ? */
        if NAME_IN(p_blk_bat_nam||'.cod_que') = '@' then
            /* NIC_20060214 : Impression dans un fichier sans passer par une file batch */
            PA_SET_ITEM.PR_PROPERTY(p_blk_bat_nam||'.nom_fic_imp', ENABLED,  PROPERTY_TRUE);
        else   /* NIC_20060214 : Impression au moyen du serveur batch, le chemin est fixé dans ba_pflptr */
            PA_SET_ITEM.PR_PROPERTY(p_blk_bat_nam||'.nom_fic_imp', ENABLED,  PROPERTY_FALSE);
        end if;
        PA_SET_ITEM.PR_PROPERTY(p_blk_bat_nam||'.nom_fic_imp',    REQUIRED,  PROPERTY_TRUE);
        IF  v_fld <> UPPER(p_blk_bat_nam||'.FMT') THEN
            PA_SET_ITEM.PR_PROPERTY(p_blk_bat_nam||'.fmt',         ENABLED,  PROPERTY_TRUE);
        END IF;
        PA_SET_ITEM.PR_PROPERTY(p_blk_bat_nam||'.fmt',            REQUIRED,  PROPERTY_TRUE);
        SET_ITEM_PROPERTY(p_blk_bat_nam||'.fmt',            LOV_VALIDATION,  PROPERTY_TRUE);
        IF  NAME_IN('bl_bat.cod_mod') <> 'CHARACTER'
        AND NAME_IN(p_blk_bat_nam||'.cod_fmt') = '@' THEN
            COPY( 'Acrobat reader', p_blk_bat_nam||'.fmt' );
            COPY( 'PDF',            p_blk_bat_nam||'.cod_fmt' );
            COPY( 'pdf',            p_blk_bat_nam||'.dir_fmt' );
        END IF ;
        PR_NOM_FIC_IMP;
        IF  NAME_IN(p_blk_bat_nam||'.cod_mod') <> 'CHARACTER'
        AND pa_var.v_user_int = 'MSWINDOWS' THEN
            IF  v_fld <> UPPER(p_blk_bat_nam||'.FMT') THEN
                PA_SET_ITEM.PR_PROPERTY(p_blk_bat_nam||'.fmt',     ENABLED,  PROPERTY_FALSE);
            END IF;
            SET_ITEM_PROPERTY(p_blk_bat_nam||'.fmt',        LOV_VALIDATION,  PROPERTY_FALSE);
            COPY( pa_var.v_default, p_blk_bat_nam||'.fmt' );
            COPY( '@',              p_blk_bat_nam||'.cod_fmt' );
            COPY( NULL,             p_blk_bat_nam||'.dir_fmt' );
        END IF;
  ELSE  
  	    -- Imprimante
  	    Set_Item_Property(p_blk_bat_nam||'.nom_fic_imp',       PROMPT_TEXT,  pa_var.v_imprimante);
        COPY( 'yes',      p_blk_bat_nam||'.cod_bat' );
        IF  NAME_IN(p_blk_bat_nam||'.typ_fic_imp') <> 'P-'||NAME_IN(p_blk_bat_nam||'.COD_QUE') THEN
            COPY( NULL,   p_blk_bat_nam||'.nom_fic_imp' );
            COPY( '@',    p_blk_bat_nam||'.typ_fic_imp' );
        END IF;
        COPY( w_adr_ptr,       p_blk_bat_nam||'.nom_fic_imp' );
        COPY('P-'||NAME_IN(p_blk_bat_nam||'.COD_QUE'), p_blk_bat_nam||'.typ_fic_imp' );
        IF  pa_var.v_user_int = 'WEB' THEN
            PA_SET_ITEM.PR_PROPERTY(p_blk_bat_nam||'.cod_bat',     ENABLED,  PROPERTY_TRUE);
        END IF;
        IF  v_fld <> UPPER(p_blk_bat_nam||'.COD_QUE') THEN
            PA_SET_ITEM.PR_PROPERTY(p_blk_bat_nam||'.cod_que',     ENABLED,  PROPERTY_TRUE);
        END IF;
        PA_SET_ITEM.PR_PROPERTY(p_blk_bat_nam||'.nom_fic_imp', ENABLED,  PROPERTY_TRUE);
        IF  NAME_IN(p_blk_bat_nam||'.cod_mod') = 'CHARACTER' THEN
            PA_SET_ITEM.PR_PROPERTY(p_blk_bat_nam||'.nom_fic_imp', REQUIRED, PROPERTY_TRUE);
            IF  v_fld <> UPPER(p_blk_bat_nam||'.FMT') THEN
                PA_SET_ITEM.PR_PROPERTY(p_blk_bat_nam||'.fmt',     ENABLED,  PROPERTY_TRUE);
            END IF;
            PA_SET_ITEM.PR_PROPERTY(p_blk_bat_nam||'.fmt',         REQUIRED, PROPERTY_TRUE);
            SET_ITEM_PROPERTY(p_blk_bat_nam||'.fmt',         LOV_VALIDATION, PROPERTY_TRUE);
        ELSE
            PA_SET_ITEM.PR_PROPERTY(p_blk_bat_nam||'.nom_fic_imp', REQUIRED, PROPERTY_FALSE);
            IF  pa_var.v_user_int NOT IN( 'MSWINDOWS', 'MSWINDOWS32') THEN
                SET_ITEM_PROPERTY(p_blk_bat_nam||'.nom_fic_imp',  ENABLED,  PROPERTY_FALSE);
            END IF;
            IF  v_fld <> UPPER(p_blk_bat_nam||'.FMT') THEN
                PA_SET_ITEM.PR_PROPERTY(p_blk_bat_nam||'.fmt',     ENABLED,  PROPERTY_FALSE);
            END IF;
            SET_ITEM_PROPERTY(p_blk_bat_nam||'.fmt',         LOV_VALIDATION, PROPERTY_FALSE);
            COPY( pa_var.v_default, p_blk_bat_nam||'.fmt' );
            COPY( '@',              p_blk_bat_nam||'.cod_fmt' );
            COPY( NULL,             p_blk_bat_nam||'.dir_fmt' );
            -- Rai 08.11.2007 pour ne pas écraser l'imprimante choisir lors de la validation de FMT...
            Set_Item_Property(p_blk_bat_nam||'.fmt',         ITEM_IS_VALID,  PROPERTY_TRUE);
        END IF;

  END IF;

  IF  NAME_IN(p_blk_bat_nam||'.cod_mod') = 'CHARACTER'
  AND NAME_IN(p_blk_bat_nam||'.dir_fmt') IS NOT NULL
  AND NAME_IN('GLOBAL.G_INI_OFISA_GEFI_PATHNAME') IS NOT NULL THEN
      COPY (RTRIM(UPPER(NAME_IN('GLOBAL.G_INI_OFISA_GEFI_PATHNAME')),'\')||
            REPLACE(NAME_IN(p_blk_bat_nam||'.dir_fmt'),
            RTRIM(UPPER(NAME_IN('GLOBAL.G_INI_OFISA_GEFI_PATHNAME')),'\'),NULL),p_blk_bat_nam||'.dir_fmt');
  END IF;

  IF  NAME_IN(p_blk_bat_nam||'.cod_que') = '@' THEN
      COPY(NULL, p_blk_bat_nam||'.day_trt');
      COPY(NULL, p_blk_bat_nam||'.tim_trt');
      PA_SET_ITEM.PR_PROPERTY(p_blk_bat_nam||'.day_trt',     ENABLED,  PROPERTY_FALSE);
      PA_SET_ITEM.PR_PROPERTY(p_blk_bat_nam||'.tim_trt',     ENABLED,  PROPERTY_FALSE);
      SET_ITEM_PROPERTY(p_blk_bat_nam||'.nom_fic_imp', LOV_VALIDATION, PROPERTY_FALSE);
      SET_ITEM_PROPERTY(p_blk_bat_nam||'.nom_fic_imp', LOV_NAME,       '');
  ELSE
      PA_SET_ITEM.PR_PROPERTY(p_blk_bat_nam||'.day_trt',     ENABLED,  PROPERTY_TRUE);
      PA_SET_ITEM.PR_PROPERTY(p_blk_bat_nam||'.tim_trt',     ENABLED,  PROPERTY_TRUE);
      IF  NAME_IN(p_blk_bat_nam||'.day_trt') IS NULL THEN
          COPY(TO_CHAR(pa_var.v_current_date,'dd-mon-yyyy'), p_blk_bat_nam||'.day_trt');
      END IF;
      IF  NAME_IN(p_blk_bat_nam||'.cod_trt') = 'printer' THEN
          SET_ITEM_PROPERTY(p_blk_bat_nam||'.nom_fic_imp', LOV_VALIDATION, PROPERTY_TRUE);
          SET_ITEM_PROPERTY(p_blk_bat_nam||'.nom_fic_imp', LOV_NAME,       'LV_NOM_PTR');
      ELSE
          SET_ITEM_PROPERTY(p_blk_bat_nam||'.nom_fic_imp', LOV_VALIDATION, PROPERTY_FALSE);
          SET_ITEM_PROPERTY(p_blk_bat_nam||'.nom_fic_imp', LOV_NAME,       '');
      END IF;
  END IF;

  IF  NAME_IN('system.cursor_item') = UPPER(p_blk_bat_nam||'.COD_MOD') THEN
      COPY(NAME_IN(p_blk_bat_nam||'.fmt'), p_blk_bat_nam||'.FMT');
      SET_ITEM_PROPERTY(p_blk_bat_nam||'.fmt', ITEM_IS_VALID, PROPERTY_FALSE);
  END IF;

  synchronize;

   z_trace.end_procedure( p_package   => 'PA_BATCH', p_procedure => 'PR_VALID_FMT' );

END PR_VALID_FMT;


PROCEDURE PR_NEW_BLK_INST 
IS
  It_Id ITEM;

  CURSOR c_fmt(p_fmt VARCHAR2)
  IS
  SELECT lib,lib_2em||lib_1er dir
    FROM ba_code_multi		--ba_code_multi, c'est voulu on veut les valeurs par défaut
   WHERE nom_cod = 'COD_FMT'
     AND dgn_cod = p_fmt;

  r_fmt      c_fmt%ROWTYPE;
  v_msg_lvl  VARCHAR2(3)      := NAME_IN('SYSTEM.MESSAGE_LEVEL');  
BEGIN
   
   z_trace.begin_procedure( p_package   => 'PA_BATCH', p_procedure => 'PR_NEW_BLK_INST' );

  PA_MISC.PR_CODES( p_item => 'BL_BAT.COD_TRT', p_nom_cod => 'COD_TRT_BAT', p_where => ' and (upper(dgn_cod) <> ''FILE'' or Pa_Acces.fu_export_autorise = 0)');
  PA_MISC.PR_CODES( 'BL_BAT.COD_TMT_ETT', 'COD_TMT_ETT' );
  PA_MISC.PR_CODES( 'BL_BAT.COD_MOD',     'COD_MOD_BAT' );

  DEFAULT_VALUE( NULL, 'global.g_bat_yon' );
  v_bat_yon := NAME_IN('global.g_bat_yon');

  IF v_bat_yon IS NOT NULL THEN
      IF  pa_var.v_user_int = 'WEB' THEN
--          message( 'chargement cod_que pour web avec COD_QUE');pause;

          PA_MISC.PR_CODES( 'BL_BAT.COD_QUE', 'COD_QUE' );	-- Pour report serveur en mode WEB
      ELSE

          /*
          ** Pour report serveur en mode CLIENT SERVEUR
          ** Forms4.5 : DGN_COD sur 1 position  P_WHERE => 'and length(dgn_cod) = 1'
          ** Forms  6 : DGN_COD sur 2 positions P_WHERE => 'and (length(dgn_cod) > 1 or dgn_cod = ''@'')'
          */
          -- VUL/NIC 20.10.2005 - Correction de la clause where: ajout de parenthèses.
--          message( 'chargement cod_que pour C/S avec COD_QUE_BAT');pause;
          PA_MISC.PR_CODES( 'BL_BAT.COD_QUE', 'COD_QUE_BAT', P_WHERE => 'and (length(dgn_cod) > 1 or dgn_cod = ''@'')');
      END IF;
  END IF;

  COPY('15'     , 'SYSTEM.MESSAGE_LEVEL');
  pa_query.pr_exeqry_next;
  COPY(v_msg_lvl, 'SYSTEM.MESSAGE_LEVEL');  --Retour à la valeur précédente

  IF  NVL(NAME_IN('bl_bat.cod_sta_bat'),'!') <> '20' THEN
      COPY('20', 'bl_bat.cod_sta_bat');
  END IF;
/*
** Code différent en 4.5 et en 6 car Wiztom que en Reports 6
**
** FORMS 6:
**
**IF  NVL(NAME_IN('parameter.cod_ver'), '!') NOT IN ('RM','RMB')              -- Forms 4.5
*/
  IF  NVL(NAME_IN('parameter.cod_ver'), '!') NOT IN ('RM','RMB', 'RW', 'RWB') -- Forms 6
  THEN
      SET_ITEM_PROPERTY('bl_bat.cod_lan_trt', DISPLAYED, PROPERTY_FALSE);
--      SET_ITEM_PROPERTY('bl_prb.cod_lan_trt', DISPLAYED, PROPERTY_FALSE);
      COPY('T', 'bl_bat.cod_lan_trt');
  ELSE      
      PA_MISC.PR_CODES( P_ITEM => 'BL_BAT.COD_LAN_TRT'
                       ,P_WHERE => 'and dgn_cod <>  ''@'''
                       ,P_ORDER => 'NVL(LIB_1ER,DGN_COD)' );
      DEFAULT_VALUE( NAME_IN('bl_ref.cod_lan_trt'), 'global.cod_lan_trt' );
      COPY(NAME_IN('global.cod_lan_trt'), 'bl_bat.cod_lan_trt');
      ERASE ('global.cod_lan_trt');
  END IF;

  IF  pa_var.v_user_int = 'MSWINDOWS'   THEN
      SET_ITEM_PROPERTY('bl_bat.bt_nom_fic_imp', DISPLAYED, PROPERTY_FALSE);
  END IF;

  COPY(pa_var.v_user_int, 'bl_bat.user_int');
  IF  pa_var.v_user_int <> 'WEB' THEN
      SET_ITEM_PROPERTY('bl_bat.cod_bat', DISPLAYED, PROPERTY_FALSE);
--      SET_ITEM_PROPERTY('bl_prb.cod_bat', DISPLAYED, PROPERTY_FALSE);
  END IF;

  IF  NOT pa_var.v_num_ett THEN
    SET_ITEM_PROPERTY('bl_bat.cod_tmt_ett', DISPLAYED, PROPERTY_FALSE);
--    SET_ITEM_PROPERTY('bl_prb.cod_tmt_ett', DISPLAYED, PROPERTY_FALSE);
  END IF;

  PR_SET_LSC_POR;
  PR_VALID_FMT;

  IF  NAME_IN('parameter.cod_par_yon') IS NOT NULL THEN
      COPY('X', 'bl_bat.cod_par_yon');
  END IF;

  OPEN c_fmt (NAME_IN('bl_bat.cod_fmt'));
  FETCH c_fmt INTO r_fmt;
  IF  c_fmt%NOTFOUND THEN
      r_fmt.lib     := pa_var.v_default;
      r_fmt.dir     := NULL;
      COPY( '@', 'bl_bat.cod_fmt');
  END IF;
  CLOSE c_fmt;
  COPY (r_fmt.lib, 'bl_bat.fmt');
  COPY (r_fmt.dir, 'bl_bat.dir_fmt');
  pa_item.pr_next;
  validate(record_scope);

   z_trace.end_procedure( p_package   => 'PA_BATCH', p_procedure => 'PR_NEW_BLK_INST' );

END pr_new_blk_inst;


PROCEDURE PR_NOM_FIC_IMP
/*
**  Proposition / Validation du nom du répertoire
*/

IS

  cursor c_dir_des (p_num_pfl_ptr number)   /* NIC_20060214 : Lecture du chemin destination */
  is
  select dir_des
    from ba_pflptr
   where num_pfl_ptr = (-1) * p_num_pfl_ptr;

  v_tmp_dir VARCHAR2(512);
  v_nom_fic VARCHAR2(512);
  v_nom_ext VARCHAR2(512);
  v_seq     VARCHAR2(8)   := LPAD(NAME_IN('bl_bat.seq_bat'),7,'_000000');

BEGIN
   
   z_trace.begin_procedure( p_package   => 'PA_BATCH', p_procedure => 'PR_NOM_FIC_IMP' );

   IF  pa_var.v_debug THEN
       message('pr_nom_fic_imp(1) '||NAME_IN('bl_bat.nom_fic_imp')||'/'||NAME_IN('BL_BAT.COD_QUE')||' '||v_tmp_dir);
   END IF;

   /* NIC_20060214 : Faut-il imprimer dans un fichier au moyen d'une file batch ? */
   if NAME_IN('bl_bat.cod_trt') <> 'file' or NAME_IN('bl_bat.cod_que') = '@' then
 	
      IF  NAME_IN('bl_bat.nom_fic_imp') IS NULL
      OR  NAME_IN('bl_bat.typ_fic_imp') <> 'F-'||NAME_IN('BL_BAT.COD_QUE')
         --   OR  NAME_IN('bl_bat.nom_fic_imp') = LOWER(NAME_IN('bl_bat.nom_fic_imp'))
      THEN

         /*
         ** Le nom du fichier n'est pas renseigné. Si un nom a déjà saisi une fois, on le réutilise
         ** (ex : on avait choisi fichier, puis écran et on revient à fichier)
         **
         ** Sinon, on propose à partir du dernier nom de répertoire utilisé (w_directory) qui provient
         ** des favoris, ou à défaut on utilise le répertoire temporaire de Windows
         */
         IF w_nom_fic_imp  is not null then
       	    copy (w_nom_fic_imp,'bl_bat.nom_fic_imp');

            IF  pa_var.v_debug THEN
                message('pr_nom_fic_imp(2) '||w_nom_fic_imp||'/'||NAME_IN('bl_bat.nom_fic_imp'));
            END IF;
         ELSE

            v_tmp_dir := nvl(w_directory
                        ,client_win_api_environment.get_temp_directory
                        ||NAME_IN('GLOBAL.G_INI_OFISA_GEFI_SYSTEM_DIRECTORY_SEPARATOR'));

            IF   NAME_IN( 'bl_bat.cod_fmt' ) = 'PDF' THEN
               COPY(LOWER(v_tmp_dir||NAME_IN('parameter.nom_prg')||v_seq||'.pdf'), 'bl_bat.nom_fic_imp');
            ELSIF NAME_IN( 'bl_bat.cod_fmt' ) IN ('HTML','HTMLCSS') THEN
               COPY(LOWER(v_tmp_dir||NAME_IN('parameter.nom_prg')||v_seq||'.htm'), 'bl_bat.nom_fic_imp');
            ELSIF NAME_IN( 'bl_bat.cod_fmt' ) = 'CSV' THEN
               COPY(LOWER(v_tmp_dir||NAME_IN('parameter.nom_prg')||v_seq||'.csv'), 'bl_bat.nom_fic_imp');
            ELSIF NAME_IN( 'bl_bat.cod_fmt' ) = 'XML' THEN
               COPY(LOWER(v_tmp_dir||NAME_IN('parameter.nom_prg')||v_seq||'.xml'), 'bl_bat.nom_fic_imp');
            ELSE
               COPY(LOWER(v_tmp_dir||NAME_IN('parameter.nom_prg')||v_seq||'.lis'), 'bl_bat.nom_fic_imp');
            END IF;

            IF  pa_var.v_debug THEN
                message('pr_nom_fic_imp(3) '||v_tmp_dir||'/'||NAME_IN('bl_bat.nom_fic_imp'));
            END IF;

         END IF;

         COPY('F-'||NAME_IN('BL_BAT.COD_QUE'), 'BL_BAT.TYP_FIC_IMP');

      ELSE

         /*
         ** Nom de fichier déjà renseigné. On ajuste l'extension si nécessaire
         */

         -- v_nom_fic := pa_utility.fu_piece(NAME_IN('bl_bat.nom_fic_imp'),'.',1);
         -- VUL 02.07.2014 remplacer fu_piece par des substr et instr parce que ça ne marchait pas quand le nom du répertoire
         --                contenait un point. Le nom du fichier était coupé après le premier point au lieu du dernier
         --                ex : C:\users\ches.BUSSIGNY\toto.pdf donnait C:\users\ches alors qu'on veut C:\users\ches.BUSSIGNY\toto
         IF  pa_var.v_debug THEN
             message('pr_nom_fic_imp(4) '||NAME_IN('bl_bat.nom_fic_imp'));
         END IF;
         --
         If  INSTR(NAME_IN('bl_bat.nom_fic_imp'),'.',-1) <> 0 Then
             v_nom_fic := SUBSTR( NAME_IN('bl_bat.nom_fic_imp'), 1, INSTR(NAME_IN('bl_bat.nom_fic_imp'),'.',-1)-1);
             v_nom_ext := LOWER(pa_utility.fu_piece(NAME_IN('bl_bat.nom_fic_imp'),'.',2));
         Else
         	   v_nom_fic := NAME_IN('bl_bat.nom_fic_imp');
         	   v_nom_ext := NULL;
         End If;
         --
         IF  pa_var.v_debug THEN
            message('pr_nom_fic_imp(5) '||v_nom_fic||'/'||v_nom_ext);
         END IF;
         IF  v_nom_ext IS NULL
         OR (v_nom_ext <> 'pdf'         AND NAME_IN( 'bl_bat.cod_fmt' ) = 'PDF')
         OR (v_nom_ext <> 'htm'         AND NAME_IN( 'bl_bat.cod_fmt' ) IN ('HTML','HTMLCSS'))
         OR (v_nom_ext <> 'csv'         AND NAME_IN( 'bl_bat.cod_fmt' ) = 'CSV')
         OR (v_nom_ext <> 'xml'         AND NAME_IN( 'bl_bat.cod_fmt' ) = 'XML')
         OR (v_nom_ext IN ('pdf','htm','csv','xml')
         AND NAME_IN( 'bl_bat.cod_fmt' ) NOT IN ('PDF', 'HTML', 'HTMLCSS', 'CSV', 'XML')) THEN
            IF    NAME_IN( 'bl_bat.cod_fmt' ) = 'PDF' THEN
               COPY(v_nom_fic||'.pdf', 'bl_bat.nom_fic_imp');
            ELSIF NAME_IN( 'bl_bat.cod_fmt' ) IN ('HTML','HTMLCSS') THEN
               COPY(v_nom_fic||'.htm', 'bl_bat.nom_fic_imp');
            ELSIF NAME_IN( 'bl_bat.cod_fmt' ) = 'CSV' THEN
               COPY(v_nom_fic||'.csv', 'bl_bat.nom_fic_imp');
            ELSIF NAME_IN( 'bl_bat.cod_fmt' ) = 'XML' THEN
               COPY(v_nom_fic||'.xml', 'bl_bat.nom_fic_imp');
            ELSE
               COPY(v_nom_fic||'.lis', 'bl_bat.nom_fic_imp');
            END IF;
         END IF;
            IF  pa_var.v_debug THEN
                message('pr_nom_fic_imp(6) '||v_nom_fic||'/'||NAME_IN('bl_bat.nom_fic_imp'));
            END IF;
      END IF;

      /*
      **  Sauvegarde du nom de fichier utilisé
      */

      w_nom_fic_imp := name_in('bl_bat.nom_fic_imp');

      SET_ITEM_PROPERTY('bl_bat.fmt', ITEM_IS_VALID, PROPERTY_TRUE);

   else
      /* Lecture de la destination locale sur le serveur batch pour les document d'impression  */
      open c_dir_des(NAME_IN('bl_bat.cod_que'));
      fetch c_dir_des into v_tmp_dir;
      close c_dir_des;

      IF NAME_IN( 'bl_bat.cod_fmt' ) = 'PDF' THEN
         COPY(LOWER(v_tmp_dir||NAME_IN('parameter.nom_prg')||v_seq||'.pdf'), 'bl_bat.nom_fic_imp');
      ELSIF NAME_IN( 'bl_bat.cod_fmt' ) IN ('HTML','HTMLCSS') THEN
         COPY(LOWER(v_tmp_dir||NAME_IN('parameter.nom_prg')||v_seq||'.htm'), 'bl_bat.nom_fic_imp');
      ELSIF NAME_IN( 'bl_bat.cod_fmt' ) = 'CSV' THEN
         COPY(LOWER(v_tmp_dir||NAME_IN('parameter.nom_prg')||v_seq||'.csv'), 'bl_bat.nom_fic_imp');
      ELSIF NAME_IN( 'bl_bat.cod_fmt' ) = 'XML' THEN
         COPY(LOWER(v_tmp_dir||NAME_IN('parameter.nom_prg')||v_seq||'.xml'), 'bl_bat.nom_fic_imp');
      ELSE
         COPY(LOWER(v_tmp_dir||NAME_IN('parameter.nom_prg')||v_seq||'.lis'), 'bl_bat.nom_fic_imp');
      END IF;
   end if;
           
   IF  pa_var.v_debug THEN
      message('pr_nom_fic_imp(7) '||NAME_IN('bl_bat.nom_fic_imp'));
   END IF;           

   z_trace.end_procedure( p_package   => 'PA_BATCH', p_procedure => 'PR_NOM_FIC_IMP' );

END pr_nom_fic_imp;


FUNCTION FU_TIT_PRG( p_cod_lan IN VARCHAR2 )
         RETURN VARCHAR2
IS
   v_load     VARCHAR2(100) := FU_WHICH_NAME;
   v_cod_lan      VARCHAR2(2);

/*
**  Recherche du titre du programme en fonction du code langue demandé
*/

   CURSOR c_tit (c_nom_prg VARCHAR2, c_cod_lan VARCHAR2)
   IS
   SELECT REPLACE(
                NVL(DECODE(c_cod_lan,'1',p.tit_prg_001,
                                     '2',p.tit_prg_002,
                                     '3',p.tit_prg_003,
                                     '4',p.tit_prg_004,
                                     '5',p.tit_prg_005)
                                        ,nvl(p.tit_prg_001,p.tit_prg)),'&',NULL) tit_prg
     FROM ba_programme   p
    WHERE p.nom_prg = c_nom_prg;

   v_tit_prg ba_programme.tit_prg%TYPE;

BEGIN
   
   z_trace.begin_procedure( p_package   => 'PA_BATCH', p_procedure => 'FU_TIT_PRG' );

   IF    p_cod_lan = 'S' THEN
         v_cod_lan := NAME_IN('parameter.cod_lan_soc');
   ELSIF p_cod_lan in ('U','T') THEN
         v_cod_lan := NAME_IN('parameter.cod_lan_uti');
   ELSE
         v_cod_lan := p_cod_lan;
   END IF;

   OPEN  c_tit (v_load, v_cod_lan);
   FETCH c_tit INTO v_tit_prg;
   CLOSE c_tit;

   z_trace.end_procedure( p_package   => 'PA_BATCH', p_procedure => 'FU_TIT_PRG' );

   RETURN( v_tit_prg );

END FU_TIT_PRG;

END;
