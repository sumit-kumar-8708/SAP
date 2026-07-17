*&---------------------------------------------------------------------*
*& Report Z_CUSTOMER_MASTER_REPORT_1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_CUSTOMER_MASTER_REPORT_1.

TABLES : kna1, knb1.

TYPES: BEGIN OF ty_output,
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





ENDFORM.

FORM display_alv.

  DATA: go_alv TYPE REF TO cl_salv_table.

  TRY.

      cl_salv_table=>factory(

        IMPORTING
          r_salv_table = go_alv

        CHANGING
          t_table = gt_output ).

      go_alv->get_functions( )->set_all( abap_true ).

      go_alv->get_columns( )->set_optimize( ).

      go_alv->display( ).

    CATCH cx_salv_msg.
      MESSAGE 'Error while displaying ALV' TYPE 'E'.

  ENDTRY.

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
