
REPORT zpracticebapisale.
DATA: ls_header  TYPE bapisdhd1,
      ls_headerx TYPE bapisdhd1x.

DATA: ls_return     TYPE bapiret2,
      lt_return     TYPE TABLE OF bapiret2,

      ls_items      TYPE bapisditm,
      lt_items      TYPE TABLE OF bapisditm,

      ls_itemsx     TYPE bapisditmx,
      lt_itemsx     TYPE TABLE OF bapisditmx,

      ls_partners   TYPE bapiparnr,
      lt_partners   TYPE TABLE OF bapiparnr,

      ls_schedules  TYPE bapischdl,
      lt_schedules  TYPE TABLE OF bapischdl,

      ls_schedulesx TYPE bapischdlx,
      lt_schedulesx TYPE TABLE OF bapischdlx.

DATA: lv_vbeln TYPE vbeln_va.

" Header info
ls_header-doc_type   = 'OR'.
ls_header-sales_org  = 'VR01'.
ls_header-distr_chan = '00'.
ls_header-division   = '00'.

ls_headerx-updateflag = 'I'.
ls_headerx-doc_type   = 'X'.
ls_headerx-sales_org  = 'X'.
ls_headerx-distr_chan = 'X'.
ls_headerx-division   = 'X'.

" fill Item info
ls_items-itm_number = '000010'.
ls_items-material   = '318'.
ls_items-plant      = 'VR01'.
ls_items-target_qty = '10'.
ls_items-sales_unit = 'KG'.
APPEND ls_items TO lt_items.
CLEAR ls_items.

ls_itemsx-itm_number = '000010'.
ls_itemsx-material   = 'X'.
ls_itemsx-plant      = 'X'.
ls_itemsx-target_qty = 'X'.
ls_itemsx-sales_unit = 'X'.
APPEND ls_itemsx TO lt_itemsx.
CLEAR ls_itemsx.

" Fill Partner info
ls_partners-partn_role = 'AG'.
ls_partners-partn_numb = '0000000010'.
APPEND ls_partners TO lt_partners.
CLEAR ls_partners.

" Fill Schedule info
ls_schedules-itm_number = '000010'.
ls_schedules-req_qty    = '10.000'.

APPEND ls_schedules TO lt_schedules.
CLEAR ls_schedules.

" Fill Schedule X info
ls_schedulesx-itm_number = '000010'.
ls_schedulesx-req_qty    = 'X'.

APPEND ls_schedulesx TO lt_schedulesx.
CLEAR ls_schedulesx.

CALL FUNCTION 'BAPI_SALESORDER_CREATEFROMDAT2'
  EXPORTING

    order_header_in     = ls_header
    order_header_inx    = ls_headerx
  IMPORTING
    salesdocument       = lv_vbeln
  TABLES
    return              = lt_return
    order_items_in      = lt_items
    order_items_inx     = lt_itemsx
    order_partners      = lt_partners
    order_schedules_in  = lt_schedules
    order_schedules_inx = lt_schedulesx.

*LOOP AT lt_return INTO ls_return.
*
*  WRITE: / ls_return-type,
*           ls_return-id,
*           ls_return-number,
*           ls_return-message.
*
*ENDLOOP.

READ TABLE lt_return INTO ls_return WITH KEY type = 'E'.


IF sy-subrc = 0.

  WRITE: /.
  WRITE: / 'ERROR: Sales Order was not created.'.

  CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
ELSE.
  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
ENDIF.
