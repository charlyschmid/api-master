PROCEDURE PR_SET_PROPERTY (ITEM_ID IN ITEM, PROPERTY IN NUMBER, VALUE NUMBER, CASCADE IN BOOLEAN DEFAULT TRUE)
IS

  v_itm_type     VARCHAR2(255) := NULL;
  v_mm_itm_name  VARCHAR2(100);
  v_itm_name     VARCHAR2(100);
  
BEGIN

  v_itm_type:=GET_ITEM_PROPERTY(ITEM_ID, ITEM_TYPE);

  IF    v_itm_type = 'BUTTON' THEN
        IF    PROPERTY = REQUIRED THEN
              RETURN;
        ELSIF PROPERTY = UPDATEABLE THEN
              RETURN;
        ELSIF PROPERTY = UPDATE_NULL THEN
              RETURN;
        ELSIF PROPERTY = ITEM_IS_VALID THEN
              RETURN;
        END IF;
  ELSIF v_itm_type = 'CHART ITEM' THEN
        IF    PROPERTY = REQUIRED THEN
              RETURN;
        ELSIF PROPERTY = UPDATEABLE THEN
              RETURN;
        ELSIF PROPERTY = UPDATE_NULL THEN
              RETURN;
        ELSIF PROPERTY = MOUSE_NAVIGATE THEN
              RETURN;
        END IF;
  ELSIF v_itm_type = 'CHECKBOX' THEN
        IF    PROPERTY = REQUIRED THEN
              RETURN;
        ELSIF PROPERTY = UPDATE_NULL THEN
              RETURN;
        END IF;        
  ELSIF v_itm_type = 'DISPLAY ITEM' THEN
        IF    PROPERTY = ENABLED THEN
              PR_GRISE(ITEM_ID, VALUE);
              RETURN;
        ELSIF PROPERTY = NAVIGABLE THEN
              RETURN;
        ELSIF PROPERTY = REQUIRED THEN
              RETURN;
        ELSIF PROPERTY = UPDATEABLE THEN
              RETURN;
        ELSIF PROPERTY = UPDATE_NULL THEN
              RETURN;
        ELSIF PROPERTY = MOUSE_NAVIGATE THEN
              RETURN;
        END IF;
  ELSIF v_itm_type = 'IMAGE' THEN
        IF    PROPERTY = MOUSE_NAVIGATE THEN
              RETURN;
        END IF;
  ELSIF v_itm_type = 'LIST' THEN
        IF    PROPERTY = UPDATE_NULL THEN
              RETURN;
        END IF;
  ELSIF v_itm_type = 'OLE OBJECT' THEN
        IF    PROPERTY = UPDATE_NULL THEN
              RETURN;
        END IF;
  ELSIF v_itm_type = 'RADIO GROUP' THEN
        IF    PROPERTY = DISPLAYED THEN
              RETURN;
        ELSIF PROPERTY = HEIGHT THEN
              RETURN;
        ELSIF PROPERTY = WIDTH  THEN
              RETURN;
        ELSIF PROPERTY = REQUIRED THEN
              RETURN;
        ELSIF PROPERTY = UPDATE_NULL THEN
              RETURN;
        END IF;
  ELSIF v_itm_type = 'TEXT ITEM' THEN
        IF    PROPERTY = MOUSE_NAVIGATE THEN
              RETURN;
        END IF;
  ELSIF v_itm_type = 'USER AREA' THEN
        IF    PROPERTY = UPDATE_NULL THEN
              RETURN;
        END IF;
  ELSIF v_itm_type = 'VBX CONTROL' THEN
         IF   PROPERTY = UPDATE_NULL THEN
              RETURN;
         END IF;
  ELSIF    v_itm_type = 'TREE' THEN
        IF    PROPERTY = REQUIRED THEN
              RETURN;
        ELSIF PROPERTY = UPDATEABLE THEN
              RETURN;
        ELSIF PROPERTY = UPDATE_NULL THEN
              RETURN;
        ELSIF PROPERTY = ITEM_IS_VALID THEN
              RETURN;
        END IF;         
  END IF; 

  IF PROPERTY = DISPLAYED AND VALUE = PROPERTY_TRUE
  THEN
     IF PA_GET_ITEM.FU_PROPERTY ( ITEM_ID, ITEM_CANVAS ) IS NULL
     THEN
        RETURN;
     END IF;
  ELSIF PROPERTY = ENABLED AND VALUE = PROPERTY_TRUE
  THEN
     IF NVL(PA_GET_ITEM.FU_PROPERTY ( ITEM_ID, DISPLAYED ) , 'TRUE') = 'FALSE'
     THEN
        RETURN;
     END IF;
  ELSIF PROPERTY = NAVIGABLE AND VALUE = PROPERTY_TRUE
  THEN
     IF NVL(PA_GET_ITEM.FU_PROPERTY ( ITEM_ID, ENABLED )   , 'FALSE') = 'FALSE'
     OR NVL(PA_GET_ITEM.FU_PROPERTY ( ITEM_ID, DISPLAYED ) , 'TRUE') = 'FALSE'
     THEN
        RETURN;
     END IF;
  ELSIF PROPERTY = UPDATE_NULL AND VALUE = PROPERTY_TRUE
  THEN
     IF NVL(PA_GET_ITEM.FU_PROPERTY ( ITEM_ID, ENABLED )   , 'FALSE') = 'FALSE'
     OR NVL(PA_GET_ITEM.FU_PROPERTY ( ITEM_ID, DISPLAYED ) , 'TRUE') = 'FALSE'
     OR NVL(PA_GET_ITEM.FU_PROPERTY ( ITEM_ID, UPDATEABLE ) , 'FALSE') = 'FALSE'
     THEN
        RETURN;
     END IF;
  ELSIF PROPERTY = UPDATEABLE AND VALUE = PROPERTY_TRUE
  THEN
     IF NVL(PA_GET_ITEM.FU_PROPERTY ( ITEM_ID, ENABLED )   , 'FALSE') = 'FALSE'
     OR NVL(PA_GET_ITEM.FU_PROPERTY ( ITEM_ID, DISPLAYED ) , 'TRUE') = 'FALSE'
     OR NVL(PA_GET_ITEM.FU_PROPERTY ( ITEM_ID, UPDATE_NULL ) , 'FALSE') = 'TRUE'
     THEN
        RETURN;
     END IF;
  ELSIF PROPERTY = UPDATE_ALLOWED AND VALUE = PROPERTY_TRUE
  THEN
     IF NVL(PA_GET_ITEM.FU_PROPERTY ( ITEM_ID, ENABLED )   , 'FALSE') = 'FALSE'
     OR NVL(PA_GET_ITEM.FU_PROPERTY ( ITEM_ID, DISPLAYED ) , 'TRUE') = 'FALSE'
     THEN
        RETURN;
     END IF;
  ELSIF PROPERTY = REQUIRED AND VALUE = PROPERTY_TRUE
  THEN
     IF NVL(PA_GET_ITEM.FU_PROPERTY ( ITEM_ID, ENABLED )   , 'FALSE') = 'FALSE'
     OR NVL(PA_GET_ITEM.FU_PROPERTY ( ITEM_ID, DISPLAYED ) , 'TRUE') = 'FALSE'
     OR NVL(PA_GET_ITEM.FU_PROPERTY ( ITEM_ID, UPDATEABLE ) , 'FALSE') = 'FALSE'
     THEN
        RETURN;
     END IF;
  ELSIF PROPERTY = QUERYABLE AND VALUE = PROPERTY_TRUE
  THEN
     IF NVL(PA_GET_ITEM.FU_PROPERTY ( ITEM_ID, DISPLAYED ) , 'TRUE') = 'FALSE'
     THEN
        RETURN;
     END IF;
  END IF;
  
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

  IF CASCADE
  THEN  
    PR_CASCADE(ITEM_ID, PROPERTY, VALUE);

    IF    PROPERTY = ENABLED
    THEN
      IF VALUE = PROPERTY_TRUE
      THEN
        PR_GRISE      (ITEM_ID , PROPERTY_TRUE );
        PR_BOUTONS_ET_PROMPTS (PROPERTY, VALUE);
      ELSIF VALUE = PROPERTY_FALSE
      THEN
        PR_GRISE      (ITEM_ID , PROPERTY_FALSE );
        PR_BOUTONS_ET_PROMPTS (PROPERTY, VALUE);
      END IF;
    ELSIF PROPERTY = DISPLAYED
    THEN
      IF VALUE = PROPERTY_TRUE
      THEN
         PR_BOUTONS_ET_PROMPTS (PROPERTY, VALUE);
      ELSIF VALUE = PROPERTY_FALSE
      THEN
         PR_BOUTONS_ET_PROMPTS (PROPERTY, VALUE);
       END IF;
     END IF;
  END IF;

EXCEPTION
  WHEN others THEN NULL;
  
END PR_SET_PROPERTY;