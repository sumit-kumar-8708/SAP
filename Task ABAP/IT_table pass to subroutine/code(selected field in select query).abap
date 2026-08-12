*---------------------------------------------------------------------*
* Local Structure - same fields as SELECT
*---------------------------------------------------------------------*
TYPES: BEGIN OF ty_employee,
         id      TYPE ztestemployee-id,
         name    TYPE ztestemployee-name,
         salary  TYPE ztestemployee-salary,
         dept_id TYPE ztestemployee-dept_id,
       END OF ty_employee.

*---------------------------------------------------------------------*
* Internal Table
*---------------------------------------------------------------------*
DATA lt_employee TYPE TABLE OF ty_employee.

START-OF-SELECTION.

  "Read employee data from database table
  SELECT id,
         name,
         salary,
         dept_id
    FROM ztestemployee
    INTO TABLE @lt_employee.

  "Pass internal table to subroutine
  PERFORM increase_salary TABLES lt_employee.

  "Main program - print result
  LOOP AT lt_employee INTO DATA(ls_employee).

    WRITE: / 'ID       :', ls_employee-id,
           / 'Name     :', ls_employee-name,
           / 'Salary   :', ls_employee-salary,
           / 'Dept ID  :', ls_employee-dept_id.

    SKIP.

  ENDLOOP.


*---------------------------------------------------------------------*
* Subroutine
*---------------------------------------------------------------------*
FORM increase_salary TABLES p_lt_employee LIKE lt_employee.

  LOOP AT p_lt_employee INTO DATA(p_wa_employee).

    "Increase salary by 1000
    p_wa_employee-salary = p_wa_employee-salary + 1000.

    "Update internal table
    MODIFY p_lt_employee FROM p_wa_employee.

  ENDLOOP.

ENDFORM.
