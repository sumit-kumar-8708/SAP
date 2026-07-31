*&---------------------------------------------------------------------*
*& Report Z_CALL_CLASS_2_LOCAL_CLASS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_CALL_CLASS_2_LOCAL_CLASS.

" EXAMPLE-1 simple local class

" Local Class Definition
CLASS lcl_employee DEFINITION.
  PUBLIC SECTION.
    METHODS: display_details.
    METHODS: display_name.
ENDCLASS.

" Local Class Implementation
CLASS lcl_employee IMPLEMENTATION.
  METHOD display_details.
    WRITE: / 'Employee Name: Sumit Kumar'.
    WRITE: / 'Department   : SAP ABAP'.
  ENDMETHOD.

  METHOD display_name.
    WRITE: / 'Employee Name: Raju Kumar'.
  ENDMETHOD.
ENDCLASS.

START-OF-SELECTION.

*DATA: lo_employee TYPE REF TO lcl_employee.
*CREATE OBJECT lo_employee.
data(lo_employee) = new lcl_employee( ).

CALL METHOD lo_employee->display_details.
CALL METHOD lo_employee->display_name.

" EXAMPLE-2 Local call with inline internal table declaration

" Selection Screen
PARAMETERS: p_vbeln TYPE vbeln_va.

" Local Class Definition
CLASS lcl_employee DEFINITION.
  PUBLIC SECTION.
    METHODS: display_details.
ENDCLASS.

" Local Class Implementation
CLASS lcl_employee IMPLEMENTATION.

  METHOD display_details.

    SELECT vbeln,
           erdat,
           erzet,
           ernam
      FROM vbak
      INTO TABLE @DATA(lt_vbak)
      WHERE vbeln = @p_vbeln.

    IF sy-subrc = 0.
      LOOP AT lt_vbak INTO DATA(ls_vbak).
        WRITE: / ls_vbak-vbeln,
                 ls_vbak-erdat,
                 ls_vbak-erzet,
                 ls_vbak-ernam.
      ENDLOOP.
    ELSE.
      WRITE: / 'No data found.'.
    ENDIF.

  ENDMETHOD.

ENDCLASS.

START-OF-SELECTION.
  DATA(lo_employee) = NEW lcl_employee( ).
  CALL METHOD lo_employee->display_details( ).

" EXample-3

PARAMETERS: p_vbeln TYPE vbeln_va.

CLASS lcl_employee DEFINITION.
  PUBLIC SECTION.
    METHODS:
      display_details
        IMPORTING
          p_vbeln TYPE vbeln_va
        EXPORTING
          v_vbeln TYPE vbeln_va
          v_erdat TYPE erdat
          v_erzet TYPE erzet
          v_ernam TYPE ernam.
ENDCLASS.

CLASS lcl_employee IMPLEMENTATION.

  METHOD display_details.

    SELECT SINGLE vbeln,
                  erdat,
                  erzet,
                  ernam
      FROM vbak
      INTO (@v_vbeln, @v_erdat, @v_erzet, @v_ernam)
      WHERE vbeln = @p_vbeln.

  ENDMETHOD.

ENDCLASS.

START-OF-SELECTION.

  DATA(lo_employee) = NEW lcl_employee( ).

  DATA: lv_vbeln TYPE vbeln_va,
        lv_erdat TYPE erdat,
        lv_erzet TYPE erzet,
        lv_ernam TYPE ernam.

  CALL METHOD lo_employee->display_details
    EXPORTING
      p_vbeln = p_vbeln
    IMPORTING
      v_vbeln   = lv_vbeln
      v_erdat   = lv_erdat
      v_erzet   = lv_erzet
      v_ernam   = lv_ernam.

  WRITE: / 'VBELN :', lv_vbeln.
  WRITE: / 'ERDAT :', lv_erdat.
  WRITE: / 'ERZET :', lv_erzet.
  WRITE: / 'ERNAM :', lv_ernam.
