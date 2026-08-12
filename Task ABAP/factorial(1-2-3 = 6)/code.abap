*&---------------------------------------------------------------------*
*& Report Z_TASK_0301_Q2
*&---------------------------------------------------------------------*
*& DO = कितनी बार चलाना है पता है (DO p_num TIMES.) and WHILE = कब तक चलाना है इसकी condition पता है (WHILE lv_i <= p_num.)
*&---------------------------------------------------------------------*
REPORT z_task_0301_q2.

PARAMETERS p_num TYPE i.

DATA: lv_fact TYPE i VALUE 1.

START-OF-SELECTION.

  IF p_num < 0.

    WRITE: / 'Factorial is not possible for negative number'.

  ELSE.

    DO p_num TIMES.

      lv_fact = lv_fact * sy-index.

    ENDDO.

    SKIP.

    WRITE: / 'Number    :', p_num.
    WRITE: / 'Factorial :', lv_fact.

  ENDIF.
  
*  ---------------- OR -------------------------

PARAMETERS p_num TYPE i.

DATA: lv_fact TYPE i VALUE 1,
      lv_i    TYPE i VALUE 1.

START-OF-SELECTION.

  IF p_num < 0.

    WRITE: / 'Factorial is not possible for negative number'.

  ELSE.

    WHILE lv_i <= p_num.

      WRITE: / 'Iteration:', sy-index, 'Value:', lv_i.

      lv_fact = lv_fact * lv_i. " or  lv_fact = lv_fact * sy-index.
      lv_i = lv_i + 1.

    ENDWHILE.

    SKIP.

    WRITE: / 'Number    :', p_num.
    WRITE: / 'Factorial :', lv_fact.

  ENDIF.
