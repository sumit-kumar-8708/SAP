*&---------------------------------------------------------------------*
*& Report ZINTERACTIVEREPORT_2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zinteractivereport_2.

TYPE-POOLS: slis.

DATA: gt_fieldcat TYPE slis_t_fieldcat_alv,
      gs_fieldcat TYPE slis_fieldcat_alv.
DATA: gt_listheader TYPE slis_t_listheader,
      gs_listheader TYPE slis_listheader.

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

AT LINE-SELECTION.

  GET CURSOR FIELD v_field VALUE v_value.

  lv_vbeln = v_value.

  PERFORM conversion_input CHANGING lv_vbeln.

  PERFORM get_data_vbap USING lv_vbeln.

FORM get_data_vbak .

  SELECT vbeln
    erdat
    auart
    INTO TABLE gt_vbak
    FROM vbak
    WHERE vbeln IN s_vbeln.

ENDFORM.

FORM get_data_vbap  USING    p_v_value TYPE vbak-vbeln.

  SELECT vbeln
   posnr
   matnr
   arktx
   netpr
   INTO TABLE gt_vbap
   FROM vbap
   WHERE vbeln = p_v_value.

  LOOP AT gt_vbap INTO gw_vbap.
    IF sy-subrc = 0.
      WRITE:/ gw_vbap-vbeln,
      gw_vbap-posnr,
      gw_vbap-matnr,
      gw_vbap-arktx,
      gw_vbap-netpr.
    ENDIF.
  ENDLOOP.

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
  gs_fieldcat-seltext_m = 'Sales Order'.
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
*     I_INTERFACE_CHECK  = ' '
*     I_BYPASSING_BUFFER = ' '
*     I_BUFFER_ACTIVE    = ' '
      i_callback_program = sy-repid " program name show
*     I_CALLBACK_PF_STATUS_SET          = ' '
*     I_CALLBACK_USER_COMMAND           = ' '
      I_CALLBACK_TOP_OF_PAGE            = 'TOP_OF_PAGE'
*     I_CALLBACK_HTML_TOP_OF_PAGE       = ' '
*     I_CALLBACK_HTML_END_OF_LIST       = ' '
*     I_STRUCTURE_NAME   =
*     I_BACKGROUND_ID    = ' '
*     I_GRID_TITLE       =
*     I_GRID_SETTINGS    =
*     IS_LAYOUT          =
      it_fieldcat        = gt_fieldcat " Field Catalog pass for table header show
*     IT_EXCLUDING       =
*     IT_SPECIAL_GROUPS  =
*     IT_SORT            =
*     IT_FILTER          =
*     IS_SEL_HIDE        =
*     I_DEFAULT          = 'X'
      i_save             = 'A'
*     IS_VARIANT         =
*     IT_EVENTS          =
*     IT_EVENT_EXIT      =
*     IS_PRINT           =
*     IS_REPREP_ID       =
*     I_SCREEN_START_COLUMN             = 0
*     I_SCREEN_START_LINE               = 0
*     I_SCREEN_END_COLUMN               = 0
*     I_SCREEN_END_LINE  = 0
*     I_HTML_HEIGHT_TOP  = 0
*     I_HTML_HEIGHT_END  = 0
*     IT_ALV_GRAPHICS    =
*     IT_HYPERLINK       =
*     IT_ADD_FIELDCAT    =
*     IT_EXCEPT_QINFO    =
*     IR_SALV_FULLSCREEN_ADAPTER        =
* IMPORTING
*     E_EXIT_CAUSED_BY_CALLER           =
*     ES_EXIT_CAUSED_BY_USER            =
    TABLES
      t_outtab           = gt_vbak "ALV Data
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.
  IF sy-subrc <> 0.
    MESSAGE 'Error while displaying ALV' TYPE 'E'.
  ENDIF.

ENDFORM.

FORM top_of_page.

  DATA : date_string type string.

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
