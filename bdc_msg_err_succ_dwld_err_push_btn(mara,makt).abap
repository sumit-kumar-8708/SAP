
REPORT z_rec_mat_6
       NO STANDARD PAGE HEADING LINE-SIZE 255.

TYPE-POOLS: slis, icon.

TYPES: BEGIN OF record,

         mbrsh TYPE mara-mbrsh,
         mtart TYPE mara-mtart,
         maktx TYPE makt-maktx,
         meins TYPE mara-meins,

       END OF record.

TYPES: BEGIN OF ty_output,
         srno     TYPE i,
         material TYPE mara-matnr,
         maktx    TYPE makt-maktx,
         status   TYPE icon_d,
         message  TYPE string,
       END OF ty_output.

DATA: it_record TYPE TABLE OF record,
      wa_record TYPE record.
DATA: lv_msg TYPE string.

DATA: it_bdcdata TYPE TABLE OF bdcdata,
      wa_bdcdata TYPE bdcdata.
DATA: it_message TYPE TABLE OF bdcmsgcoll,
      wa_message TYPE bdcmsgcoll.

"Duplicate Validation
DATA: lv_maktx TYPE makt-maktx.

*ALV Report START
DATA: gt_output TYPE TABLE OF ty_output,
      gs_output TYPE ty_output.
DATA: gv_total   TYPE i,
      gv_success TYPE i,
      gv_failed  TYPE i,
      gv_exist   TYPE i,
      gv_srno    TYPE i.

DATA: gt_fieldcat TYPE slis_t_fieldcat_alv,
      gs_fieldcat TYPE slis_fieldcat_alv,

      gs_layout   TYPE slis_layout_alv,

      gt_events   TYPE slis_t_event,
      gs_event    TYPE slis_alv_event.
*ALV Report END

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = 'C:\Users\Sumit Kumar\Desktop\SAP-ABAP HANA\rec_3.txt'
      filetype                = 'ASC'    " File Type (ASC or BIN)
      has_field_separator     = 'X'    " Columns Separated by Tabs in Case of ASCII Upload
*     header_length           = 0    " Length of Header for Binary Data
*     read_by_line            = 'X'    " The file will be written to the internal table line-by-line
*     dat_mode                = SPACE    " Numeric and Date Fields Imported in ws_download 'DAT' Format
*     codepage                =     " Character Representation for Output
*     ignore_cerr             = ABAP_TRUE    " Specifies whether to ignore errors converting character sets
*     replacement             = '#'    " Replacement Character for Non-Convertible Characters
*     check_bom               = SPACE    " The consistency of the codepage and byte order mark will be
*     virus_scan_profile      =     " Virus Scan Profile
*     no_auth_check           = SPACE    " Switch off Check for Access Rights
*    IMPORTING
*     filelength              =     " File Length
*     header                  =     " File Header in Case of Binary Upload
    TABLES
      data_tab                = it_record
*    CHANGING
*     isscanperformed         = SPACE    " File already scanned
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      OTHERS                  = 17.
  IF sy-subrc <> 0.
*   MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  DESCRIBE TABLE it_record LINES gv_total.

  LOOP AT it_record INTO wa_record.

*  Duplicate Validation
    CLEAR lv_maktx.

