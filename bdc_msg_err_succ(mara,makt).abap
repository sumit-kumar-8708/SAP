REPORT z_rec_mat_6
       NO STANDARD PAGE HEADING LINE-SIZE 255.

TYPES: BEGIN OF record,

         mbrsh TYPE mara-mbrsh,
         mtart TYPE mara-mtart,
         maktx TYPE makt-maktx,
         meins TYPE mara-meins,

       END OF record.

DATA: it_record TYPE TABLE OF record,
      wa_record TYPE record.
DATA: lv_msg TYPE string.

DATA: it_bdcdata TYPE TABLE OF bdcdata,
      wa_bdcdata TYPE bdcdata.
DATA: it_message TYPE TABLE OF bdcmsgcoll,
      wa_message TYPE bdcmsgcoll.

"Duplicate Validation
DATA: lv_maktx TYPE makt-maktx.

CALL FUNCTION 'GUI_UPLOAD'
  EXPORTING
    filename                = 'C:\Users\Sumit Kumar\Desktop\SAP-ABAP HANA\rec_3.txt'
    filetype                = 'ASC'    " File Type (ASC or BIN)
    has_field_separator     = 'X'    " Columns Separated by Tabs in Case of ASCII Upload
*   header_length           = 0    " Length of Header for Binary Data
*   read_by_line            = 'X'    " The file will be written to the internal table line-by-line
*   dat_mode                = SPACE    " Numeric and Date Fields Imported in ws_download 'DAT' Format
*   codepage                =     " Character Representation for Output
*   ignore_cerr             = ABAP_TRUE    " Specifies whether to ignore errors converting character sets
*   replacement             = '#'    " Replacement Character for Non-Convertible Characters
*   check_bom               = SPACE    " The consistency of the codepage and byte order mark will be
*   virus_scan_profile      =     " Virus Scan Profile
*   no_auth_check           = SPACE    " Switch off Check for Access Rights
*    IMPORTING
*   filelength              =     " File Length
*   header                  =     " File Header in Case of Binary Upload
  TABLES
    data_tab                = it_record
*    CHANGING
*   isscanperformed         = SPACE    " File already scanned
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

*  Duplicate Validation
  CLEAR lv_maktx.

  SELECT SINGLE maktx
    INTO lv_maktx
    FROM makt
    WHERE maktx = wa_record-maktx
      AND spras = sy-langu.

  IF sy-subrc = 0.
    WRITE:/ 'Duplicate Record Found :', wa_record-maktx.
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

    WRITE:/ 'SUCCESS :', lv_msg.

  ENDIF.

ENDFORM.

*---------------------------------------------------------------------*
* Error Message
*---------------------------------------------------------------------*
FORM display_error_rec.

  DATA: wa_message TYPE bdcmsgcoll.

  LOOP AT it_message INTO wa_message
       WHERE msgtyp = 'E'
          OR msgtyp = 'A'
          OR msgtyp = 'X'.

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

    WRITE:/ 'ERROR :', lv_msg.

  ENDLOOP.

ENDFORM.
