*&---------------------------------------------------------------------*
*& Report Z_CALL_CLASS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_call_class.
DATA:erdat TYPE erdat,
     erzet TYPE erzet,
     ernam TYPE ernam,
     angdt TYPE angdt.

PARAMETERS p_vbeln TYPE vbeln.

* 1. Select Static Method in SE24

CALL METHOD zcl_vabk=>get_details_vbak
  EXPORTING
    p_vbeln    = p_vbeln
  IMPORTING
    v_erdat    = erdat
    v_erzet    = erzet
    v_ernam    = ernam
    v_angdt    = angdt
  EXCEPTIONS
    wronginput = 1
    OTHERS     = 2.

IF sy-subrc = 1.
  MESSAGE 'Invalid Sales Document Number' TYPE 'E'.
ELSEIF sy-subrc = 2.
  MESSAGE 'Unknown Error' TYPE 'E'.
ENDIF.

IF sy-subrc = 1.
  MESSAGE 'Invalid Sales Document Number' TYPE 'E'.
ELSEIF sy-subrc = 2.
  MESSAGE 'Unknown Error' TYPE 'E'.
ENDIF.
WRITE: / erdat,  erzet, ernam, angdt.

* 2. Select Instance Method in SE24
data(ol_object) = new zcl_vabk( ).
CALL METHOD ol_object->get_details_vbak
  EXPORTING
    p_vbeln    = p_vbeln
  IMPORTING
    v_erdat    = erdat
    v_erzet    = erzet
    v_ernam    = ernam
    v_angdt    = angdt
  EXCEPTIONS
    wronginput = 1
    others     = 2.

IF sy-subrc = 1.
  MESSAGE 'Invalid Sales Document Number' TYPE 'E'.
ELSEIF sy-subrc = 2.
  MESSAGE 'Unknown Error' TYPE 'E'.
ENDIF.
WRITE: / erdat,  erzet, ernam, angdt.
