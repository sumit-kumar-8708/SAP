 PERFORM read_from_as.

 FORM read_from_as.

  DATA: lv_file TYPE string,
        lv_line TYPE string.

  DATA: gt_file TYPE TABLE OF string,
        gw_file TYPE string.

  lv_file = 'E:\usr\sap\TEC\D00\data\test_2807.txt'. " You can get this path from the AL11 screen

  OPEN DATASET lv_file FOR INPUT IN TEXT MODE ENCODING DEFAULT. " INPUT MODE => means opening the file in Read mode.

  IF sy-subrc <> 0.
    MESSAGE 'Unable to open file' TYPE 'E'.
  ENDIF.

  DO.

    CLEAR lv_line.

    READ DATASET lv_file INTO lv_line.

    IF sy-subrc <> 0.
      EXIT.
    ENDIF.

    APPEND lv_line TO gt_file.

  ENDDO.

  CLOSE DATASET lv_file.

  LOOP AT gt_file INTO gw_file.
    WRITE:/ gw_file.
  ENDLOOP.

ENDFORM.
