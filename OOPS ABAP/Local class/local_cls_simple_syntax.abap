*&---------------------------------------------------------------------*
*& Report Z_CALL_CLASS_2_LOCAL_CLASS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_CALL_CLASS_2_LOCAL_CLASS.

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
