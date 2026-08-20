*&---------------------------------------------------------------------*
*& Report ZDRIVER_SALES_ORDER_3_MAIL
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zdriver_sales_order_3_mail.

PARAMETERS p_vbeln TYPE vbeln_va.

*---------------------------------------------------------------------*
* DATA
*---------------------------------------------------------------------*

DATA:
  wa_vbak      TYPE vbak,
  it_vbap      TYPE STANDARD TABLE OF vbap,
  wa_vbap      TYPE vbap,
  dynamic_logo TYPE sychar20,
  lv_fm        TYPE rs38l_fnam.

DATA:
  total_net_price TYPE netwr_ap VALUE 0.

*---------------------------------------------------------------------*
* SMART FORM CONTROL
*---------------------------------------------------------------------*

DATA:
  wa_control_parameters TYPE ssfctrlop,
  wa_output_options     TYPE ssfcompop,
  wa_output_otf         TYPE ssfcrescl.

*---------------------------------------------------------------------*
* PDF DATA
*---------------------------------------------------------------------*

DATA:
  lv_pdf_xstring  TYPE xstring,
  lv_bin_filesize TYPE i,
  lt_pdf_lines    TYPE TABLE OF tline,
  lt_pdf_binary   TYPE solix_tab.

*---------------------------------------------------------------------*
* MAIL DATA
*---------------------------------------------------------------------*

DATA:
  lo_send_request TYPE REF TO cl_bcs,
  lo_document     TYPE REF TO cl_document_bcs,
  lo_recipient    TYPE REF TO if_recipient_bcs,
  lo_sender       TYPE REF TO if_sender_bcs.

DATA:
  lt_mail_text TYPE bcsy_text,
  lv_recipient TYPE ad_smtpadr,
  lv_subject   TYPE so_obj_des.

DATA:
  lv_sent_to_all TYPE os_boolean.

*---------------------------------------------------------------------*
* 1. READ SALES ORDER HEADER
*---------------------------------------------------------------------*

SELECT SINGLE *
  FROM vbak
  INTO @wa_vbak
  WHERE vbeln = @p_vbeln.

IF sy-subrc <> 0.

  MESSAGE |Sales Order { p_vbeln } not found.| TYPE 'E'.

ENDIF.

*---------------------------------------------------------------------*
* 2. SELECT LOGO
*---------------------------------------------------------------------*

IF p_vbeln GE 10.
  dynamic_logo = 'LOGO'.
ELSE.
  dynamic_logo = 'LOGO_2'.
ENDIF.

*---------------------------------------------------------------------*
* 3. READ SALES ORDER ITEMS
*---------------------------------------------------------------------*

SELECT *
  FROM vbap
  INTO TABLE @it_vbap
  WHERE vbeln = @p_vbeln.

IF sy-subrc <> 0 OR it_vbap IS INITIAL.

  MESSAGE |No items found for Sales Order { p_vbeln }.| TYPE 'E'.

ENDIF.

*---------------------------------------------------------------------*
* 4. CALCULATE TOTAL
*---------------------------------------------------------------------*

CLEAR total_net_price.

LOOP AT it_vbap INTO wa_vbap.

  total_net_price =
    total_net_price + wa_vbap-netwr.

ENDLOOP.

*---------------------------------------------------------------------*
* 5. GET SMART FORM FUNCTION MODULE
*---------------------------------------------------------------------*

CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
  EXPORTING
    formname           = 'ZTEST_SF2'
  IMPORTING
    fm_name            = lv_fm
  EXCEPTIONS
    no_form            = 1
    no_function_module = 2
    OTHERS             = 3.

IF sy-subrc <> 0 OR lv_fm IS INITIAL.

  MESSAGE 'Unable to determine Smart Form Function Module.'
    TYPE 'E'.

ENDIF.

*---------------------------------------------------------------------*
* 6. SMART FORM CONTROL PARAMETERS
*
* GETOTF = X
* OTF data is required because the Smart Form output will be
* converted into PDF and attached to the e-mail.
*---------------------------------------------------------------------*

CLEAR wa_control_parameters.

wa_control_parameters-no_dialog = 'X'.
wa_control_parameters-getotf    = 'X'.

