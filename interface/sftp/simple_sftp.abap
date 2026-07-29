
*&------------------Flow---------------------------------------------------*
*Application Server File
*↓
*OPEN DATASET
*↓
*READ DATASET
*↓
*gt_file
*↓
*SPLIT
*↓
*Internal Table
*↓
*Validation
*↓
*Duplicate Check
*↓
*Insert data in Database
*↓
*Error Log
*↓
*ALV Report


REPORT zemp_master_salary_sftp.

** Step 1: Dummy data save on AL11 server though SFTP
*TYPES: BEGIN OF structure,
*         " ZHREMPMASTER Table
*         zemp_id_test   TYPE zemp_id_test,
*         zemp_name_test TYPE zemp_name_test,
*         zemp_add       TYPE zemp_add,
*         zemp_mobile    TYPE zemp_mobile,
*         " ZHREMPDET Table
*         zde_emp_sal    TYPE zde_emp_sal,
*         zde_emp_email  TYPE zde_emp_email,
*       END OF structure.
*
*DATA: it_structure TYPE TABLE OF structure,
*      wa_structure TYPE          structure.
*
*wa_structure-zemp_id_test = '101'.
*wa_structure-zemp_name_test = 'Raw1'.
*wa_structure-zemp_add  = 'add1'.
*wa_structure-zemp_mobile = '9636963691'.
*wa_structure-zde_emp_sal = '10000'.
*wa_structure-zde_emp_email = 'raw1@gmail.com'.
*APPEND wa_structure TO it_structure.
*
*CLEAR wa_structure.
*wa_structure-zemp_id_test = '102'.
*wa_structure-zemp_name_test = 'Raw2'.
*wa_structure-zemp_add  = 'add2'.
*wa_structure-zemp_mobile = '9636963692'.
*wa_structure-zde_emp_sal = '20000'.
*wa_structure-zde_emp_email = 'raw2@gmail.com'.
*APPEND wa_structure TO it_structure.
*
*CLEAR wa_structure.
*wa_structure-zemp_id_test = '103'.
*wa_structure-zemp_name_test = 'Raw3'.
*wa_structure-zemp_add  = 'add3'.
*wa_structure-zemp_mobile = '9636963693'.
*wa_structure-zde_emp_sal = '30000'.
*wa_structure-zde_emp_email = 'raw3@gmail.com'.
*APPEND wa_structure TO it_structure.
*CLEAR wa_structure.
*
*
*PERFORM send_to_as.
*
*FORM send_to_as .
*  DATA : file_path   TYPE string,
*         string_line TYPE string.
*
*  file_path = 'E:\usr\sap\TEC\D00\data\test_28_july.txt'. " You can get this path from the AL11 screen
*  OPEN DATASET file_path FOR OUTPUT IN TEXT MODE ENCODING DEFAULT. " OUTPUT MODE => means opening the file in Write mode.
*  IF sy-subrc IS INITIAL.
*    LOOP AT it_structure INTO DATA(wa).
*      CONCATENATE
*       wa-zemp_id_test
*       wa-zemp_name_test
*       wa-zemp_add
*       wa-zemp_mobile
*       wa-zde_emp_sal
*       wa-zde_emp_email
*     INTO string_line
*     SEPARATED BY '|'.
*      TRANSFER string_line TO file_path.
*    ENDLOOP.
*    MESSAGE 'file has been created in AS' TYPE 'S'.
*  ELSE.
*    MESSAGE 'error in opening the file' TYPE 'E'.
*
*  ENDIF.
*  CLOSE DATASET file_path.
*ENDFORM.

* Step 2: Data get from AL11 server using SFTP

TYPES: BEGIN OF zemp,
         " ZHREMPMASTER Table
         zemp_id_test   TYPE zemp_id_test,
         zemp_name_test TYPE zemp_name_test,
         zemp_add       TYPE zemp_add,
         zemp_mobile    TYPE zemp_mobile,
         " ZHREMPDET Table
         zde_emp_sal    TYPE zde_emp_sal,
         zde_emp_email  TYPE zde_emp_email,
       END OF zemp.

