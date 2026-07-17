*&---------------------------------------------------------------------*
*& Report Z_CUSTOMER_MASTER_REPORT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_customer_master_report.
TABLES : kna1, knb1.
TYPE-POOLS: slis.

TYPES: BEGIN OF ty_output,
         srno  TYPE i,
         bukrs TYPE knb1-bukrs, " company code
         kunnr TYPE kna1-kunnr, " customer number
         land1 TYPE kna1-land1, " language
         name1 TYPE kna1-name1, " name
         ort01 TYPE kna1-ort01, " city
         akont TYPE knb1-akont, " Recon. account
         zterm TYPE knb1-zterm, " Payt terms

       END OF ty_output.

DATA:
  gt_output TYPE TABLE OF ty_output,
  gs_output TYPE ty_output.
DATA: downloadpath TYPE string.


DATA lv_sr TYPE i.
DATA:
  gt_fieldcat TYPE slis_t_fieldcat_alv,
  gs_fieldcat TYPE slis_fieldcat_alv,

  gt_events   TYPE slis_t_event,
  gs_event    TYPE slis_alv_event.


SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-000.

PARAMETERS: p_bukrs TYPE knb1-bukrs. " comapny code

SELECT-OPTIONS: s_custno FOR kna1-kunnr, " customer number
s_lang FOR kna1-land1. " country code

PARAMETERS: p_down AS CHECKBOX. " check box

PARAMETERS: p_file TYPE localfile. " file

SELECTION-SCREEN END OF BLOCK b1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  PERFORM get_file_name.

*  SQL query write
START-OF-SELECTION.
  PERFORM get_data.
  IF gt_output IS INITIAL.
    MESSAGE 'No Data Found' TYPE 'I'.
    EXIT.
  ENDIF.

  PERFORM replace_blank.

  IF p_down = 'X'.
    PERFORM download_excel.
  ELSE.
    PERFORM display_alv.
  ENDIF.

FORM get_file_name .

  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name  = syst-cprog
      dynpro_number = syst-dynnr
      field_name    = 'p_fname'
    IMPORTING
      file_name     = p_file.
ENDFORM.


FORM get_data.

  SELECT
       b~bukrs
       a~kunnr
       a~land1
       a~name1
       a~ort01
       b~akont
       b~zterm
    FROM kna1 AS a
    INNER JOIN knb1 AS b
    ON a~kunnr = b~kunnr
*    INTO TABLE gt_output
    INTO CORRESPONDING FIELDS OF TABLE gt_output
    WHERE b~bukrs = p_bukrs AND a~kunnr IN s_custno AND a~land1 IN s_lang.

*  IF gt_output IS NOT INITIAL.
*    PERFORM replace_blank.
*    PERFORM display_alv.
*  ELSE.
*    MESSAGE 'No Data Found' TYPE 'I'.
*  ENDIF.


  CLEAR lv_sr.

  LOOP AT gt_output INTO gs_output.

    lv_sr = lv_sr + 1.
    gs_output-srno = lv_sr.

    MODIFY gt_output FROM gs_output INDEX sy-tabix.

  ENDLOOP.

ENDFORM.


FORM replace_blank.

  LOOP AT gt_output INTO gs_output.

    IF gs_output-name1 IS INITIAL.
      gs_output-name1 = 'N/A'.
    ENDIF.

    IF gs_output-ort01 IS INITIAL.
      gs_output-ort01 = 'N/A'.
    ENDIF.

    IF gs_output-land1 IS INITIAL.
      gs_output-land1 = 'N/A'.
    ENDIF.

    IF gs_output-akont IS INITIAL.
      gs_output-akont = 'N/A'.
    ENDIF.

    IF gs_output-zterm IS INITIAL.
      gs_output-zterm = 'N/A'.
    ENDIF.

    MODIFY gt_output FROM gs_output.

  ENDLOOP.

ENDFORM.

FORM download_excel.

*  downloadpath = 'C:\Users\Sumit Kumar\Documents\SAP\SAP GUI\test.txt'.
  downloadpath = 'C:\Users\Sumit Kumar\Documents\SAP\SAP GUI\d2.csv'.

  CALL FUNCTION 'GUI_DOWNLOAD' " this for txt and csv file not xlsv file
    EXPORTING
      filename              = downloadpath
      filetype              = 'ASC'
      write_field_separator = 'X'
    TABLES
      data_tab              = gt_output
    EXCEPTIONS
      OTHERS                = 1.

  IF sy-subrc = 0.
    MESSAGE 'File downloaded successfully.' TYPE 'S'.
  ELSE.
    MESSAGE 'Download failed.' TYPE 'E'.
  ENDIF.

ENDFORM.