*---------------------------------------------------------------------*
* 7. SMART FORM OUTPUT OPTIONS
*---------------------------------------------------------------------*

CLEAR wa_output_options.

wa_output_options-tddest = 'LP01'.

*---------------------------------------------------------------------*
* 8. EXECUTE SMART FORM
*---------------------------------------------------------------------*

CALL FUNCTION lv_fm
  EXPORTING
    control_parameters = wa_control_parameters
    output_options     = wa_output_options
    user_settings      = ' '
    p_vbeln            = p_vbeln
    wa_vbak            = wa_vbak
    total_net_price    = total_net_price
    dynamic_logo       = dynamic_logo
  IMPORTING
    job_output_info    = wa_output_otf
  TABLES
    it_vbap            = it_vbap
  EXCEPTIONS
    formatting_error   = 1
    internal_error     = 2
    send_error         = 3
    user_canceled      = 4
    OTHERS             = 5.

IF sy-subrc <> 0.

  MESSAGE 'Error while executing Smart Form.' TYPE 'E'.

ENDIF.

*---------------------------------------------------------------------*
* 9. CHECK OTF DATA
*
* Smart Form must generate OTF data before PDF conversion.
*---------------------------------------------------------------------*

IF wa_output_otf-otfdata IS INITIAL.

  MESSAGE 'Smart Form did not generate OTF data.' TYPE 'E'.

ENDIF.

*---------------------------------------------------------------------*
* 10. CONVERT SMART FORM OTF TO PDF
*
* BIN_FILE      = PDF content in XSTRING format
* BIN_FILESIZE  = PDF size in bytes
*
* The XSTRING will later be converted into SOLIX_TAB so that
* CL_DOCUMENT_BCS can attach the PDF to the e-mail.
*---------------------------------------------------------------------*

CALL FUNCTION 'CONVERT_OTF'
  EXPORTING
    format                = 'PDF'
    max_linewidth         = 132
  IMPORTING
    bin_file              = lv_pdf_xstring
    bin_filesize          = lv_bin_filesize
  TABLES
    otf                   = wa_output_otf-otfdata
    lines                 = lt_pdf_lines
  EXCEPTIONS
    err_max_linewidth     = 1
    err_format            = 2
    err_conv_not_possible = 3
    err_bad_otf           = 4
    OTHERS                = 5.

IF sy-subrc <> 0.

  MESSAGE 'Unable to convert Smart Form OTF to PDF.' TYPE 'E'.

ENDIF.

*---------------------------------------------------------------------*
* 11. CHECK PDF
*---------------------------------------------------------------------*

IF lv_pdf_xstring IS INITIAL.

  MESSAGE 'PDF was not generated.' TYPE 'E'.

ENDIF.

*---------------------------------------------------------------------*
* 12. CONVERT PDF XSTRING TO SOLIX
*
* CL_DOCUMENT_BCS requires binary PDF content for
* I_ATT_CONTENT_HEX.
*---------------------------------------------------------------------*

*lt_pdf_binary =
*  cl_document_bcs=>xstring_to_solix(
*    ip_xstring = lv_pdf_xstring ).

CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
  EXPORTING
    buffer     = lv_pdf_xstring
*   APPEND_TO_TABLE       = ' '
* IMPORTING
*   OUTPUT_LENGTH         =
  TABLES
    binary_tab = lt_pdf_binary.

IF lt_pdf_binary IS INITIAL.

  MESSAGE 'PDF binary data could not be created.' TYPE 'E'.

ENDIF.

*---------------------------------------------------------------------*
* 13. CREATE SEND REQUEST
*
* CL_BCS creates the e-mail send request.
*---------------------------------------------------------------------*

TRY.

    lo_send_request = cl_bcs=>create_persistent( ).

  CATCH cx_send_req_bcs INTO DATA(lx_send_request).

    MESSAGE lx_send_request->get_text( ) TYPE 'E'.

ENDTRY.

