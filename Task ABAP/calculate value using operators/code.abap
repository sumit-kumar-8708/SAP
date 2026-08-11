
REPORT Z_TASK_0301_Q1.
PARAMETERS:
  p_num1 TYPE i,
  p_num2 TYPE i,
  p_oper TYPE c LENGTH 1.

DATA lv_result TYPE p LENGTH 10 DECIMALS 2.

START-OF-SELECTION.

  CASE p_oper.

    WHEN '+'.

      lv_result = p_num1 + p_num2.

    WHEN '-'.

      lv_result = p_num1 - p_num2.

    WHEN '*'.

      lv_result = p_num1 * p_num2.

    WHEN '/'.

      IF p_num2 = 0.
        MESSAGE e002(ZMSG_SUMIT).
      ENDIF.

      lv_result = p_num1 / p_num2.

    WHEN OTHERS.

      MESSAGE e001(ZMSG_SUMIT).

  ENDCASE.


  "Output
  WRITE: / '=============================='.
  WRITE: / '       CALCULATOR RESULT'.
  WRITE: / '=============================='.

  SKIP.

  WRITE: / 'First Number  :', p_num1.
  WRITE: / 'Second Number :', p_num2.
  WRITE: / 'Operator      :', p_oper.

  ULINE.

  WRITE: / 'Result        :', lv_result.

  NEW-LINE.

  WRITE: / '=============================='.
