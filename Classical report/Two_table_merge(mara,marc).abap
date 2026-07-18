*&---------------------------------------------------------------------*
*& Report ZABAP_TWOTABLEMARGE
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zabap_twotablemarge.

TABLES : mara, marc .

TYPES: BEGIN OF ty_mara,
         matnr TYPE mara-matnr,
         ersda TYPE mara-ersda,
       END OF ty_mara.


TYPES: BEGIN OF ty_marc,
         matnr TYPE marc-matnr,
         werks TYPE marc-werks,
       END OF ty_marc.

TYPES: BEGIN OF ty_final,
         matnr TYPE mara-matnr,
         ersda TYPE mara-ersda,
         werks TYPE marc-werks,
       END OF ty_final.

DATA : it_mara TYPE TABLE OF ty_mara .
DATA : wa_mara TYPE          ty_mara .
DATA : it_marc TYPE TABLE OF ty_marc .
DATA : wa_marc TYPE          ty_marc .
DATA : it_final TYPE TABLE OF ty_final.
DATA : wa_final TYPE          ty_final.

SELECT-OPTIONS : s_matnr FOR mara-matnr .

" get data from mara

SELECT matnr
       ersda
 FROM mara
 INTO TABLE  it_mara
  WHERE matnr IN s_matnr.

IF it_mara IS NOT INITIAL .

  SELECT matnr
         werks
     FROM marc
    INTO TABLE  it_marc
  FOR ALL ENTRIES IN it_mara
  WHERE matnr = it_mara-matnr.

*  sql create
*  select matnr, werks
*  from marc
*  where matnr = 'M100'
*  or matnr = 'M200'
*  or matnr = 'M300';
ELSE .
  WRITE : 'No material  data found' .

ENDIF.
LOOP AT it_mara  INTO wa_mara.

  wa_final-matnr = wa_mara-matnr.
  wa_final-ersda = wa_mara-ersda.

*    LOOP at it_marc into wa_marc WHERE matnr = wa_mara-matnr.
*    wa_final-werks = wa_marc-werks.
*      APPEND wa_final to it_final.
*
*        ENDLOOP.

  READ TABLE it_marc INTO wa_marc WITH KEY matnr = wa_mara-matnr.
  IF sy-subrc IS INITIAL.
    wa_final-werks = wa_marc-werks.
  ELSE.
*    wa_final-werks  = '9999'.
    wa_final-werks  = 'N/A'.
  ENDIF.
  APPEND wa_final TO it_final.

ENDLOOP.

LOOP AT it_final  INTO wa_final.
  WRITE :/5 wa_final-matnr , 25 wa_final-ersda , 45 wa_final-werks.

ENDLOOP.
