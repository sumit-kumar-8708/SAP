
* interactive_alv Report(Double click on First ALV list then again second ALV list Open)

REPORT zinteractivereport_3.

TYPE-POOLS: slis.

DATA: gt_fieldcat TYPE slis_t_fieldcat_alv,
      gs_fieldcat TYPE slis_fieldcat_alv.
DATA: gt_listheader TYPE slis_t_listheader,
      gs_listheader TYPE slis_listheader.

DATA: gt_fieldcat_alv2 TYPE slis_t_fieldcat_alv,
      gs_fieldcat_alv2 TYPE slis_fieldcat_alv.

TYPES: BEGIN OF ty_vbak,
         vbeln TYPE vbak-vbeln,
         erdat TYPE vbak-erdat,
         auart TYPE vbak-auart,
       END OF ty_vbak,

       BEGIN OF ty_vbap,
         vbeln TYPE vbap-vbeln,
         posnr TYPE vbap-posnr,
         matnr TYPE vbap-matnr,
         arktx TYPE vbap-arktx,
         netpr TYPE vbap-netpr,
       END OF ty_vbap.

DATA: gt_vbak  TYPE TABLE OF ty_vbak,
      gw_vbak  TYPE ty_vbak,
      gt_vbap  TYPE TABLE OF ty_vbap,
      gw_vbap  TYPE ty_vbap,
      d_vbeln  TYPE vbak-vbeln, " variable declare for select-option
      lv_vbeln TYPE vbak-vbeln,
      v_field  TYPE string,
      v_value  TYPE string.


SELECT-OPTIONS s_vbeln FOR d_vbeln.

START-OF-SELECTION.
  PERFORM get_data_vbak.
  PERFORM build_fieldcat.
  PERFORM display_alv.

FORM get_data_vbak .

  REFRESH gt_vbak.
  CLEAR gw_vbak.

  SELECT vbeln
    erdat
    auart
    INTO TABLE gt_vbak
    FROM vbak
    WHERE vbeln IN s_vbeln.

ENDFORM.

FORM get_data_vbap  USING    p_v_value TYPE vbak-vbeln.

  REFRESH gt_vbap.
  CLEAR gw_vbap.

  SELECT vbeln
   posnr
   matnr
   arktx
   netpr
   INTO TABLE gt_vbap
   FROM vbap
   WHERE vbeln = p_v_value.

*  LOOP AT gt_vbap INTO gw_vbap.
*
*    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*      EXPORTING
*        input  = gw_vbap-vbeln
*      IMPORTING
*        output = gw_vbap-vbeln.
*
*    MODIFY gt_vbap FROM gw_vbap.
*
*  ENDLOOP.

ENDFORM.

FORM conversion_input CHANGING p_vbeln TYPE vbak-vbeln.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = p_vbeln
    IMPORTING
      output = p_vbeln.

ENDFORM.

FORM build_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = 'VBELN'.
  gs_fieldcat-seltext_m = 'Sales Document'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = 'ERDAT'.
  gs_fieldcat-seltext_m = 'Created On'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = 'AUART'.
  gs_fieldcat-seltext_m = 'Order Type'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.

ENDFORM.


FORM display_alv.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
*     I_INTERFACE_CHECK       = ' '
*     I_BYPASSING_BUFFER      = ' '
*     I_BUFFER_ACTIVE         = ' '
      i_callback_program      = sy-repid " program name show
*     I_CALLBACK_PF_STATUS_SET          = ' '
      i_callback_user_command = 'USER_COMMAND' " ALV me user ke click ko handle karne ke liye
      i_callback_top_of_page  = 'TOP_OF_PAGE'
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME        =
*     I_BACKGROUND_ID         = ' '
*     I_GRID_TITLE            =
*     I_GRID_SETTINGS         =
*     IS_LAYOUT               =
      it_fieldcat             = gt_fieldcat " Field Catalog pass for table header show
*     IT_EXCLUDING            =
*     IT_SPECIAL_GROUPS       =
*     IT_SORT                 =
*     IT_FILTER               =
*     IS_SEL_HIDE             =
*     I_DEFAULT               = 'X'
      i_save                  = 'A'
*     IS_VARIANT              =
*     IT_EVENTS               =
*     IT_EVENT_EXIT           =
*     IS_PRINT                =
*     IS_REPREP_ID            =
*     I_SCREEN_START_COLUMN   = 0
*     I_SCREEN_START_LINE     = 0
*     I_SCREEN_END_COLUMN     = 0
*     I_SCREEN_END_LINE       = 0
*     I_HTML_HEIGHT_TOP       = 0
*     I_HTML_HEIGHT_END       = 0
*     IT_ALV_GRAPHICS         =
*     IT_HYPERLINK            =
*     IT_ADD_FIELDCAT         =
*     IT_EXCEPT_QINFO         =
*     IR_SALV_FULLSCREEN_ADAPTER        =
* IMPORTING
*     E_EXIT_CAUSED_BY_CALLER =
*     ES_EXIT_CAUSED_BY_USER  =
    TABLES
      t_outtab                = gt_vbak "ALV Data
    EXCEPTIONS
      program_error           = 1
      OTHERS                  = 2.
  IF sy-subrc <> 0.
    MESSAGE 'Error while displaying ALV' TYPE 'E'.
  ENDIF.