* --------------------------     for Send to self start ---------------------------------
*TRY.
*    CALL METHOD cl_bcs=>create_persistent
*      RECEIVING
*        result = lo_send_request.
*  CATCH cx_send_req_bcs .
*ENDTRY.
*
*DATA: lo_sapuser TYPE REF TO cl_sapuser_bcs.
*TRY.
*    CALL METHOD cl_sapuser_bcs=>create
*      EXPORTING
*        i_user = 'ABAP5'
*      RECEIVING
*        result = lo_sapuser.
*  CATCH cx_address_bcs .
*ENDTRY.
*
*TRY.
*    CALL METHOD lo_send_request->add_recipient
*      EXPORTING
*        i_recipient = lo_sapuser
**       i_express   =
**       i_copy      =
**       i_blind_copy =
**       i_no_forward =
*      .
*  CATCH cx_send_req_bcs .
*ENDTRY.
* --------------------------     for Send to self end -------------------------------------

* -------------------- for send to external user Start

DATA lo_external_user TYPE REF TO cl_cam_address_bcs.
TRY.
    CALL METHOD cl_cam_address_bcs=>create_internet_address
      EXPORTING
        i_address_string = 'sumitkuk3714322@gmail.com'
*       i_address_name   =
*       i_incl_sapuser   =
      RECEIVING
        result           = lo_external_user.
  CATCH cx_address_bcs .
ENDTRY.

TRY.
    CALL METHOD lo_send_request->add_recipient
      EXPORTING
        i_recipient = lo_external_user
*       i_express   =
*       i_copy      =
*       i_blind_copy =
*       i_no_forward =
      .
  CATCH cx_send_req_bcs .
ENDTRY.

* -------------------- for send to external user End

DATA: is_text TYPE soli,
      it_text TYPE TABLE OF soli.

is_text = 'Dear Sir/Madam,'.
APPEND is_text TO it_text.

is_text-line = |Please find attached Sales Order { p_vbeln }.|.
APPEND is_text TO it_text.

is_text = 'Please check the attached Sales Order PDF.'.
APPEND is_text TO it_text.

APPEND 'Regards,' TO it_text.
APPEND 'SAP System' TO it_text.

CLEAR is_text.

TRY.
    CALL METHOD cl_document_bcs=>create_document
      EXPORTING
        i_type    = 'RAW'
        i_subject = 'Sale Details'
*       i_length  =
*       i_language     = SPACE
*       i_importance   =
*       i_sensitivity  =
        i_text    = it_text
*       i_hex     =
*       i_header  =
*       i_sender  =
*       iv_vsi_profile =
      RECEIVING
        result    = lo_document.
  CATCH cx_document_bcs .
ENDTRY.

DATA: is_subject TYPE so_obj_des.
CONCATENATE 'Sales_Order :' p_vbeln INTO is_subject.

TRY.
    CALL METHOD lo_document->add_attachment
      EXPORTING
        i_attachment_type    = 'PDF'
        i_attachment_subject = is_subject " |Sales_Order_{ p_vbeln }.pdf|
*       i_attachment_size    =
*       i_attachment_language = SPACE
*       i_att_content_text   =
        i_att_content_hex    = lt_pdf_binary
*       i_attachment_header  =
*       iv_vsi_profile       =
      .
  CATCH cx_document_bcs .
ENDTRY.

TRY.
    CALL METHOD lo_send_request->set_document
      EXPORTING
        i_document = lo_document.
  CATCH cx_send_req_bcs .
ENDTRY.

TRY.
    CALL METHOD lo_send_request->set_send_immediately
      EXPORTING
*       i_send_immediately = lv_sent_to_all .
        i_send_immediately = 'X'.

  CATCH cx_send_req_bcs .
ENDTRY.


TRY.
    CALL METHOD lo_send_request->send
*  EXPORTING
*    i_with_error_screen = SPACE
      RECEIVING
        result = lv_sent_to_all.

  CATCH cx_send_req_bcs .
ENDTRY.



IF lv_sent_to_all IS NOT INITIAL.

  COMMIT WORK.

*  MESSAGE |Sales Order { p_vbeln } PDF sent successfully to { lv_recipient }.|
*    TYPE 'S'.
  MESSAGE |Sales Order { p_vbeln } PDF sent successfully| TYPE 'S'.

ELSE.

  ROLLBACK WORK.

  MESSAGE 'Mail could not be sent.' TYPE 'E'.

ENDIF.
