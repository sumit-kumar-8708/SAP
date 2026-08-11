REPORT Z_TASK_EX_1.

TYPE-POOLS: slis.

*---------------------------------------------------------------------*
* SALES ORDER DATA
*---------------------------------------------------------------------*
TYPES: BEGIN OF ty_vbak,
         vbeln TYPE vbak-vbeln,
         erdat TYPE vbak-erdat,
         vbtyp TYPE vbak-vbtyp,
         netwr TYPE vbak-netwr,
         waerk TYPE vbak-waerk,
         vtweg TYPE vbak-vtweg,
         spart TYPE vbak-spart,
         vkorg TYPE vbak-vkorg,
         vkgrp TYPE vbak-vkgrp,
         color TYPE char4,
       END OF ty_vbak.

DATA: lt_vbak TYPE TABLE OF ty_vbak.

*---------------------------------------------------------------------*
* PARTNER DATA
*---------------------------------------------------------------------*
TYPES: BEGIN OF ty_vbpa,
         vbeln TYPE vbpa-vbeln,
         posnr TYPE vbpa-posnr,
         parvw TYPE vbpa-parvw,
         kunnr TYPE vbpa-kunnr,
         pernr TYPE vbpa-pernr,
       END OF ty_vbpa.

DATA: lt_vbpa TYPE TABLE OF ty_vbpa.

*---------------------------------------------------------------------*
* ALV DATA
*---------------------------------------------------------------------*
DATA: lt_fieldcat TYPE slis_t_fieldcat_alv,
      ls_fieldcat TYPE slis_fieldcat_alv,
      ls_layout    TYPE slis_layout_alv.

*---------------------------------------------------------------------*
* START
*---------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM get_data.
  PERFORM set_color.
  PERFORM build_fieldcatalog.
  PERFORM display_alv.

*---------------------------------------------------------------------*
* GET SALES ORDER DATA
*---------------------------------------------------------------------*
FORM get_data.

  SELECT vbeln,
         erdat,
         vbtyp,
         netwr,
         waerk,
         vtweg,
         spart,
         vkorg,
         vkgrp,
         @space AS color
    FROM vbak
    INTO TABLE @lt_vbak.
*    WHERE auart = 'OR'.

  IF sy-subrc <> 0.
    MESSAGE 'No Standard Sales Orders found' TYPE 'I'.
    LEAVE LIST-PROCESSING.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
* COLOR DBR1 ROW
*---------------------------------------------------------------------*
FORM set_color.

  LOOP AT lt_vbak ASSIGNING FIELD-SYMBOL(<fs_vbak>).

    IF <fs_vbak>-vkorg = '0001'.
      <fs_vbak>-color = 'C610'.
    ENDIF.

  ENDLOOP.

ENDFORM.

*---------------------------------------------------------------------*
* FIELD CATALOG
*---------------------------------------------------------------------*
FORM build_fieldcatalog.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'VBELN'.
  ls_fieldcat-seltext_m = 'Order No'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'ERDAT'.
  ls_fieldcat-seltext_m = 'Creation Date'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'VBTYP'.
  ls_fieldcat-seltext_m = 'Document Category'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'NETWR'.
  ls_fieldcat-seltext_m = 'Net Value'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'WAERK'.
  ls_fieldcat-seltext_m = 'Currency'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'VTWEG'.
  ls_fieldcat-seltext_m = 'Dist. Channel'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'SPART'.
  ls_fieldcat-seltext_m = 'Division'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'VKORG'.
  ls_fieldcat-seltext_m = 'Sales Org'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'VKGRP'.
  ls_fieldcat-seltext_m = 'Sales Group'.
  APPEND ls_fieldcat TO lt_fieldcat.

ENDFORM.

*---------------------------------------------------------------------*
* DISPLAY MAIN ALV
*---------------------------------------------------------------------*
FORM display_alv.

  ls_layout-info_fieldname = 'COLOR'.
  ls_layout-zebra         = 'X'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = sy-repid
      i_callback_pf_status_set = 'PF_STATUS'
      i_callback_user_command  = 'USER_COMMAND'
      is_layout                = ls_layout
      it_fieldcat              = lt_fieldcat
    TABLES
      t_outtab                 = lt_vbak
    EXCEPTIONS
      program_error             = 1
      OTHERS                    = 2.

ENDFORM.

