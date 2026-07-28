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
