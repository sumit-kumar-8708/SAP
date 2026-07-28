perform send_to_as.

FORM send_to_as .

* Variable declare kiya file path store karne ke liye
  DATA: file_path TYPE string.

* Application Server par file ka path assign kiya
  file_path = 'E:\usr\sap\TEC\D00\data\test_2607.txt'. " You can get this path from the AL11 screen

* Application Server par nayi file create/open kar rahe hain
* FOR OUTPUT = File me data write karna
* TEXT MODE = Text format me file create hogi
* ENCODING DEFAULT = System default encoding use hogi
OPEN DATASET file_path FOR OUTPUT IN TEXT MODE ENCODING DEFAULT. " OUTPUT MODE => means opening the file in Write mode.

* Check ki file successfully open hui ya nahi
  IF sy-subrc IS INITIAL.

* Internal Table GT_VBAK ke har record ko read karna
    LOOP AT gt_vbak INTO DATA(wa).

* Current record ko Application Server ki file me write karna
      TRANSFER wa TO file_path.

    ENDLOOP.

* Success Message
    MESSAGE 'File has been created in Application Server'
            TYPE 'S'.

  ELSE.

* Agar file open nahi hui to error message
    MESSAGE 'Error in opening the file'
            TYPE 'E'.

  ENDIF.

* File ko close karna (Mandatory)
  CLOSE DATASET file_path.

ENDFORM.


" second option dummy data set and sent and concatenate by '|'

REPORT zemp_master_salary_sftp.

TYPES: BEGIN OF structure,
         " ZHREMPMASTER Table
         zemp_id_test   TYPE zemp_id_test,
         zemp_name_test TYPE zemp_name_test,
         zemp_add       TYPE zemp_add,
         zemp_mobile    TYPE zemp_mobile,
         " ZHREMPDET Table
         zde_emp_sal    TYPE zde_emp_sal,
         zde_emp_email  TYPE zde_emp_email,
       END OF structure.

DATA: it_structure TYPE TABLE OF structure,
      wa_structure TYPE          structure.

wa_structure-zemp_id_test = '101'.
wa_structure-zemp_name_test = 'Raw1'.
wa_structure-zemp_add  = 'add1'.
wa_structure-zemp_mobile = '9636963691'.
wa_structure-zde_emp_sal = '10000'.
wa_structure-zde_emp_email = 'raw1@gmail.com'.
APPEND wa_structure TO it_structure.

CLEAR wa_structure.
wa_structure-zemp_id_test = '102'.
wa_structure-zemp_name_test = 'Raw2'.
wa_structure-zemp_add  = 'add2'.
wa_structure-zemp_mobile = '9636963692'.
wa_structure-zde_emp_sal = '20000'.
wa_structure-zde_emp_email = 'raw2@gmail.com'.
APPEND wa_structure TO it_structure.

CLEAR wa_structure.
wa_structure-zemp_id_test = '103'.
wa_structure-zemp_name_test = 'Raw3'.
wa_structure-zemp_add  = 'add3'.
wa_structure-zemp_mobile = '9636963693'.
wa_structure-zde_emp_sal = '30000'.
wa_structure-zde_emp_email = 'raw3@gmail.com'.
APPEND wa_structure TO it_structure.
CLEAR wa_structure.


PERFORM send_to_as.

FORM send_to_as .
  DATA : file_path   TYPE string,
         string_line TYPE string.

  file_path = 'E:\usr\sap\TEC\D00\data\test_28_july.txt'. " You can get this path from the AL11 screen
  OPEN DATASET file_path FOR OUTPUT IN TEXT MODE ENCODING DEFAULT. " OUTPUT MODE => means opening the file in Write mode.
  IF sy-subrc IS INITIAL.
    LOOP AT it_structure INTO DATA(wa).
      CONCATENATE
       wa-zemp_id_test
       wa-zemp_name_test
       wa-zemp_add
       wa-zemp_mobile
       wa-zde_emp_sal
       wa-zde_emp_email
     INTO string_line
     SEPARATED BY '|'.
      TRANSFER string_line TO file_path.
    ENDLOOP.
    MESSAGE 'file has been created in AS' TYPE 'S'.
  ELSE.
    MESSAGE 'error in opening the file' TYPE 'E'.

  ENDIF.
  CLOSE DATASET file_path.
ENDFORM.
