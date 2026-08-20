
*&---------------------------------------------------------------------*
*& Report ZDRIVER_SALES_ORDER_1
*&---------------------------------------------------------------------*
*& Purpose:
*&   1. Read Sales Order header data from VBAK
*&   2. Read Sales Order item data from VBAP
*&   3. Calculate total Net Value
*&   4. Call Smart Form ZTEST_SF2
*&   5. Generate OTF output
*&   6. Convert OTF output into PDF
*&   7. Ask user where to save the PDF
*&   8. Download the generated PDF to the local computer
*&
*& This program is written with detailed comments so that a new
*& ABAP developer can easily understand each step.
*&---------------------------------------------------------------------*

REPORT zdriver_sales_order_2.

*---------------------------------------------------------------------*
* 1. SELECTION SCREEN
*---------------------------------------------------------------------*
* User enters the Sales Order number here.
*---------------------------------------------------------------------*

PARAMETERS p_vbeln TYPE vbeln_va.

*---------------------------------------------------------------------*
* 2. DATA DECLARATION
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
* Smart Form Control Parameters
*---------------------------------------------------------------------*
* SSFCTRLOP controls Smart Form execution.
*
* Important fields used here:
*   NO_DIALOG = Do not show print dialog
*   PREVIEW   = Open Smart Form preview
*   GETOTF    = Generate OTF data
*---------------------------------------------------------------------*

DATA:
  wa_control_parameters TYPE ssfctrlop,

*---------------------------------------------------------------------*
* Smart Form Output Options
*---------------------------------------------------------------------*
* SSFCOMPOP contains output device / spool related settings.
*---------------------------------------------------------------------*

  wa_output_options     TYPE ssfcompop,

*---------------------------------------------------------------------*
* Smart Form Output Result
*---------------------------------------------------------------------*
* SSFCRESCL contains the generated OTF data.
*---------------------------------------------------------------------*

  wa_output_otf         TYPE ssfcrescl.

*---------------------------------------------------------------------*
* Variables required for OTF -> PDF conversion
*---------------------------------------------------------------------*

DATA:
  it_docs         TYPE TABLE OF docs, " Archive document table
  it_line_pdf     TYPE TABLE OF tline,   " PDF output lines
  lo_rc           TYPE i, " Return code from file dialog
  it_file         TYPE TABLE OF file_table,  " File selection table
  lo_filename     TYPE string, " Complete filename selected by user
  lv_bin_filesize TYPE i. " Size of generated PDF in bytes

*---------------------------------------------------------------------*
* 3. READ SALES ORDER HEADER
*---------------------------------------------------------------------*
SELECT SINGLE *
  FROM vbak
  INTO @wa_vbak
  WHERE vbeln = @p_vbeln.

*---------------------------------------------------------------------*
* Check whether Sales Order exists
*---------------------------------------------------------------------*

IF sy-subrc <> 0.

  MESSAGE |Sales Order { p_vbeln } not found in VBAK.| TYPE 'E'.

ENDIF.

*---------------------------------------------------------------------*
* 4. SELECT DYNAMIC LOGO
*---------------------------------------------------------------------*
* Depending on Sales Order number, different logo names are selected.
*
* IMPORTANT:
* This is only an example business rule.
* In a real project, logo selection should normally be based on
* Sales Organization / Company Code / Business Unit etc.
*---------------------------------------------------------------------*

IF p_vbeln GE 10.
  dynamic_logo = 'LOGO'.
ELSE.
  dynamic_logo = 'LOGO_2'.
ENDIF.

*---------------------------------------------------------------------*
* 5. READ SALES ORDER ITEM DATA
*---------------------------------------------------------------------*
SELECT *
  FROM vbap
  INTO TABLE @it_vbap
  WHERE vbeln = @p_vbeln.

*---------------------------------------------------------------------*
* Check whether any item exists
*---------------------------------------------------------------------*
IF sy-subrc <> 0 OR it_vbap IS INITIAL.
  MESSAGE |No items found for Sales Order { p_vbeln }.| TYPE 'E'.
ENDIF.

*---------------------------------------------------------------------*
* 6. CALCULATE TOTAL NET VALUE
*---------------------------------------------------------------------*
* Loop through every VBAP item and add NETWR.
*---------------------------------------------------------------------*
CLEAR total_net_price.
LOOP AT it_vbap INTO wa_vbap.
  total_net_price = total_net_price + wa_vbap-netwr.
