*&---------------------------------------------------------------------*
*& Report Z_ALL_EVENT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
*REPORT z_all_event.
REPORT z_all_event NO STANDARD PAGE HEADING LINE-COUNT 34(3).

TYPES: BEGIN OF ty_kna1,
         kunnr TYPE kna1-kunnr,
         land1 TYPE kna1-land1,
         name1 TYPE kna1-name1,
         ort01 TYPE kna1-ort01,
       END OF ty_kna1.

DATA: i_kna1 TYPE TABLE OF ty_kna1.
DATA: wa_kna1 TYPE ty_kna1.
DATA: v_title(25) TYPE c.
DATA: v_land1 TYPE kna1-land1.
DATA: v_fname TYPE string.

*************** SELECTION SCREEN ****************

PARAMETERS: p_land1 TYPE kna1-land1.
PARAMETERS: p_fname TYPE rlgrap-filename.
PARAMETERS: p_dload AS CHECKBOX.

INITIALIZATION.
  PERFORM init_varibales.

*AT SELECTION-SCREEN OUTPUT.

AT SELECTION-SCREEN ON p_land1.
  PERFORM validate_land1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_fname.
  PERFORM get_file_name.

AT SELECTION-SCREEN ON HELP-REQUEST FOR p_fname.
  PERFORM get_help.

*AT SELECTION-SCREEN.

START-OF-SELECTION.
  PERFORM gest_data.

END-OF-SELECTION.

  IF p_dload = 'X'.
    PERFORM download_data.
  ENDIF.

  PERFORM display_data.

TOP-OF-PAGE.
  PERFORM display_heading.

END-OF-PAGE.
  PERFORM display_footer.

*---------------------------------------------------------------------*
* Form INIT_VARIBALES
*---------------------------------------------------------------------*
FORM init_varibales.

  v_title = 'CUSTOMER MASTER REPORT'.
  p_land1 = 'IN'.

ENDFORM.

*---------------------------------------------------------------------*
* Form VALIDATE_LAND1
*---------------------------------------------------------------------*
FORM validate_land1.

  SELECT land1
    FROM kna1
    INTO v_land1
    UP TO 1 ROWS
    WHERE land1 = p_land1.
  ENDSELECT.

*  MESSAGE |V_LAND1 = { v_land1 }| TYPE 'I'. " check for data receive or not in v_land1

  IF sy-subrc <> 0.
    MESSAGE 'INVALID COUNTRY CODE' TYPE 'E'.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
* Form GET_FILE_NAME
*---------------------------------------------------------------------*
FORM get_file_name.

  CALL FUNCTION 'KD_GET_FILENAME_ON_F4'
    EXPORTING
      program_name  = syst-repid
      dynpro_number = syst-dynnr
      field_name    = 'P_FNAME'
    CHANGING
      file_name     = p_fname.

  IF sy-subrc <> 0.
  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
* Form GEST_DATA
*---------------------------------------------------------------------*
FORM gest_data.

  SELECT kunnr
         land1
         name1
         ort01
    FROM kna1
    INTO TABLE i_kna1
    WHERE land1 = p_land1.

  IF sy-subrc <> 0.
    MESSAGE 'NO DATA FOUND' TYPE 'I'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GET_HELP
*&---------------------------------------------------------------------*

FORM get_help .

  MESSAGE 'Please Click on F4 Help For File Name' TYPE 'I'.

ENDFORM.

FORM download_data.

  v_fname = p_fname.

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename              = v_fname      " C:\KNA1.TXT
      filetype              = 'ASC'        " ASC = Notepad File
      write_field_separator = 'X'
    TABLES
      data_tab              = i_kna1.

  IF sy-subrc = 0.
    MESSAGE 'DATA IS SUCCESSFULLY DOWNLOADED' TYPE 'I'.
  ENDIF.

ENDFORM.

FORM display_data.

  LOOP AT i_kna1 INTO wa_kna1.

    WRITE : / wa_kna1-kunnr,
              wa_kna1-land1,
              wa_kna1-name1,
              wa_kna1-ort01.

  ENDLOOP.

ENDFORM.

*---------------------------------------------------------------------*
* Form DISPLAY_HEADING
*---------------------------------------------------------------------*
FORM display_heading.

  WRITE : / sy-uline.
  WRITE : /45 v_title COLOR 5.
  WRITE : / sy-uline.

ENDFORM.

FORM display_footer.

  WRITE : / sy-uline.
  WRITE : /45 'I am a footer' COLOR 5.
  WRITE : / sy-uline.

ENDFORM.