*FORM build_fieldcat.
*
*  CLEAR gt_fieldcat.
*
*  PERFORM add_fieldcat USING 'SRNO'   'Sr No'.
*  PERFORM add_fieldcat USING 'KUNNR'  'Customer No'.
*  PERFORM add_fieldcat USING 'NAME1'  'Customer Name'.
*  PERFORM add_fieldcat USING 'ORT01'  'City'.
*  PERFORM add_fieldcat USING 'LAND1'  'Country'.
*  PERFORM add_fieldcat USING 'BUKRS'  'Company Code'.
*  PERFORM add_fieldcat USING 'AKONT'  'Recon Account'.
*  PERFORM add_fieldcat USING 'ZTERM'  'Payment Terms'.
*
*ENDFORM.
*
*FORM add_fieldcat USING p_field p_text.
*
*  CLEAR gs_fieldcat.
*
*  gs_fieldcat-fieldname = p_field.
*  gs_fieldcat-seltext_l = p_text.
*  gs_fieldcat-seltext_m = p_text.
*  gs_fieldcat-seltext_s = p_text.
*  gs_fieldcat-col_pos   = lines( gt_fieldcat ) + 1.
*
*  APPEND gs_fieldcat TO gt_fieldcat.
*
*ENDFORM.

FORM build_fieldcat.

  TYPES: BEGIN OF ty_fcat,
           fieldname TYPE slis_fieldcat_alv-fieldname,
           text      TYPE slis_fieldcat_alv-seltext_l,
         END OF ty_fcat.

  DATA:gt_fcat TYPE TABLE OF ty_fcat,
    gs_fcat TYPE ty_fcat.

  DATA: ls_fieldcat TYPE slis_fieldcat_alv.

  REFRESH gt_fcat.
  REFRESH gt_fieldcat.

  gs_fcat-fieldname = 'SRNO'.
  gs_fcat-text = 'Sr No'.
  APPEND gs_fcat TO gt_fcat.

  gs_fcat-fieldname = 'KUNNR'.
  gs_fcat-text = 'Customer No'.
  APPEND gs_fcat TO gt_fcat.

  gs_fcat-fieldname = 'NAME1'.
  gs_fcat-text = 'Customer Name'.
  APPEND gs_fcat TO gt_fcat.

  gs_fcat-fieldname = 'ORT01'.
  gs_fcat-text = 'City'.
  APPEND gs_fcat TO gt_fcat.

  gs_fcat-fieldname = 'LAND1'.
  gs_fcat-text = 'Country'.
  APPEND gs_fcat TO gt_fcat.

  gs_fcat-fieldname = 'BUKRS'.
  gs_fcat-text = 'Company Code'.
  APPEND gs_fcat TO gt_fcat.

  gs_fcat-fieldname = 'AKONT'.
  gs_fcat-text = 'Recon Account'.
  APPEND gs_fcat TO gt_fcat.

  gs_fcat-fieldname = 'ZTERM'.
  gs_fcat-text = 'Payment Terms'.
  APPEND gs_fcat TO gt_fcat.

  LOOP AT gt_fcat INTO gs_fcat.

    CLEAR ls_fieldcat.

    ls_fieldcat-fieldname = gs_fcat-fieldname.
    ls_fieldcat-seltext_l = gs_fcat-text.
    ls_fieldcat-seltext_m = gs_fcat-text.
    ls_fieldcat-seltext_s = gs_fcat-text.
    ls_fieldcat-col_pos   = sy-tabix.

    APPEND ls_fieldcat TO gt_fieldcat.

  ENDLOOP.

ENDFORM.

FORM build_events.

  CLEAR gs_event.

  gs_event-name = slis_ev_top_of_page.
  gs_event-form = 'TOP_OF_PAGE'.

  APPEND gs_event TO gt_events.

ENDFORM.

FORM top_of_page.

  DATA:
    lt_header TYPE slis_t_listheader,
    ls_header TYPE slis_listheader,
    lv_total  TYPE char10.

  lv_total = lines( gt_output ). " return total records in internal table

* Title
  CLEAR ls_header.
  ls_header-typ  = 'H'.
  ls_header-info = 'Customer Master Report'.
  APPEND ls_header TO lt_header.

* Created By
  CLEAR ls_header.
  ls_header-typ  = 'S'.
  ls_header-key  = 'Created By :'.
  ls_header-info = sy-uname.
  APPEND ls_header TO lt_header.

* Date
  CLEAR ls_header.
  ls_header-typ  = 'S'.
  ls_header-key  = 'Current Date :'.
  WRITE sy-datum TO ls_header-info.
  APPEND ls_header TO lt_header.

* Total Records
  CLEAR ls_header.
  ls_header-typ  = 'S'.
  ls_header-key  = 'Total Records :'.
  ls_header-info = lv_total.
  APPEND ls_header TO lt_header.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = lt_header.

ENDFORM.

FORM display_alv.

  PERFORM build_fieldcat.

  PERFORM build_events.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid " program name show
      it_fieldcat        = gt_fieldcat " Field Catalog pass for table header show
      it_events          = gt_events "TOP_OF_PAGE Event mean Jab ALV display hoga, TOP_OF_PAGE FORM ko call karna.
      i_save             = 'A' "Layout Save
    TABLES
      t_outtab           = gt_output "ALV Data
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.

  IF sy-subrc <> 0.
    MESSAGE 'Error while displaying ALV' TYPE 'E'.
  ENDIF.

ENDFORM.
