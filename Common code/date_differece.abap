REPORT Z_TASK_ASSIGNMENT_0701.

DATA: lv_date1 TYPE sy-datum VALUE '20260801',
      lv_time1 TYPE sy-uzeit VALUE '100000',
      lv_date2 TYPE sy-datum VALUE '20260802',
      lv_time2 TYPE sy-uzeit VALUE '143000',

      lv_difference TYPE i,
      lv_days       TYPE i,
      lv_hours      TYPE p DECIMALS 2.

*-----------------------------------------------------------------------
* Calculate Difference in Seconds
*1 Day = 24 × 60 × 60 = 86400 Seconds
*DIV is ABAP integer division operator. " 10 DIV 3 => 3
*-----------------------------------------------------------------------
lv_difference = ( ( lv_date2 - lv_date1 ) * 86400 )
              + ( lv_time2 - lv_time1 ).

*-----------------------------------------------------------------------
* Convert into Days and Hours
*-----------------------------------------------------------------------
lv_days  = lv_difference DIV 86400.
lv_hours = lv_difference / 3600.

*-----------------------------------------------------------------------
* Output
*-----------------------------------------------------------------------
WRITE: / 'Date 1          :', lv_date1,
       / 'Time 1          :', lv_time1,
       / 'Date 2          :', lv_date2,
       / 'Time 2          :', lv_time2,
       / '-------------------------------',
       / 'Difference(sec) :', lv_difference,
       / 'Days            :', lv_days,
       / 'Hours           :', lv_hours.
