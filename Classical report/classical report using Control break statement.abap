*&---------------------------------------------------------------------*
*& Report ZABAP_GUI
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZABAP_GUI.


*Declaring the line type of database table

TABLES: mara.

*------Declaring the local types for Internal table & Work area--------*

TYPES: BEGIN OF ty_mara,
        matnr TYPE mara-matnr, "Material No.
        ersda TYPE mara-ersda, "Creation Data
        ernam TYPE mara-ernam, "Created By
        mtart TYPE mara-mtart, "Material Type
        matkl TYPE mara-matkl, "Material Group
       END OF ty_mara.

*-----Declaring the Internal table & work area-------------------------*

DATA: wa_mara TYPE ty_mara,
      it_mara TYPE STANDARD TABLE OF ty_mara,
      v_repid TYPE sy-repid, "Program name
      v_date  TYPE sy-datum, "Current date
      v_user  TYPE sy-uname. "User name

*-------------Event initialization-------------------------------------*
INITIALIZATION.
  v_repid = sy-repid.
  v_date  = sy-datum.
  v_user  = sy-uname.

*-Declaring the selection screen & select option for input-------------*
  SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
  SELECT-OPTIONS   s_matnr FOR mara-matnr OBLIGATORY.
  SELECTION-SCREEN END OF BLOCK b1.

*-----Event start of selection-----------------------------------------*
START-OF-SELECTION.
  PERFORM get_mara.

*---Event end of selection---------------------------------------------*
END-OF-SELECTION.
  PERFORM get_output.

*---Event top of page--------------------------------------------------*
TOP-OF-PAGE.
  PERFORM top_page.
*&---------------------------------------------------------------------*
*&      Form  get_mara
*&---------------------------------------------------------------------*
*       Select data from MARA table
*----------------------------------------------------------------------*
FORM get_mara .

  SELECT matnr ersda ernam mtart matkl
  FROM mara INTO TABLE it_mara
  WHERE matnr IN s_matnr.

  IF sy-subrc <> 0.
    MESSAGE 'Material Doesn''t Exist.' TYPE 'I'.
    LEAVE LIST-PROCESSING.
  ENDIF.

ENDFORM.                    " get_mara
*&---------------------------------------------------------------------*
*&      Form  get_output
*&---------------------------------------------------------------------*
*       Preparing the classical output with WRITE statement
*----------------------------------------------------------------------*
FORM get_output .

  IF it_mara IS NOT INITIAL.
    LOOP AT it_mara INTO wa_mara.

      "Control break statement – it will display one time at first line
      AT FIRST.
        WRITE: /3 'Material No.',
               25 'Created By',
               40 'Group',
               55 'Type',
               70 'Creation Date'.
        ULINE.
        SKIP.
      ENDAT.

      WRITE: /  wa_mara-matnr,
             25 wa_mara-ernam,
             40 wa_mara-matkl,
             55 wa_mara-mtart,
             70 wa_mara-ersda.

      "Control break statement – it will display one time at last line
      AT LAST.
        ULINE.
        WRITE: /15 '~~End of Material Display~~'.
      ENDAT.

    ENDLOOP.
  ENDIF.

ENDFORM.                    " get_output
*&---------------------------------------------------------------------*
*&      Form  top_page
*&---------------------------------------------------------------------*
*       Top pf page to display top information
*----------------------------------------------------------------------*
FORM top_page .

  WRITE: / 'Material Details',
         / 'Date: ',   12 v_date DD/MM/YYYY,
         / 'User: ',   12 v_user,
         / 'Report: ', 12 v_repid.
  ULINE.
  SKIP.

ENDFORM.                    " top_page
