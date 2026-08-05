*
*                     ---------Exercise 6-----------------
*Create a report which takes two date and time and calls the RFC to calculate the difference between the two dates.
*The difference should be in no. of days and no of hours.
*The input to the report is provided from a txt file and displays the output using ALV.

REPORT z_task_assignment_0701.

TYPE-POOLS: slis.

DATA: gt_fieldcat TYPE slis_t_fieldcat_alv,
      gs_fieldcat TYPE slis_fieldcat_alv.
DATA: gt_listheader TYPE slis_t_listheader,
      gs_listheader TYPE slis_listheader.

*---------------------------------------------------------------------*
* Types
*--------Ye SAP ka internal date (YYYYMMDD) aur internal time (HHMMSS) format hai---------------------------------------------*
TYPES: BEGIN OF ty_record,
         date TYPE d, " YYYYMMDD
         time TYPE t, " HHMMSS
       END OF ty_record.

TYPES: BEGIN OF ty_final,
         no_of_date TYPE string,
         no_of_time TYPE string,
       END OF ty_final.

*---------------------------------------------------------------------*
* Data
*---------------------------------------------------------------------*
DATA: gt_record TYPE TABLE OF ty_record,
      gs_record TYPE ty_record.
DATA: gt_final TYPE TABLE OF ty_final,
      gs_final TYPE ty_final.

DATA: gv_date1 TYPE d,
      gv_time1 TYPE t,
      gv_date2 TYPE d,
      gv_time2 TYPE t.

DATA: gv_datediff TYPE p,
      gv_timediff TYPE p,
      gv_earliest TYPE c.

DATA: gv_file TYPE string.

*---------------------------------------------------------------------*
* Start of Selection
*---------------------------------------------------------------------*
START-OF-SELECTION.

  gv_file = 'C:\Users\Sumit Kumar\Desktop\SAP-ABAP HANA\Project\date_time.txt'.

*---------------------------------------------------------------------*
* Upload File
*---------------------------------------------------------------------*
  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = gv_file
      has_field_separator     = 'X'
    TABLES
      data_tab                = gt_record
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
    WRITE: / 'Error while uploading file'.
    STOP.
  ENDIF.

*---------------------------------------------------------------------*
* Check Records
*---------------------------------------------------------------------*
  IF lines( gt_record ) < 2.
    WRITE: / 'File must contain at least 2 records'.
    STOP.
  ENDIF.

*---------------------------------------------------------------------*
* Read First Record
*---------------------------------------------------------------------*
  READ TABLE gt_record INTO gs_record INDEX 1.

  gv_date1 = gs_record-date.
  gv_time1 = gs_record-time.

*---------------------------------------------------------------------*
* Read Second Record
*---------------------------------------------------------------------*
  READ TABLE gt_record INTO gs_record INDEX 2.

  gv_date2 = gs_record-date.
  gv_time2 = gs_record-time.

*---------------------------------------------------------------------*
* Display Input
*---------------------------------------------------------------------*
*  WRITE: / 'First Date :', gv_date1.
*  WRITE: / 'First Time :', gv_time1.
*
*  WRITE: /.
*
*  WRITE: / 'Second Date:', gv_date2.
*  WRITE: / 'Second Time:', gv_time2.

*---------------------------------------------------------------------*
* Calculate Difference
*---------------------------------------------------------------------*
  CALL FUNCTION 'SD_DATETIME_DIFFERENCE'
    EXPORTING
      date1            = gv_date1
      time1            = gv_time1
      date2            = gv_date2
      time2            = gv_time2
    IMPORTING
      datediff         = gv_datediff
      timediff         = gv_timediff
      earliest         = gv_earliest
    EXCEPTIONS
      invalid_datetime = 1
      OTHERS           = 2.

  IF sy-subrc <> 0.
    WRITE: /.
    WRITE: / 'Error while calling SD_DATETIME_DIFFERENCE'.
    STOP.
  ENDIF.

*---------------------------------------------------------------------*
* Output
*---------------------------------------------------------------------*
  gs_final-no_of_date = gv_datediff.
  gs_final-no_of_time = gv_timediff.
  APPEND gs_final to gt_final.
  CLEAR gs_final.

  PERFORM build_fieldcat.
  PERFORM display_alv.
*  WRITE: /.
*  WRITE: / '============================='.
*  WRITE: / 'Date Difference :', gv_datediff.
*  WRITE: / 'Time Difference :', gv_timediff.
*  WRITE: / 'Earliest        :', gv_earliest.
*  WRITE: / '============================='.



FORM build_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = 'no_of_date'.
  gs_fieldcat-seltext_m = 'No. of days'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = 'no_of_time'.
  gs_fieldcat-seltext_m = 'No. of Times'.
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
      i_callback_user_command = '' " ALV me user ke click ko handle karne ke liye
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
      t_outtab                = gt_final "ALV Data
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
  gs_listheader-info = 'Calculate Date and time differece b/w Two date and time'.
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