TYPES: BEGIN OF ty_error,
         emp_id  TYPE zemp_id_test,
         message TYPE char100,
       END OF ty_error.

TYPE-POOLS: slis.
DATA: gt_fieldcat TYPE slis_t_fieldcat_alv,
      gs_fieldcat TYPE slis_fieldcat_alv.
DATA: gt_listheader TYPE slis_t_listheader,
      gs_listheader TYPE slis_listheader.

DATA: lt_error TYPE TABLE OF ty_error,
      lv_error TYPE ty_error.

DATA: ls_master TYPE zhrempmaster,
      ls_det    TYPE zhrempdet.

" Split data store
DATA: lt_data TYPE TABLE OF zemp,
      ls_data TYPE zemp.


DATA: lt_success TYPE TABLE OF zemp,
      ls_success TYPE zemp.

DATA: lv_file TYPE string,
      lv_line TYPE string.

DATA: gt_file TYPE TABLE OF string,
      gw_file TYPE string.

PERFORM read_from_as.
PERFORM build_fieldcat.
PERFORM display_alv.

FORM read_from_as.

*  DATA: lt_error TYPE TABLE OF string,
*        lv_error TYPE string.

  lv_file = 'E:\usr\sap\TEC\D00\data\test_28_july.txt'. " You can get this path from the AL11 screen

  OPEN DATASET lv_file FOR INPUT IN TEXT MODE ENCODING DEFAULT. " INPUT MODE => means opening the file in Read mode.

  IF sy-subrc <> 0.
    MESSAGE 'Unable to open file' TYPE 'E'.
  ENDIF.

  DO.

    CLEAR lv_line.

    READ DATASET lv_file INTO lv_line.

    IF sy-subrc <> 0.
      EXIT.
    ENDIF.

    APPEND lv_line TO gt_file.

  ENDDO.

  CLOSE DATASET lv_file.

*  LOOP AT gt_file INTO gw_file.
*
*    SPLIT gw_file AT '|'
*    INTO ls_data-zemp_id_test
*         ls_data-zemp_name_test
*         ls_data-zemp_add
*         ls_data-zemp_mobile
*         ls_data-zde_emp_sal
*         ls_data-zde_emp_email .
*
*    "  Mandatory Field Validation
*    IF ls_data-zemp_id_test IS INITIAL.
*
*      CONCATENATE 'EMP_ID Missing :' gw_file
*      INTO lv_error SEPARATED BY space.
*
*      APPEND lv_error TO lt_error.
*      CONTINUE.
*
*    ENDIF.
*
*    APPEND ls_data TO lt_data.
*    CLEAR ls_data.
*
*  ENDLOOP.

  LOOP AT gt_file INTO gw_file.

    CLEAR: ls_data,
           ls_master,
           ls_det,
           lv_error.

    SPLIT gw_file AT '|'
      INTO ls_data-zemp_id_test
           ls_data-zemp_name_test
           ls_data-zemp_add
           ls_data-zemp_mobile
           ls_data-zde_emp_sal
           ls_data-zde_emp_email.

* Mandatory Validation
    IF ls_data-zemp_id_test IS INITIAL.

*      CONCATENATE 'EMP_ID Missing :' gw_file
*             INTO lv_error SEPARATED BY space.
*

      lv_error-emp_id  = ls_data-zemp_id_test.
      lv_error-message = 'EMP_ID Missing'.

      APPEND lv_error TO lt_error.
      CONTINUE.

    ENDIF.

* Duplicate Check
    SELECT SINGLE emp_id
      FROM zhrempmaster
      INTO @DATA(lv_empid)
     WHERE emp_id = @ls_data-zemp_id_test.

    IF sy-subrc = 0.

*      CONCATENATE 'Duplicate Employee :'
*                  ls_data-zemp_id_test
*             INTO lv_error SEPARATED BY space.
*

      lv_error-emp_id  = ls_data-zemp_id_test.
      lv_error-message = 'Duplicate Employee'.

      APPEND lv_error TO lt_error.
      CONTINUE.

    ENDIF.