ENDLOOP.

*---------------------------------------------------------------------*
* 7. GET SMART FORM FUNCTION MODULE
*---------------------------------------------------------------------*
* Smart Form name is not directly called.
*
* SAP generates a Function Module internally for every Smart Form.
*
* Therefore:
*
*   Smart Form Name
*          |
*          V
*   SSF_FUNCTION_MODULE_NAME
*          |
*          V
*   Generated Function Module Name
*
* Example:
*   ZTEST_SF2 -> /1BCDWB/SF00000XXX
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

*---------------------------------------------------------------------*
* Check whether Smart Form Function Module was generated successfully
*---------------------------------------------------------------------*
IF sy-subrc <> 0 OR lv_fm IS INITIAL.
  CASE sy-subrc.
    WHEN 1.
      MESSAGE 'Smart Form ZTEST_SF2 does not exist.' TYPE 'E'.
    WHEN 2.
      MESSAGE 'Function Module for Smart Form ZTEST_SF2 could not be generated.'
        TYPE 'E'.
    WHEN OTHERS.
      MESSAGE 'Unable to determine Smart Form Function Module.'
        TYPE 'E'.
  ENDCASE.
ENDIF.

*---------------------------------------------------------------------*
* 8. PREPARE SMART FORM CONTROL PARAMETERS
*---------------------------------------------------------------------*
*
* NO_DIALOG = 'X'
*   Do not show normal print parameter dialog.
*
* PREVIEW = 'X'
*   Ask Smart Form to generate preview.
*
* GETOTF = 'X'
*   Required because we want OTF data so that it can later be
*   converted into PDF.
*---------------------------------------------------------------------*

CLEAR wa_control_parameters.
wa_control_parameters-no_dialog = 'X'.
wa_control_parameters-preview   = 'X'.
wa_control_parameters-getotf    = 'X'.

*---------------------------------------------------------------------*
* 9. OUTPUT OPTIONS
*---------------------------------------------------------------------*
* TDDest represents the output device.
*
* LP01 is commonly used as an example printer/output device.
*
* USER_SETTINGS = SPACE is used in the Smart Form call below,
* therefore the program controls the output settings itself.
*---------------------------------------------------------------------*

CLEAR wa_output_options.
wa_output_options-tddest = 'LP01'.

*---------------------------------------------------------------------*
* 10. CALL SMART FORM
*---------------------------------------------------------------------*
* The generated Smart Form Function Module is called dynamically
* using variable LV_FM.
*
* Header data:
*   WA_VBAK
*
* Item data:
*   IT_VBAP
*
* Total:
*   TOTAL_NET_PRICE
*
* Dynamic logo:
*   DYNAMIC_LOGO
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
    " Generated OTF result
    job_output_info    = wa_output_otf
  TABLES
    " Sales Order item table
    it_vbap            = it_vbap
  EXCEPTIONS
    formatting_error   = 1
    internal_error     = 2
    send_error         = 3
    user_canceled      = 4
    OTHERS             = 5.

*---------------------------------------------------------------------*
* 11. HANDLE SMART FORM ERRORS
*---------------------------------------------------------------------*
IF sy-subrc <> 0.
  CASE sy-subrc.
    WHEN 1.
      MESSAGE 'Smart Form formatting error occurred.' TYPE 'E'.
    WHEN 2.
      MESSAGE 'Internal error occurred while executing Smart Form.'
        TYPE 'E'.
    WHEN 3.
      MESSAGE 'Smart Form output could not be sent.' TYPE 'E'.
    WHEN 4.
      MESSAGE 'User cancelled the Smart Form execution.' TYPE 'E'.
    WHEN OTHERS.
      MESSAGE 'Unknown error occurred while executing Smart Form.' TYPE 'E'.
  ENDCASE.
ENDIF.

*---------------------------------------------------------------------*
* 12. CHECK WHETHER OTF DATA WAS GENERATED
*---------------------------------------------------------------------*
* GETOTF = X should generate OTF data.
*
* If OTF data is empty, PDF conversion cannot be performed.
*---------------------------------------------------------------------*

