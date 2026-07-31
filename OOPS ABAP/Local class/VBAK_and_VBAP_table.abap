
*Requirement:
*The customer wants that he would be giving a range of Sales document number on the selection screen
*and wants to see details of Sales Document from VBAK table and VBAP table on Output Screen.

" VBAP is Line item and VBAK is a Header

REPORT z_call_class_3_local_class.

TYPES: BEGIN OF ty_vbak,

         " vbak
         vbeln TYPE vbeln_va,
         erdat TYPE erdat,
         erzet TYPE erzet,
         ernam TYPE ernam,
         vbtyp TYPE vbtyp,
       END OF ty_vbak,

       " vbap
       BEGIN OF ty_vbap,
         vbeln TYPE vbeln_va,
         posnr TYPE posnr,
         matnr TYPE matnr,
       END OF ty_vbap,

       " combine of both table
       BEGIN OF ty_final,
         vbeln TYPE vbeln_va,
         erdat TYPE erdat,
         erzet TYPE erzet,
         ernam TYPE ernam,
         vbtyp TYPE vbtyp,
         posnr TYPE posnr,
         matnr TYPE matnr,
       END OF ty_final.

*TYPES ty_r_vbeln TYPE RANGE OF vbeln_va.

DATA: it_vbak  TYPE TABLE OF ty_vbak,
      wa_vbak  TYPE ty_vbak,
      it_vbap  TYPE TABLE OF ty_vbap,
      wa_vbap  TYPE ty_vbap,
      it_final TYPE TABLE OF ty_final,
      wa_final TYPE ty_final.

DATA iv_vbeln TYPE vbeln_va.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

SELECT-OPTIONS: s_vbeln FOR iv_vbeln OBLIGATORY.

SELECTION-SCREEN END OF BLOCK b1.

" validation on select option

AT SELECTION-SCREEN.

  LOOP AT s_vbeln INTO DATA(ls_vbeln).

    " Only numbers allowed
    IF ls_vbeln-low CN '0123456789'.
      MESSAGE 'Only numeric values are allowed.' TYPE 'E'.
    ENDIF.

    IF ls_vbeln-high IS NOT INITIAL.
      IF ls_vbeln-high CN '0123456789'.
        MESSAGE 'Only numeric values are allowed.' TYPE 'E'.
      ENDIF.
    ENDIF.


  ENDLOOP.

CLASS lcl_final DEFINITION.
  PUBLIC SECTION.
    METHODS:
      display_details.
ENDCLASS.

CLASS lcl_final IMPLEMENTATION.

  METHOD display_details.

    SELECT vbeln
         erdat
         erzet
         ernam
         vbtyp
    FROM vbak
    INTO TABLE it_vbak
    WHERE vbeln IN s_vbeln.

    IF sy-subrc <> 0.
      MESSAGE 'NO data found in VBAK Table' TYPE 'E'.
    ENDIF.

    SELECT vbeln posnr matnr
    FROM vbap
    INTO CORRESPONDING FIELDS OF TABLE it_vbap
    FOR ALL ENTRIES IN it_vbak
    WHERE vbeln = it_vbak-vbeln.

    IF sy-subrc <> 0.
      MESSAGE 'NO data found in VBAP Table' TYPE 'E'.
    ENDIF.

    " NOw prepare final result
    LOOP AT it_vbap INTO wa_vbap.
      wa_final-posnr = wa_vbap-posnr.
      wa_final-matnr = wa_vbap-matnr.

      READ TABLE it_vbak INTO wa_vbak WITH KEY vbeln = wa_vbap-vbeln.
      IF sy-subrc = 0 .
        wa_final-vbeln = wa_vbak-vbeln.
        wa_final-erdat = wa_vbak-erdat.
        wa_final-erzet = wa_vbak-erzet.
        wa_final-ernam = wa_vbak-ernam.
        wa_final-vbtyp = wa_vbak-vbtyp.

        APPEND wa_final TO it_final.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

START-OF-SELECTION.

  " call class
  DATA(lo_result) = NEW lcl_final( ).
  CALL METHOD lo_result->display_details.

  IF it_final IS NOT INITIAL.

    TRY.
        CALL METHOD cl_salv_table=>factory
          EXPORTING
            list_display = if_salv_c_bool_sap=>false
          IMPORTING
            r_salv_table = DATA(salv_display)
          CHANGING
            t_table      = it_final.

        " Enable all standard functions
        salv_display->get_functions( )->set_all( abap_true ).

        " display table
        salv_display->display( ).

      CATCH cx_salv_msg .
    ENDTRY.

  ELSE.
    MESSAGE 'You have entered wrong sale doc no. ' TYPE 'E'.
  ENDIF.