*  SELECT SINGLE maktx
*    INTO lv_maktx
*    FROM makt
*    WHERE maktx = wa_record-maktx
*      AND spras = sy-langu.
*
*  IF sy-subrc = 0.
*    WRITE:/ 'Duplicate Record Found :', wa_record-maktx.
*    CONTINUE.
*  ENDIF.

    SELECT SINGLE maktx
    FROM makt
    INTO lv_maktx
    WHERE maktx = wa_record-maktx
    AND spras = sy-langu.

    IF sy-subrc = 0.

      gv_exist = gv_exist + 1.
      gv_srno  = gv_srno + 1.

      CLEAR gs_output.

      gs_output-srno = gv_srno.
      gs_output-maktx = wa_record-maktx.
      gs_output-status = icon_yellow_light.
      gs_output-message = 'Already Exists'.

      APPEND gs_output TO gt_output.

      CONTINUE.

    ENDIF.




    PERFORM bdc_dynpro      USING 'SAPLMGMM' '0060'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'RMMG1-MTART'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=AUSW'.
    PERFORM bdc_field       USING 'RMMG1-MBRSH'
                                  wa_record-mbrsh.
    PERFORM bdc_field       USING 'RMMG1-MTART'
                                  wa_record-mtart.
    PERFORM bdc_dynpro      USING 'SAPLMGMM' '0070'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'MSICHTAUSW-DYTXT(01)'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=ENTR'.
    PERFORM bdc_field       USING 'MSICHTAUSW-KZSEL(01)'
                                  'X'.
    PERFORM bdc_dynpro      USING 'SAPLMGMM' '4004'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=BU'.
    PERFORM bdc_field       USING 'MAKT-MAKTX'
                                  wa_record-maktx.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'MARA-MEINS'.
    PERFORM bdc_field       USING 'MARA-MEINS'
                                  wa_record-meins.

*---------------------------------------------------------------------*
* Call Transaction (Background Mode)
*---------------------------------------------------------------------*

    CALL TRANSACTION 'MM01' USING it_bdcdata MODE 'N' UPDATE 'S' MESSAGES INTO it_message.

    IF sy-subrc = 0.
      PERFORM display_success_rec.
    ELSE.
      PERFORM display_error_rec.
    ENDIF.

*---------------------------------------------------------------------*
* Clear Data
*---------------------------------------------------------------------*

    REFRESH it_bdcdata.
    REFRESH it_message.

    CLEAR wa_record.
    CLEAR wa_bdcdata.
    CLEAR wa_message.
    CLEAR lv_msg.

  ENDLOOP.

  PERFORM display_alv.

*----------------------------------------------------------------------*
*        Start new screen                                              *
*----------------------------------------------------------------------*
FORM bdc_dynpro USING program dynpro.
  CLEAR wa_bdcdata.
  wa_bdcdata-program  = program.
  wa_bdcdata-dynpro   = dynpro.
  wa_bdcdata-dynbegin = 'X'.
  APPEND wa_bdcdata TO it_bdcdata.
ENDFORM.

*----------------------------------------------------------------------*
*        Insert field                                                  *
*----------------------------------------------------------------------*
FORM bdc_field USING fnam fval.
  IF fval <> space.
    CLEAR wa_bdcdata.
    wa_bdcdata-fnam = fnam.
    wa_bdcdata-fval = fval.
    APPEND wa_bdcdata TO it_bdcdata.
  ENDIF.
ENDFORM.

*---------------------------------------------------------------------*
* Success Message
*---------------------------------------------------------------------*
FORM display_success_rec.

  DATA: wa_message TYPE bdcmsgcoll.

  READ TABLE it_message INTO wa_message
       WITH KEY msgtyp = 'S'.

  IF sy-subrc = 0.

    CALL FUNCTION 'FORMAT_MESSAGE'
      EXPORTING
        id   = wa_message-msgid
        lang = sy-langu
        no   = wa_message-msgnr
        v1   = wa_message-msgv1
        v2   = wa_message-msgv2
        v3   = wa_message-msgv3
        v4   = wa_message-msgv4
      IMPORTING
        msg  = lv_msg.

    gv_success = gv_success + 1.
    gv_srno    = gv_srno + 1.

    CLEAR gs_output.

    gs_output-srno     = gv_srno.
    gs_output-material = ''.          "MATNR agar available ho to yahan set karo
    gs_output-maktx    = wa_record-maktx.
    gs_output-status   = icon_green_light.
    gs_output-message  = lv_msg.

    APPEND gs_output TO gt_output.

  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