ENDFORM.

FORM top_of_page.

  DATA : date_string TYPE string.

  CLEAR gt_listheader.

  "Heading
  CLEAR gs_listheader.
  gs_listheader-typ  = 'H'.
  gs_listheader-info = 'Sales Order Report'.
  APPEND gs_listheader TO gt_listheader.

  "Program Name
  CLEAR gs_listheader.
  gs_listheader-typ  = 'S'.
  gs_listheader-key  = 'Program'.
  gs_listheader-info = sy-repid.
  APPEND gs_listheader TO gt_listheader.

  "Created By
  CLEAR gs_listheader.
  gs_listheader-typ  = 'S'.
  gs_listheader-key  = 'Created By'.
  gs_listheader-info = sy-uname.
  APPEND gs_listheader TO gt_listheader.

  "Current Date
  CLEAR gs_listheader.

*  CONCATENATE 'Date: ' sy-datum+6(2) sy-datum+4(2) sy-datum+0(4) INTO date_string SEPARATED BY '-'.
  CONCATENATE sy-datum+6(2) sy-datum+4(2) sy-datum+0(4) INTO date_string SEPARATED BY '-'.

  gs_listheader-typ  = 'S'.
  gs_listheader-key  = 'Date'.
*  gs_listheader-info = sy-datum.
  gs_listheader-info = date_string.
  APPEND gs_listheader TO gt_listheader.

  CLEAR gs_listheader.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = gt_listheader.

ENDFORM.

FORM user_command USING r_ucomm LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.

  CASE r_ucomm.

    WHEN '&IC1'.

      READ TABLE gt_vbak INTO gw_vbak INDEX rs_selfield-tabindex.

      IF sy-subrc = 0.

        PERFORM get_data_vbap USING gw_vbak-vbeln.

        IF sy-subrc <> 0.
          MESSAGE 'No Data Found in VBAP Table' TYPE 'E'.
        ENDIF.

        PERFORM build_fieldcat_alv2.
        PERFORM display_alv_vbap.

      ENDIF.

  ENDCASE.

ENDFORM.

FORM build_fieldcat_alv2.

  CLEAR gs_fieldcat_alv2.
  REFRESH gt_fieldcat_alv2.

  gs_fieldcat_alv2-fieldname = 'vbeln'.
  gs_fieldcat_alv2-seltext_m = 'Sales Document'.
  gs_fieldcat-no_zero   = 'X'.
  APPEND gs_fieldcat_alv2 TO gt_fieldcat_alv2.
  CLEAR gs_fieldcat_alv2.
  gs_fieldcat_alv2-fieldname = 'posnr'.
  gs_fieldcat_alv2-seltext_m = 'Sales Document Item'.
  APPEND gs_fieldcat_alv2 TO gt_fieldcat_alv2.

  CLEAR gs_fieldcat_alv2.
  gs_fieldcat_alv2-fieldname = 'matnr'.
  gs_fieldcat_alv2-seltext_m = 'Material Number'.
  APPEND gs_fieldcat_alv2 TO gt_fieldcat_alv2.

  CLEAR gs_fieldcat_alv2.
  gs_fieldcat_alv2-fieldname = 'arktx'.
  gs_fieldcat_alv2-seltext_m = 'Short text for sales order item'.
  APPEND gs_fieldcat_alv2 TO gt_fieldcat_alv2.

  CLEAR gs_fieldcat_alv2.
  gs_fieldcat_alv2-fieldname = 'netpr'.
  gs_fieldcat_alv2-seltext_m = 'Net price'.
  gs_fieldcat_alv2-do_sum    = 'X'.    "Total dikhane ke liye
  APPEND gs_fieldcat_alv2 TO gt_fieldcat_alv2.

  CLEAR gs_fieldcat_alv2.

ENDFORM.


FORM display_alv_vbap.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid " program name show
*     I_CALLBACK_PF_STATUS_SET          = ' '
*     i_callback_user_command = 'USER_COMMAND' " ALV me user ke click ko handle karne ke liye
*     i_callback_top_of_page  = 'TOP_OF_PAGE'
      it_fieldcat        = gt_fieldcat_alv2 " Field Catalog pass for table header show
    TABLES
      t_outtab           = gt_vbap "ALV Data
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.
  IF sy-subrc <> 0.
    MESSAGE 'Error while displaying ALV 2' TYPE 'E'.
  ENDIF.

ENDFORM.
