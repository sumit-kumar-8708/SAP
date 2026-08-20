*&---------------------------------------------------------------------*
*& Report ZDRIVER_SALES_ORDER
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zdriver_sales_order.

PARAMETERS p_vbeln TYPE vbeln_va.

DATA:
  wa_vbak      TYPE vbak,
  it_vbap      TYPE STANDARD TABLE OF vbap,
  wa_vbap      TYPE vbap,
  dynamic_logo TYPE sychar20,
  lv_fm        TYPE rs38l_fnam.
DATA: total_net_price TYPE netwr_ap VALUE 0.

" Step 1 — VBAK read
SELECT SINGLE *
  FROM vbak
  INTO @wa_vbak
  WHERE vbeln = @p_vbeln.
IF sy-subrc <> 0.
  MESSAGE 'Sales Order not found' TYPE 'E'.
ENDIF.

IF p_vbeln GE 10.
  dynamic_logo = 'LOGO'.
ELSEIF p_vbeln lE 10.
  dynamic_logo = 'LOGO_2'.
ENDIF.

" Step 2 — VBAP read
SELECT *
  FROM vbap
  INTO TABLE @it_vbap
  WHERE vbeln = @p_vbeln.


LOOP AT it_vbap INTO DATA(w_vbap).
  total_net_price = total_net_price + w_vbap-netwr.
ENDLOOP.

" step 3 - Get Smart Form Function Module
CALL FUNCTION 'SSF_FUNCTION_MODULE_NAME'
  EXPORTING
   formname           = 'ZTEST_SF2' " smartform name
*    formname           = 'ZTEST_SF4_COPY'
  IMPORTING
    fm_name            = lv_fm
  EXCEPTIONS
    no_form            = 1
    no_function_module = 2
    OTHERS             = 3.

IF sy-subrc <> 0.
  MESSAGE 'Smart Form FM not found' TYPE 'E'.
ENDIF.

" Step 4 - Call Smart Form
*CALL FUNCTION '/1BCDWB/SF00000087'
CALL FUNCTION lv_fm
  EXPORTING
*   ARCHIVE_INDEX    =
*   ARCHIVE_INDEX_TAB          =
*   ARCHIVE_PARAMETERS         =
*   CONTROL_PARAMETERS         =
*   MAIL_APPL_OBJ    =
*   MAIL_RECIPIENT   =
*   MAIL_SENDER      =
*   OUTPUT_OPTIONS   =
*   USER_SETTINGS    = 'X'
    p_vbeln          = p_vbeln
    wa_vbak          = wa_vbak
    total_net_price  = total_net_price
    dynamic_logo     = dynamic_logo
* IMPORTING
*   DOCUMENT_OUTPUT_INFO       =
*   JOB_OUTPUT_INFO  =
*   JOB_OUTPUT_OPTIONS         =
  TABLES
    it_vbap          = it_vbap
  EXCEPTIONS
    formatting_error = 1
    internal_error   = 2
    send_error       = 3
    user_canceled    = 4
    OTHERS           = 5.
IF sy-subrc <> 0.
* Implement suitable error handling here
ENDIF.