* Error Message
*---------------------------------------------------------------------*
*FORM display_error_rec.
*
*  DATA: wa_message TYPE bdcmsgcoll.
*
*  LOOP AT it_message INTO wa_message
*       WHERE msgtyp = 'E'
*          OR msgtyp = 'A'
*          OR msgtyp = 'X'.
*
*    CALL FUNCTION 'FORMAT_MESSAGE'
*      EXPORTING
*        id   = wa_message-msgid
*        lang = sy-langu
*        no   = wa_message-msgnr
*        v1   = wa_message-msgv1
*        v2   = wa_message-msgv2
*        v3   = wa_message-msgv3
*        v4   = wa_message-msgv4
*      IMPORTING
*        msg  = lv_msg.
*
**    WRITE:/ 'ERROR :', lv_msg.
*    gv_failed = gv_failed + 1.
*    gv_srno = gv_srno + 1.
*
*    CLEAR gs_output.
*
*    gs_output-srno = gv_srno.
*    gs_output-maktx = wa_record-maktx.
*    gs_output-status = icon_red_light.
*    gs_output-message = lv_msg.
*
*    APPEND gs_output TO gt_output.
*
*  ENDLOOP.
*
*ENDFORM.

FORM display_error_rec.

  DATA: wa_message TYPE bdcmsgcoll.

  READ TABLE it_message INTO wa_message
       WITH KEY msgtyp = 'E'.


  IF sy-subrc <> 0.
    READ TABLE it_message INTO wa_message
         WITH KEY msgtyp = 'A'.
  ENDIF.

  IF sy-subrc <> 0.
    READ TABLE it_message INTO wa_message
         WITH KEY msgtyp = 'X'.
  ENDIF.

  IF sy-subrc = 0.

    CALL FUNCTION 'FORMAT_MESSAGE'
      EXPORTING
        id   = wa_message-msgid
        lang = sy-langu
        no   = wa_message-msgnr
        v1   = wa_message-msgv1
        v2   = wa_message-msgv2
        v3   = wa_message-msgv3
        v4   = wa_message-msgv4
      IMPORTING
        msg  = lv_msg.

    gv_failed = gv_failed + 1.
    gv_srno   = gv_srno + 1.

    CLEAR gs_output.

    gs_output-srno    = gv_srno.
    gs_output-maktx   = wa_record-maktx.
    gs_output-status  = icon_red_light.
    gs_output-message = lv_msg.

    APPEND gs_output TO gt_output.

  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
* Error Message
*---------------------------------------------------------------------*
*FORM display_error_rec.
*
*  DATA: wa_message TYPE bdcmsgcoll.
*
** Read Error Message
*  READ TABLE it_message INTO wa_message
*       WITH KEY msgtyp = 'E'.
*
** If Error not found, check Abort
*  IF sy-subrc <> 0.
*    READ TABLE it_message INTO wa_message
*         WITH KEY msgtyp = 'A'.
*  ENDIF.
*
** If Abort not found, check System Error
*  IF sy-subrc <> 0.
*    READ TABLE it_message INTO wa_message
*         WITH KEY msgtyp = 'X'.
*  ENDIF.
*
** If any message found
*  IF sy-subrc = 0.
*
*    CALL FUNCTION 'FORMAT_MESSAGE'
*      EXPORTING
*        id   = wa_message-msgid
*        lang = sy-langu
*        no   = wa_message-msgnr
*        v1   = wa_message-msgv1
*        v2   = wa_message-msgv2
*        v3   = wa_message-msgv3
*        v4   = wa_message-msgv4
*      IMPORTING
*        msg  = lv_msg.
*
**--------------------------------------------------------------*
** User Friendly Messages
**--------------------------------------------------------------*
*
*    IF lv_msg CS 'MARA-MEINS'.
*      lv_msg = 'Base Unit is mandatory.'.
*
*    ELSEIF lv_msg CS 'Industry sector'.
*      lv_msg = 'Please enter Industry Sector.'.
*
*    ELSEIF lv_msg CS 'Material type'.
*      lv_msg = 'Please enter Material Type.'.
*
*    ELSEIF lv_msg CS 'already exists'.
*      lv_msg = 'Material already exists.'.
*
*    ENDIF.
*
**--------------------------------------------------------------*
** Statistics
**--------------------------------------------------------------*
*
*    gv_failed = gv_failed + 1.
*    gv_srno   = gv_srno + 1.
*
**--------------------------------------------------------------*
** ALV Output
**--------------------------------------------------------------*
*
*    CLEAR gs_output.
*
*    gs_output-srno     = gv_srno.
*    gs_output-material = ''.              "Assign MATNR if available
*    gs_output-maktx    = wa_record-maktx.
*    gs_output-status   = icon_red_light.
*    gs_output-message  = lv_msg.
*
*    APPEND gs_output TO gt_output.
*
*  ENDIF.
*
*ENDFORM.

