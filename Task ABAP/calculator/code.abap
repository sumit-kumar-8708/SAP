*Copy program number 1. Now add another operator called '%' (percentage). Now perform all operations like (+, - etc) in separate subroutines in the program.
*Use the changing parameter for returning values.

REPORT Z_TASK_0301_Q5.

*---------------------------------------------------------------------*
* Selection Screen
*---------------------------------------------------------------------*
PARAMETERS:
  p_num1 TYPE i,
  p_num2 TYPE i,
  p_oper TYPE c LENGTH 1.

*---------------------------------------------------------------------*
* Data
*---------------------------------------------------------------------*
DATA lv_result TYPE p LENGTH 10 DECIMALS 2.

*---------------------------------------------------------------------*
* Main Logic
*---------------------------------------------------------------------*
START-OF-SELECTION.

  CASE p_oper.

    WHEN '+'.

      PERFORM addition CHANGING lv_result.

    WHEN '-'.

      PERFORM subtraction CHANGING lv_result.

    WHEN '*'.

      PERFORM multiplication CHANGING lv_result.

    WHEN '/'.

      IF p_num2 = 0.
        MESSAGE e002(zcalc).
      ENDIF.

      PERFORM division CHANGING lv_result.

    WHEN '%'.

      PERFORM percentage CHANGING lv_result.

    WHEN OTHERS.

      MESSAGE e001(zcalc).

  ENDCASE.


*---------------------------------------------------------------------*
* Output
*---------------------------------------------------------------------*
  WRITE: / TEXT-005.

  ULINE.

  WRITE: / TEXT-001, ':', p_num1.
  WRITE: / TEXT-002, ':', p_num2.
  WRITE: / TEXT-003, ':', p_oper.

  SKIP.

  WRITE: / TEXT-004, ':', lv_result.

  NEW-LINE.

  ULINE.


*---------------------------------------------------------------------*
* Addition
*---------------------------------------------------------------------*
FORM addition CHANGING cv_result TYPE p.

  cv_result = p_num1 + p_num2.

ENDFORM.


*---------------------------------------------------------------------*
* Subtraction
*---------------------------------------------------------------------*
FORM subtraction CHANGING cv_result TYPE p.

  cv_result = p_num1 - p_num2.

ENDFORM.


*---------------------------------------------------------------------*
* Multiplication
*---------------------------------------------------------------------*
FORM multiplication CHANGING cv_result TYPE p.

  cv_result = p_num1 * p_num2.

ENDFORM.


*---------------------------------------------------------------------*
* Division
*---------------------------------------------------------------------*
FORM division CHANGING cv_result TYPE p.

  cv_result = p_num1 / p_num2.

ENDFORM.


*---------------------------------------------------------------------*
* Percentage
*---------------------------------------------------------------------*
FORM percentage CHANGING cv_result TYPE p.

  cv_result = ( p_num1 * p_num2 ) / 100.

ENDFORM.
