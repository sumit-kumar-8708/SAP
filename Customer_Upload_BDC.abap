REPORT ztestbdcp_cust_file
       NO STANDARD PAGE HEADING LINE-SIZE 255.


TYPES: BEGIN OF record,

         ktokd TYPE ktokd,        "Customer Account Group
         anred TYPE anred,        "Title
         name1 TYPE name1_gp,     "Name 1
         land1 TYPE land1_gp,     "Country
         regio TYPE regio,        "Region
         spras TYPE spras,        "Language Key
         civve TYPE civve,        "Civil Status

       END OF record.
*
*** End generated data section ***
*
DATA: it_record TYPE TABLE OF record,
      wa_record TYPE record.
DATA: it_bdcdata TYPE TABLE OF bdcdata,
      wa_bdcdata TYPE bdcdata.
DATA: it_message TYPE TABLE OF bdcmsgcoll.


PARAMETERS:
  p_file TYPE localfile.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
      program_name  = syst-cprog
      dynpro_number = syst-dynnr
      field_name    = ' '
    IMPORTING
      file_name     = p_file.

START-OF-SELECTION.

  DATA: lv_file TYPE string.
  lv_file = p_file.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = lv_file
*     filetype                = 'ASC'    " File Type (ASC or BIN)
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


  LOOP AT it_record INTO wa_record.

    PERFORM bdc_dynpro      USING 'SAPMF02D' '0100'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'RF02D-KTOKD'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM bdc_field       USING 'RF02D-KTOKD'
                                  wa_record-ktokd.
    PERFORM bdc_dynpro      USING 'SAPMF02D' '0110'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'KNA1-SPRAS'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM bdc_field       USING 'KNA1-ANRED'
                                  wa_record-anred.
    PERFORM bdc_field       USING 'KNA1-NAME1'
                                  wa_record-name1.
    PERFORM bdc_field       USING 'KNA1-LAND1'
                                  wa_record-land1.
    PERFORM bdc_field       USING 'KNA1-REGIO'
                                  wa_record-regio.
    PERFORM bdc_field       USING 'KNA1-SPRAS'
                                  wa_record-spras.
    PERFORM bdc_dynpro      USING 'SAPMF02D' '0120'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'KNA1-LIFNR'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM bdc_dynpro      USING 'SAPMF02D' '0125'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'KNA1-NIELS'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '/00'.
    PERFORM bdc_dynpro      USING 'SAPMF02D' '0130'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'KNBK-BANKS(01)'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=ENTR'.
    PERFORM bdc_dynpro      USING 'SAPMF02D' '0340'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'KNVA-ABLAD(01)'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=ENTR'.
    PERFORM bdc_dynpro      USING 'SAPMF02D' '0370'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'KNEX-LNDEX(01)'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=ENTR'.
    PERFORM bdc_field       USING 'KNA1-CIVVE'
                                  wa_record-civve.
    PERFORM bdc_dynpro      USING 'SAPMF02D' '0360'.
    PERFORM bdc_field       USING 'BDC_CURSOR'
                                  'KNVK-NAMEV(01)'.
    PERFORM bdc_field       USING 'BDC_OKCODE'
                                  '=ENTR'.

    CALL TRANSACTION 'XD01' USING it_bdcdata MODE 'A' UPDATE 'S' MESSAGES INTO it_message.
    CLEAR it_bdcdata.

  ENDLOOP.

  cl_demo_output=>display( it_message ).

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
*  IF fval <> nodata.
  CLEAR wa_bdcdata.
  wa_bdcdata-fnam = fnam.
  wa_bdcdata-fval = fval.
  APPEND wa_bdcdata TO it_bdcdata.
*  ENDIF.
ENDFORM.
