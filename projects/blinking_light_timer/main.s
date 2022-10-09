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
test_string: .asciiz "the answer is:"
  

  .section '.body'

; ------------------------------
; THE PROGRAM!
; ------------------------------
reset:
 .global reset
  
  lda #(<test_string)
  sta ADDR_ARG_1
  
  lda #(>test_string)
  sta ADDR_ARG_1 + 1
  jsr write_zero_terminated_string_line_1

  lda #42
  sta PRINT_BASE_10_VALUE
  lda #$00
  sta PRINT_BASE_10_VALUE + 1
  jsr write_base_10_number_line_2

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
  rts

;
; right button press handler
;
on_right_button_press:
  .global on_right_button_press
  rts

;
; down button press handler
;
on_down_button_press:
  .global on_down_button_press
  rts

;
; left button press handler
;
on_left_button_press:
  .global on_left_button_press
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
