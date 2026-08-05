REPORT z_material_delete.

DATA: ls_head      TYPE bapimathead,
      ls_client    TYPE bapi_mara,
      ls_clientx   TYPE bapi_marax,
      ls_return    TYPE bapiret2,
      lt_returnmsg TYPE TABLE OF bapi_matreturn2,
      ls_mara      TYPE mara.

PARAMETERS: p_matnr TYPE mara-matnr.

START-OF-SELECTION.

  SELECT SINGLE *
    FROM mara
    INTO ls_mara
    WHERE matnr = p_matnr AND LVORM ne 'X'.

  IF sy-subrc <> 0.
    MESSAGE 'Material not found' TYPE 'E'.
  ENDIF.

* Header Data
  CLEAR ls_head.
  ls_head-material     = ls_mara-matnr.
  ls_head-matl_type    = ls_mara-mtart.
  ls_head-ind_sector   = ls_mara-mbrsh.
  ls_head-basic_view   = 'X'.
*  ls_head-inp_fld_check = 'W'.

* Client Data
  CLEAR ls_client.
  ls_client-del_flag = 'X'.

* Client Data X
  CLEAR ls_clientx.
  ls_clientx-del_flag = 'X'.

  CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
    EXPORTING
      headdata       = ls_head
      clientdata     = ls_client
      clientdatax    = ls_clientx
    IMPORTING
      return         = ls_return
    TABLES
      returnmessages = lt_returnmsg.

  IF ls_return-type CA 'AE'.

    WRITE: / 'Error:', ls_return-message.

    LOOP AT lt_returnmsg INTO DATA(ls_msg).
      WRITE: / ls_msg-type,
               ls_msg-id,
               ls_msg-number,
               ls_msg-message.
    ENDLOOP.

    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

  ELSE.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.

    WRITE: / 'Material marked for deletion successfully.'.

    LOOP AT lt_returnmsg INTO ls_msg.
      WRITE: / ls_msg-type,
               ls_msg-id,
               ls_msg-number,
               ls_msg-message.
    ENDLOOP.

  ENDIF.
