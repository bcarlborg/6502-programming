  .include '../../global_utilities/global_constants.h.s'

; ------------------------------
; variables in RAM
; ------------------------------

  .section ".zero_page_variables"

  .section ".variables"

; ------------------------------
; initialized data
; ------------------------------

  .section '.initialized_data'
  

  .section '.body'

; ------------------------------
; THE PROGRAM!
; ------------------------------
reset:
  .global reset
  rts

loop:
  .global loop
  rts

  .section '.body'

; ------------------------------
; BUTTON HANDLERS
; ------------------------------

; BUTTON 1
;
on_up_button_press:
  .global on_up_button_press
  lda SCREEN_CURSOR_ROW
  beq on_up_button_press__exit
  lda #0
  sta SCREEN_CURSOR_ROW
on_up_button_press__exit:
  rts

;
; right button press handler
;
on_right_button_press:
  .global on_right_button_press
  lda SCREEN_CURSOR_POS
  clc
  cmp #15
  beq on_right_button_press__exit
  inc SCREEN_CURSOR_POS
on_right_button_press__exit:
  .global on_right_button_press__exit
  rts

;
; down button press handler
;
on_down_button_press:
  .global on_down_button_press
  lda SCREEN_CURSOR_ROW
  bne on_down_button_press__exit 
  lda #1
  sta SCREEN_CURSOR_ROW
on_down_button_press__exit:
  rts

;
; left button press handler
;
on_left_button_press:
  .global on_left_button_press
  lda SCREEN_CURSOR_POS
  beq on_left_button_press__exit
  dec SCREEN_CURSOR_POS
on_left_button_press__exit:
  rts

;
; action button handler
;
on_action_button_press:
  .global on_action_button_press
  LDA SCREEN_CURSOR_ROW
  beq on_action_button_press___modify_first_row

on_action_button_press___modify_second_row:
  lda SCREEN_CURSOR_POS
  tay
  lda #'1'
  sta SCREEN_OUT_2,Y
  jmp on_action_button_press__exit

on_action_button_press___modify_first_row:
  lda SCREEN_CURSOR_POS
  tay
  lda #'1'
  sta SCREEN_OUT_1,Y

on_action_button_press__exit:
  rts


; ------------------------------
; ROUTINES
; ------------------------------

  .section '.routines'