IF wa_output_otf-otfdata IS INITIAL.
  MESSAGE 'Smart Form did not generate OTF data.' TYPE 'E'.
ENDIF.

*---------------------------------------------------------------------*
* 13. CONVERT OTF TO PDF
*---------------------------------------------------------------------*
*
* Smart Form
*     |
*     V
*   OTF DATA
*     |
*     V
* CONVERT_OTF_2_PDF
*     |
*     V
*   PDF DATA
*
* IT_LINE_PDF will contain the generated PDF binary data.
*---------------------------------------------------------------------*

CLEAR:
  it_docs,
  it_line_pdf,
  lv_bin_filesize.

CALL FUNCTION 'CONVERT_OTF_2_PDF'
* EXPORTING
*   USE_OTF_MC_CMD               = 'X'
*   ARCHIVE_INDEX                =
* IMPORTING
*   BIN_FILESIZE                 =
  TABLES
    otf                    = wa_output_otf-otfdata " OTF input
    doctab_archive         = it_docs " Archive information
    lines                  = it_line_pdf " PDF output
  EXCEPTIONS
    err_conv_not_possible  = 1
    err_otf_mc_noendmarker = 2
    OTHERS                 = 3.

*---------------------------------------------------------------------*
* 14. HANDLE PDF CONVERSION ERRORS
*---------------------------------------------------------------------*

IF sy-subrc <> 0.

  CASE sy-subrc.

    WHEN 1.
      MESSAGE 'OTF to PDF conversion is not possible.' TYPE 'E'.

    WHEN 2.
      MESSAGE 'OTF data is incomplete. End marker was not found.'
        TYPE 'E'.

    WHEN OTHERS.
      MESSAGE 'Unknown error occurred during OTF to PDF conversion.'
        TYPE 'E'.

  ENDCASE.

ENDIF.

*---------------------------------------------------------------------*
* 15. CHECK PDF DATA
*---------------------------------------------------------------------*
* If PDF data is empty, there is nothing to download.
*---------------------------------------------------------------------*

*IF it_line_pdf IS INITIAL OR lv_bin_filesize IS INITIAL.
IF it_line_pdf IS INITIAL.
  MESSAGE 'PDF was not generated successfully.' TYPE 'E'.
ENDIF.

*---------------------------------------------------------------------*
* 16. OPEN FILE SAVE / SELECTION DIALOG
*---------------------------------------------------------------------*
* This allows the user to select the location where the PDF should
* be saved.
*
* Example:
*   C:\Users\Sumit\Downloads\Sales_Order.pdf
*---------------------------------------------------------------------*

CLEAR:
  it_file,
  lo_rc,
  lo_filename.

CALL METHOD cl_gui_frontend_services=>file_open_dialog
  EXPORTING
    " Show PDF files in the dialog
    window_title            = 'Select location for Sales Order PDF'
    default_extension       = 'pdf'
    default_filename        = |Sales_Order_{ p_vbeln }.pdf|
    file_filter             = 'PDF Files (*.pdf)|*.pdf|All Files (*.*)|*.*'
    multiselection          = abap_false
  CHANGING
    " Selected file information
    file_table              = it_file
    " Number of selected files
    rc                      = lo_rc
  EXCEPTIONS
    file_open_dialog_failed = 1
    cntl_error              = 2
    error_no_gui            = 3
    not_supported_by_gui    = 4
    OTHERS                  = 5.

*---------------------------------------------------------------------*
* 17. HANDLE FILE DIALOG ERRORS
*---------------------------------------------------------------------*

IF sy-subrc <> 0.

  CASE sy-subrc.

    WHEN 1.
      MESSAGE 'Unable to open file selection dialog.' TYPE 'E'.

    WHEN 2.
      MESSAGE 'Frontend control error occurred.' TYPE 'E'.

    WHEN 3.
      MESSAGE 'This operation requires SAP GUI frontend.' TYPE 'E'.

    WHEN 4.
      MESSAGE 'File dialog is not supported on this system.' TYPE 'E'.

    WHEN OTHERS.
      MESSAGE 'Unknown error occurred while opening file dialog.'
        TYPE 'E'.

  ENDCASE.

ENDIF.

