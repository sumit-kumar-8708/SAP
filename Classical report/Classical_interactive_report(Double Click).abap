
* Classical Interactive Report When user Double Click on first list then Second List Show

REPORT z_interactivereport_1.

TYPES: BEGIN OF ty_vbak,
         vbeln TYPE vbak-vbeln,
         erdat TYPE vbak-erdat,
         auart TYPE vbak-auart,
       END OF ty_vbak,

       BEGIN OF ty_vbap,
         vbeln TYPE vbap-vbeln,
         posnr TYPE vbap-posnr,
         matnr TYPE vbap-matnr,
         arktx TYPE vbap-arktx,
         netpr TYPE vbap-netpr,
       END OF ty_vbap.

DATA: gt_vbak  TYPE TABLE OF ty_vbak,
      gw_vbak  TYPE ty_vbak,
      gt_vbap  TYPE TABLE OF ty_vbap,
      gw_vbap  TYPE ty_vbap,
      d_vbeln  TYPE vbak-vbeln, " variable declare for select-option
      lv_vbeln TYPE vbak-vbeln,
      v_field  TYPE string,
      v_value  TYPE string.


SELECT-OPTIONS s_vbeln FOR d_vbeln.


START-OF-SELECTION.
  PERFORM get_data_vbak.

AT LINE-SELECTION.

  GET CURSOR FIELD v_field VALUE v_value.

  lv_vbeln = v_value.

  PERFORM conversion_input CHANGING lv_vbeln.

  PERFORM get_data_vbap USING lv_vbeln.

FORM get_data_vbak .

  SELECT vbeln
    erdat
    auart
    INTO TABLE gt_vbak
    FROM vbak
    WHERE vbeln IN s_vbeln.

  LOOP AT gt_vbak INTO gw_vbak.
    IF sy-subrc = 0.
      WRITE:/ gw_vbak-vbeln,
      gw_vbak-erdat,
      gw_vbak-auart.
    ENDIF.

  ENDLOOP.

ENDFORM.

FORM get_data_vbap  USING    p_v_value TYPE vbak-vbeln.

  SELECT vbeln
   posnr
   matnr
   arktx
   netpr
   INTO TABLE gt_vbap
   FROM vbap
   WHERE vbeln = p_v_value.

  LOOP AT gt_vbap INTO gw_vbap.
    IF sy-subrc = 0.
      WRITE:/ gw_vbap-vbeln,
      gw_vbap-posnr,
      gw_vbap-matnr,
      gw_vbap-arktx,
      gw_vbap-netpr.
    ENDIF.
  ENDLOOP.

ENDFORM.

FORM conversion_input CHANGING p_vbeln TYPE vbak-vbeln.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      input  = p_vbeln
    IMPORTING
      output = p_vbeln.

ENDFORM.