* Insert In zhrempmaster Table
    ls_master-emp_id     = ls_data-zemp_id_test.
    ls_master-emp_name   = ls_data-zemp_name_test.
    ls_master-emp_add    = ls_data-zemp_add.
    ls_master-emp_mobile = ls_data-zemp_mobile.

    INSERT zhrempmaster FROM ls_master.

    IF sy-subrc <> 0.

*      CONCATENATE 'Master Insert Failed :'
*                  ls_data-zemp_id_test
*             INTO lv_error SEPARATED BY space.
*

      lv_error-emp_id  = ls_data-zemp_id_test.
      lv_error-message = 'Master Insert Failed'.

      APPEND lv_error TO lt_error.
      CONTINUE.

    ENDIF.

* Insert In zhrempdet Table
    ls_det-emp_id    = ls_data-zemp_id_test.
    ls_det-emp_name  = ls_data-zemp_name_test.
    ls_det-emp_sal   = ls_data-zde_emp_sal.
    ls_det-emp_email = ls_data-zde_emp_email.

    INSERT zhrempdet FROM ls_det.

    IF sy-subrc <> 0.

*      CONCATENATE 'Detail Insert Failed :'
*                  ls_data-zemp_id_test
*             INTO lv_error SEPARATED BY space.

      lv_error-emp_id  = ls_data-zemp_id_test.
      lv_error-message = 'Detail Insert Failed'.

      APPEND lv_error TO lt_error.
      CONTINUE.

    ENDIF.

    APPEND ls_data TO lt_success.

  ENDLOOP.

  IF lt_success IS NOT INITIAL.
    COMMIT WORK.
  ENDIF.

*  DATA:
*  lv_total   TYPE i,
*  lv_success TYPE i,
*  lv_failed  TYPE i.
*
*lv_total   = lines( gt_file ).
*lv_success = lines( lt_success ).
*lv_failed  = lines( lt_error ).
*
*WRITE: / 'Total Records   :', lv_total.
*WRITE: / 'Success Records :', lv_success.
*WRITE: / 'Failed Records  :', lv_failed.

ENDFORM.

FORM build_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = 'emp_id'.
  gs_fieldcat-seltext_m = 'Emp ID'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.
  gs_fieldcat-fieldname = 'message'.
  gs_fieldcat-seltext_m = 'Message'.
  APPEND gs_fieldcat TO gt_fieldcat.

  CLEAR gs_fieldcat.

ENDFORM.


FORM display_alv.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program     = sy-repid " program name show
*      i_callback_pf_status_set = 'SET_PF_STATUS'
*     i_callback_user_command = 'USER_COMMAND' " ALV me user ke click ko handle karne ke liye
      i_callback_top_of_page = 'TOP_OF_PAGE'
      it_fieldcat            = gt_fieldcat " Field Catalog pass for table header show
      i_save                 = 'A'
    TABLES
      t_outtab               = lt_error
    EXCEPTIONS
      program_error          = 1
      OTHERS                 = 2.
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
  gs_listheader-info = 'Error Report'.
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

  CONCATENATE sy-datum+6(2) sy-datum+4(2) sy-datum+0(4) INTO date_string SEPARATED BY '-'.

  gs_listheader-typ  = 'S'.
  gs_listheader-key  = 'Date'.
  gs_listheader-info = date_string.
  APPEND gs_listheader TO gt_listheader.

  " Total Records
  CLEAR gs_listheader.
  gs_listheader-typ  = 'S'.
  gs_listheader-key  = 'Total Records'.
  gs_listheader-info = lines( gt_file ).
  APPEND gs_listheader TO gt_listheader.

  " Total Success
  CLEAR gs_listheader.
  gs_listheader-typ  = 'S'.
  gs_listheader-key  = 'Total Success'.
  gs_listheader-info = lines( lt_success ).
  APPEND gs_listheader TO gt_listheader.

  " Total Errors
  CLEAR gs_listheader.
  gs_listheader-typ  = 'S'.
  gs_listheader-key  = 'Total Errors'.
  gs_listheader-info = lines( lt_error ).
  APPEND gs_listheader TO gt_listheader.

  CLEAR gs_listheader.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = gt_listheader.

ENDFORM.
