PROCEDURE PR_SET_PROPERTY (ITEM_ID IN ITEM, PROPERTY IN NUMBER, VALUE VARCHAR2)
IS

  v_itm_type     VARCHAR2(255) := NULL;
  v_mm_itm_name  VARCHAR2(100);
  v_itm_name     VARCHAR2(100);

BEGIN

  IF PROPERTY = VISUAL_ATTRIBUTE
  THEN
     IF PA_GET_ITEM.FU_PROPERTY ( ITEM_ID, ITEM_CANVAS ) IS NULL
     THEN
        RETURN;
     END IF;
  END IF;

  v_itm_type:=GET_ITEM_PROPERTY(ITEM_ID, ITEM_TYPE);
  
  IF PROPERTY = REQUIRED
  THEN
     IF v_itm_type != 'BUTTON'
     THEN
        v_itm_name := UPPER ( GET_ITEM_PROPERTY ( ITEM_ID, BLOCK_NAME ) || '.' || GET_ITEM_PROPERTY ( ITEM_ID, ITEM_NAME ) );
        BEGIN
           v_mm_itm_name := PA_GET_ITEM.FU_PROPERTY ( ITEM_ID, MASTER_MIRROR_ITEM );
        EXCEPTION
           WHEN OTHERS
           THEN
              message ('Cannot get master mirror item property for item=' || v_itm_name); synchronize;
              v_mm_itm_name := null;
        END;
        IF v_itm_name IS NOT NULL AND v_mm_itm_name IS NOT NULL
        THEN
           IF v_itm_name != v_mm_itm_name 
           THEN
              RETURN;
           END IF;
        END IF;
     END IF;
  END IF;
  
  SET_ITEM_PROPERTY(ITEM_ID, PROPERTY, VALUE);

EXCEPTION

  WHEN others THEN NULL;

END PR_SET_PROPERTY;