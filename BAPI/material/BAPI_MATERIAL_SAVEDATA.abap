*&---------------------------------------------------------------------*
*& Report Z_BAPI_MATERIAL_1
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT z_bapi_material_1.

TYPES: BEGIN OF ty_file,
         matnr TYPE matnr,
         mbrsh TYPE mbrsh,   "Industry Sector
         mtart TYPE mtart,
         matkl TYPE matkl,
         maktx TYPE maktx,
         meins TYPE meins,
       END OF ty_file.


DATA: gt_file TYPE TABLE OF ty_file,
      gs_file TYPE ty_file.

DATA: ls_head    TYPE bapimathead,
      ls_client  TYPE bapi_mara,
      ls_clientx TYPE bapi_marax,
      lt_desc    TYPE TABLE OF bapi_makt,
      ls_desc    TYPE bapi_makt,
      lt_return  TYPE TABLE OF bapiret2,
      ls_return  TYPE bapiret2.

*PARAMETERS: p_file TYPE rlgrap-filename.
PARAMETERS: p_file TYPE localfile.


*-----------------------------------------------------------------------
* F4 Help
*-----------------------------------------------------------------------
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.

  CALL FUNCTION 'F4_FILENAME'
    IMPORTING
      file_name = p_file.

*-----------------------------------------------------------------------
* START
*-----------------------------------------------------------------------
START-OF-SELECTION.
  DATA: lv_file TYPE string.
  lv_file = p_file.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename            = lv_file
      has_field_separator = 'X'
    TABLES
      data_tab            = gt_file.

*-----------------------------------------------------------------------
* Create Material
*-----------------------------------------------------------------------
  LOOP AT gt_file INTO gs_file.

    CLEAR:
      ls_head,
      ls_client,
      ls_clientx,
      ls_desc,
      ls_return.

    CLEAR lt_return.
    REFRESH lt_desc.

* Material Header
    ls_head-material   = gs_file-matnr.
*    ls_head-ind_sector = 'M'.     "Industry Sector
    ls_head-ind_sector = gs_file-mbrsh.     "Industry Sector
    ls_head-matl_type  = gs_file-mtart.
    ls_head-basic_view = 'X'.

* Client Data
    ls_client-base_uom   = gs_file-meins.
    ls_client-matl_group = gs_file-matkl.
*    ls_client-matl_type  = gs_file-mtart.

* X Structure
    ls_clientx-base_uom   = 'X'.
    ls_clientx-matl_group = 'X'.
*    ls_clientx-matl_type  = 'X'.

* Material Description
    ls_desc-langu = sy-langu.
    ls_desc-matl_desc = gs_file-maktx.

    APPEND ls_desc TO lt_desc.


    CALL FUNCTION 'BAPI_MATERIAL_SAVEDATA'
      EXPORTING
        headdata            = ls_head
        clientdata          = ls_client
        clientdatax         = ls_clientx
*       materialdescription = ls_desc
*       materialdescriptionx = ls_descx
      TABLES
        materialdescription = lt_desc
        returnmessages      = lt_return.



    READ TABLE lt_return INTO ls_return
     WITH KEY type = 'E'.

    IF sy-subrc <> 0.
      READ TABLE lt_return INTO ls_return
           WITH KEY type = 'A'.
    ENDIF.



    IF sy-subrc = 0.

      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

      WRITE:/ 'Error :',
              gs_file-matnr,
              ls_return-message.

    ELSE.

      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = 'X'.

      WRITE:/ 'Success :',
              gs_file-matnr.

    ENDIF.

  ENDLOOP.

*  LOOP AT lt_return INTO ls_return.
*
*    WRITE: / ls_return-type,
*             ls_return-id,
*             ls_return-number,
*             ls_return-message.
*
*  ENDLOOP.
