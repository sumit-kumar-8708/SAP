START-OF-SELECTION.

  "Read employee data from database table
  SELECT *
    FROM ztestemployee
    INTO TABLE @DATA(lt_employee).

  "Pass internal table to subroutine
  PERFORM increase_salary TABLES lt_employee.

  "Main program se print
  LOOP AT lt_employee INTO DATA(ls_employee).

    WRITE: / 'ID       :', ls_employee-id,
           / 'Name     :', ls_employee-name,
           / 'Salary   :', ls_employee-salary,
           / 'Dept ID  :', ls_employee-dept_id.

    SKIP.

  ENDLOOP.


FORM increase_salary TABLES p_lt_employee STRUCTURE ztestemployee.

  LOOP AT p_lt_employee INTO DATA(p_wa_employee).

    " increase salary 1000 for every employee
    p_wa_employee-salary = p_wa_employee-salary + 1000.

    MODIFY p_lt_employee FROM p_wa_employee. " now modify internal table

  ENDLOOP.

ENDFORM.
