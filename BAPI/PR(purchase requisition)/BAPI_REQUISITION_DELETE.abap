*&---------------------------------------------------------------------*
*& Report ZTEST_BAPI
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ztest_bapi.

PARAMETERS p_banfn TYPE banfn.
DATA: lt_items  TYPE STANDARD TABLE OF bapieband,
      ls_items  TYPE bapieband,
      lt_return TYPE STANDARD TABLE OF bapireturn.

START-OF-SELECTION.
  SELECT banfn, bnfpo, loekz FROM eban INTO TABLE @DATA(lt_eban) WHERE banfn = @p_banfn AND
                                                                       loekz NE 'X'.
  IF sy-subrc IS INITIAL.
    LOOP AT lt_eban INTO DATA(wa).
      ls_items-preq_item = wa-bnfpo.
      ls_items-delete_ind = 'X'.
      APPEND ls_items TO lt_items.
    ENDLOOP.

    CALL FUNCTION 'BAPI_REQUISITION_DELETE'
      EXPORTING
        number                      = p_banfn
      TABLES
        requisition_items_to_delete = lt_items
        return                      = lt_return.
    READ TABLE lt_return INTO DATA(ls_return) WITH KEY type = 'S'.
    IF sy-subrc IS INITIAL.
      MESSAGE 'PR item is deleted' TYPE 'S'.
    ELSE.
      MESSAGE 'PR item is not deleted' TYPE 'S'.

    ENDIF.
  ELSE.
    MESSAGE 'no data found' TYPE 'E'.
  ENDIF.