*---------------------------------------------------------------------*
* CREATE CUSTOM BUTTON
*---------------------------------------------------------------------*
FORM pf_status USING rt_extab TYPE slis_t_extab.

  SET PF-STATUS 'ZSTATUS'.

ENDFORM.

*---------------------------------------------------------------------*
* USER COMMAND
*---------------------------------------------------------------------*
FORM user_command USING r_ucomm     LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.

  CASE r_ucomm.

    WHEN 'PARTNERS'.

      PERFORM get_selected_order USING rs_selfield-tabindex.

  ENDCASE.

ENDFORM.

*---------------------------------------------------------------------*
* GET SELECTED ORDER
*---------------------------------------------------------------------*
FORM get_selected_order USING p_tabix TYPE sy-tabix.

  DATA: ls_vbak TYPE ty_vbak.

  IF p_tabix IS INITIAL.

    MESSAGE 'Please select a Sales Order first' TYPE 'I'.
    RETURN.

  ENDIF.

  READ TABLE lt_vbak INTO ls_vbak INDEX p_tabix.

  IF sy-subrc <> 0.

    MESSAGE 'Sales Order not found' TYPE 'I'.
    RETURN.

  ENDIF.

  PERFORM get_partners USING ls_vbak-vbeln.

ENDFORM.

*---------------------------------------------------------------------*
* GET PARTNERS FROM VBPA
*---------------------------------------------------------------------*
FORM get_partners USING p_vbeln TYPE vbak-vbeln.

  CLEAR lt_vbpa.

  SELECT vbeln,
         posnr,
         parvw,
         kunnr,
         pernr
    FROM vbpa
    INTO TABLE @lt_vbpa
    WHERE vbeln = @p_vbeln.

  IF sy-subrc <> 0.

    MESSAGE 'No partner details found' TYPE 'I'.
    RETURN.

  ENDIF.

  PERFORM display_partner_popup.

ENDFORM.

*---------------------------------------------------------------------*
* DISPLAY PARTNER POPUP
*---------------------------------------------------------------------*
FORM display_partner_popup.

  DATA: lt_partner_fieldcat TYPE slis_t_fieldcat_alv,
        ls_partner_fieldcat TYPE slis_fieldcat_alv.

*---------------------------------------------------------------------*
* VBELN
*---------------------------------------------------------------------*
  CLEAR ls_partner_fieldcat.
  ls_partner_fieldcat-fieldname = 'VBELN'.
  ls_partner_fieldcat-seltext_m = 'Sales Order'.
  APPEND ls_partner_fieldcat TO lt_partner_fieldcat.

*---------------------------------------------------------------------*
* POSNR
*---------------------------------------------------------------------*
  CLEAR ls_partner_fieldcat.
  ls_partner_fieldcat-fieldname = 'POSNR'.
  ls_partner_fieldcat-seltext_m = 'Item'.
  APPEND ls_partner_fieldcat TO lt_partner_fieldcat.

*---------------------------------------------------------------------*
* PARVW
*---------------------------------------------------------------------*
  CLEAR ls_partner_fieldcat.
  ls_partner_fieldcat-fieldname = 'PARVW'.
  ls_partner_fieldcat-seltext_m = 'Partner Function'.
  APPEND ls_partner_fieldcat TO lt_partner_fieldcat.

*---------------------------------------------------------------------*
* KUNNR
*---------------------------------------------------------------------*
  CLEAR ls_partner_fieldcat.
  ls_partner_fieldcat-fieldname = 'KUNNR'.
  ls_partner_fieldcat-seltext_m = 'Customer'.
  APPEND ls_partner_fieldcat TO lt_partner_fieldcat.

*---------------------------------------------------------------------*
* PERNR
*---------------------------------------------------------------------*
  CLEAR ls_partner_fieldcat.
  ls_partner_fieldcat-fieldname = 'PERNR'.
  ls_partner_fieldcat-seltext_m = 'Personnel No'.
  APPEND ls_partner_fieldcat TO lt_partner_fieldcat.

*---------------------------------------------------------------------*
* POPUP ALV
*---------------------------------------------------------------------*
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
      i_grid_title       = 'Partner Details'
      it_fieldcat        = lt_partner_fieldcat
      i_screen_start_column = 10
      i_screen_start_line   = 5
      i_screen_end_column   = 100
      i_screen_end_line     = 25
    TABLES
      t_outtab = lt_vbpa
    EXCEPTIONS
      program_error = 1
      OTHERS        = 2.

ENDFORM.
