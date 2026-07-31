*&---------------------------------------------------------------------*
*& Report Z_CALL_CLASS_2_LOCAL_CLASS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_CALL_CLASS_2_LOCAL_CLASS.

" EX-1 simple local class

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

" EX-2 Local call with inline internal table declaration

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