*FORM display_alv.
*
*  WRITE:/ 'Total Records   :', gv_total.
*  WRITE:/ 'Created         :', gv_success.
*  WRITE:/ 'Already Exists  :', gv_exist.
*  WRITE:/ 'Failed          :', gv_failed.
*
*  ULINE.
*
*  LOOP AT gt_output INTO gs_output.
*
*    WRITE:/ gs_output-srno,
*            gs_output-maktx,
*            gs_output-status,
*            gs_output-message.
*
*  ENDLOOP.
*
*ENDFORM.

FORM display_alv.

  PERFORM build_fieldcat.
  PERFORM build_events.

  gs_layout-zebra = 'X'.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program     = sy-repid
      i_callback_top_of_page = 'TOP_OF_PAGE'
      is_layout              = gs_layout
      it_fieldcat            = gt_fieldcat
      it_events              = gt_events
      i_save                 = 'A'
    TABLES
      t_outtab               = gt_output
    EXCEPTIONS
      program_error          = 1
      OTHERS                 = 2.

ENDFORM.

FORM build_fieldcat.

  CLEAR gt_fieldcat.

  PERFORM add_fieldcat USING 'SRNO'
                             'Sr No'.

*  PERFORM add_fieldcat USING 'MATERIAL'
*                             'Material'.

  PERFORM add_fieldcat USING 'MAKTX'
                             'Description'.

  PERFORM add_fieldcat USING 'STATUS'
                             'Status'.

  PERFORM add_fieldcat USING 'MESSAGE'
                             'SAP Message'.

ENDFORM.

FORM add_fieldcat USING p_field
                        p_text.

  CLEAR gs_fieldcat.

  gs_fieldcat-fieldname = p_field.
  gs_fieldcat-seltext_l = p_text.
  gs_fieldcat-seltext_m = p_text.
  gs_fieldcat-seltext_s = p_text.

  IF p_field = 'STATUS'.
    gs_fieldcat-icon = 'X'.
  ENDIF.

  APPEND gs_fieldcat TO gt_fieldcat.

ENDFORM.

FORM build_events.

  CALL FUNCTION 'REUSE_ALV_EVENTS_GET'
    EXPORTING
      i_list_type = 0
    IMPORTING
      et_events   = gt_events.

  READ TABLE gt_events INTO gs_event
       WITH KEY name = slis_ev_top_of_page.

  IF sy-subrc = 0.
    gs_event-form = 'TOP_OF_PAGE'.
    MODIFY gt_events FROM gs_event INDEX sy-tabix.
  ENDIF.

ENDFORM.

FORM top_of_page.

  DATA: lt_header TYPE slis_t_listheader,
        ls_header TYPE slis_listheader.

  CLEAR ls_header.
  ls_header-typ = 'H'.
  ls_header-info = 'Material Upload Report'.
  APPEND ls_header TO lt_header.

  CLEAR ls_header.
  ls_header-typ = 'S'.
  ls_header-key = 'Total Records :'.
  ls_header-info = gv_total.
  APPEND ls_header TO lt_header.

  CLEAR ls_header.
  ls_header-typ = 'S'.
  ls_header-key = 'Created :'.
  ls_header-info = gv_success.
  APPEND ls_header TO lt_header.

  CLEAR ls_header.
  ls_header-typ = 'S'.
  ls_header-key = 'Already Exists :'.
  ls_header-info = gv_exist.
  APPEND ls_header TO lt_header.

  CLEAR ls_header.
  ls_header-typ = 'S'.
  ls_header-key = 'Failed :'.
  ls_header-info = gv_failed.
  APPEND ls_header TO lt_header.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = lt_header.

ENDFORM.
