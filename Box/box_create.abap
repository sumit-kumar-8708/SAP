*&---------------------------------------------------------------------*
*& Report ZTEST_2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZTEST_2.

* 1. Simple Box create
write: '1. Simple Box create'.
skip 2.

write: 10(40) sy-uline.
write: /10 sy-vline, 49 sy-vline.
write: /10 sy-vline, 49 sy-vline.
write: /10 sy-vline, 49 sy-vline.
write: /10 sy-vline, 49 sy-vline.
write: /10 sy-vline, 49 sy-vline.
write: /10(40) sy-uline.

Skip 4.

* 2. Four Box create in which some data at center of the box
write: '2. Four Box create in which some data at center of the box'.
skip 2.

write: 60(40) sy-uline.
write: /60 sy-vline, 99 sy-vline.
write: /60 sy-vline, 99 sy-vline.
write: /60 sy-vline, 99 sy-vline.
write: 75 sy-uname.
write: /60 sy-vline, 99 sy-vline.
write: /60 sy-vline, 99 sy-vline.
write: /60(40) sy-uline.

skip 4.

write: /10(40) sy-uline, 110(40) sy-uline.
write: /10 sy-vline, 49 sy-vline,110 sy-vline, 149 sy-vline.
write: /10 sy-vline, 49 sy-vline,110 sy-vline, 149 sy-vline.
write: /10 sy-vline, 49 sy-vline,110 sy-vline, 149 sy-vline.
write: 25 SY-UZEIT,125 sy-datum.
write: /10 sy-vline, 49 sy-vline,110 sy-vline, 149 sy-vline.
write: /10 sy-vline, 49 sy-vline,110 sy-vline, 149 sy-vline.
write: /10(40) sy-uline,110(40) sy-uline.

skip 4.

write: 60(40) sy-uline.
write: /60 sy-vline, 99 sy-vline.
write: /60 sy-vline, 99 sy-vline.
write: /60 sy-vline, 99 sy-vline.
write: 75 sy-langu.
write: /60 sy-vline, 99 sy-vline.
write: /60 sy-vline, 99 sy-vline.
write: /60(40) sy-uline.
