  .include '../../global_utilities/global_constants.h.s'

; ------------------------------
; variables in RAM
; ------------------------------

  .section ".zero_page_variables"

  .section ".variables"
  TIMER_COUNTER_MS: .byte $FF,$FF

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
 lda #$BA
 sta TIMER_COUNTER_MS
 lda #$DC
 sta TIMER_COUNTER_MS + 1

 lda #1
 sta SCREEN_CURSOR_ROW
 lda #4
 sta SCREEN_CURSOR_POS

rts

loop:
  .global loop

  jsr empty_line_1
  jsr empty_line_2
  jsr print_current_delay_ms

  rts

  .section '.body'

; ------------------------------
; BUTTON HANDLERS
; ------------------------------

; BUTTON 1
;
on_up_button_press:
  .global on_up_button_press
  ldy TIMER_COUNTER_MS 
  iny
  sty TIMER_COUNTER_MS
  rts

;
; right button press handler
;
on_right_button_press:
  .global on_right_button_press
  ldy SCREEN_CURSOR_POS
  iny
  sty SCREEN_CURSOR_POS
  rts

;
; down button press handler
;
on_down_button_press:
  .global on_down_button_press
  lda SCREEN_CURSOR_ROW
  beq on_down_button_press__row_2
  jmp on_down_button_press__row_1

on_down_button_press__row_1:
  lda #0
  sta SCREEN_CURSOR_ROW
  rts

on_down_button_press__row_2:
  lda #1
  sta SCREEN_CURSOR_ROW
  rts

;
; left button press handler
;
on_left_button_press:
  .global on_left_button_press
  ldy SCREEN_CURSOR_POS
  dey
  sty SCREEN_CURSOR_POS
  rts

;
; action button handler
;
on_action_button_press:
  .global on_action_button_press
  rts


; ------------------------------
; ROUTINES
; ------------------------------
  .section '.routines'

print_current_delay_ms:
  lda TIMER_COUNTER_MS
  sta PRINT_BASE_10_VALUE
  lda TIMER_COUNTER_MS + 1
  sta PRINT_BASE_10_VALUE + 1

  jsr write_base_10_number_line_1

  lda #(<SCREEN_OUT_1)
  sta ADDR_ARG_1
  lda #(>SCREEN_OUT_1)
  sta ADDR_ARG_1 + 1

  ; loop until we find the first space
  ldy #0
print_current_delay_ms__find_space__inner:
  lda (ADDR_ARG_1),Y   ; get the character to write
  clc
  cmp #' '
  beq print_current_delay_ms__find_space__exit
  iny
  jmp print_current_delay_ms__find_space__inner

print_current_delay_ms__find_space__exit:
  ; increment y one more time
  iny
  lda #'m'
  sta (ADDR_ARG_1),Y
  iny
  lda #'s'
  sta (ADDR_ARG_1),Y

  rts