*---------------------------------------------------------------------*
* 18. CHECK WHETHER USER SELECTED A FILE
*---------------------------------------------------------------------*
* If user presses Cancel, IT_FILE remains empty.
*---------------------------------------------------------------------*

IF it_file IS INITIAL.

  MESSAGE 'PDF save operation cancelled by user.' TYPE 'S'
          DISPLAY LIKE 'W'.

  RETURN.

ENDIF.

*---------------------------------------------------------------------*
* 19. GET SELECTED FILE NAME
*---------------------------------------------------------------------*

READ TABLE it_file INTO DATA(wa_file) INDEX 1.

IF sy-subrc <> 0 OR wa_file-filename IS INITIAL.

  MESSAGE 'No valid PDF filename was selected.' TYPE 'E'.

ENDIF.

*---------------------------------------------------------------------*
* Store selected filename in string variable
*---------------------------------------------------------------------*

lo_filename = wa_file-filename.

*---------------------------------------------------------------------*
* 20. DOWNLOAD PDF TO LOCAL COMPUTER
*---------------------------------------------------------------------*
*
* IMPORTANT:
* PDF is binary data.
*
* Therefore:
*   FILETYPE = 'BIN'
*
* is required.
*---------------------------------------------------------------------*

CALL METHOD cl_gui_frontend_services=>gui_download
  EXPORTING
    " Complete path selected by user
    filename                = lo_filename
    " PDF is binary data
    filetype                = 'BIN'
    " Exact size of PDF in bytes
    bin_filesize            = lv_bin_filesize
  CHANGING
    " Generated PDF binary data
    data_tab                = it_line_pdf
  EXCEPTIONS
    file_write_error        = 1
    no_batch                = 2
    gui_refuse_filetransfer = 3
    invalid_type            = 4
    no_authority            = 5
    unknown_error           = 6
    header_not_allowed      = 7
    separator_not_allowed   = 8
    filesize_not_allowed    = 9
    header_too_long         = 10
    dp_error_create         = 11
    dp_error_send           = 12
    dp_error_write          = 13
    unknown_dp_error        = 14
    access_denied           = 15
    dp_out_of_memory        = 16
    disk_full               = 17
    dp_timeout              = 18
    file_not_found          = 19
    dataprovider_exception  = 20
    control_flush_error     = 21
    not_supported_by_gui    = 22
    error_no_gui            = 23
    OTHERS                  = 24.

*---------------------------------------------------------------------*
* 21. HANDLE DOWNLOAD ERRORS
*---------------------------------------------------------------------*

IF sy-subrc <> 0.

  CASE sy-subrc.

    WHEN 1.
      MESSAGE 'Unable to write PDF file to selected location.' TYPE 'E'.

    WHEN 2.
      MESSAGE 'PDF download cannot be executed in background mode.'
        TYPE 'E'.

    WHEN 3.
      MESSAGE 'SAP GUI refused the file transfer.' TYPE 'E'.

    WHEN 4.
      MESSAGE 'Invalid file type specified for PDF download.' TYPE 'E'.

    WHEN 5.
      MESSAGE 'You do not have authority to write to this location.'
        TYPE 'E'.

    WHEN 15.
      MESSAGE 'Access denied. Please select another folder.' TYPE 'E'.

    WHEN 17.
      MESSAGE 'Disk is full. Please select another location.' TYPE 'E'.

    WHEN 18.
      MESSAGE 'File transfer timed out.' TYPE 'E'.

    WHEN 19.
      MESSAGE 'Selected file or directory was not found.' TYPE 'E'.

    WHEN 22.
      MESSAGE 'PDF download is not supported on this frontend.'
        TYPE 'E'.

    WHEN 23.
      MESSAGE 'No SAP GUI frontend is available for file download.'
        TYPE 'E'.

    WHEN OTHERS.
      MESSAGE 'Unknown error occurred while downloading PDF.'
        TYPE 'E'.

  ENDCASE.

ENDIF.

*---------------------------------------------------------------------*
* 22. SUCCESS MESSAGE
*---------------------------------------------------------------------*
* If program reaches this point, PDF has been successfully created
* and downloaded.
*---------------------------------------------------------------------*

MESSAGE |Sales Order { p_vbeln } PDF successfully saved to { lo_filename }|
        TYPE 'S'.
