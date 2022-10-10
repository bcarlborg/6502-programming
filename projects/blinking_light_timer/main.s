  .include '../../global_utilities/global_constants.h.s'

; ------------------------------
; variables in RAM
; ------------------------------

  .section ".zero_page_variables"

  .section ".variables"
  TIMER_COUNTER_10S_MS: .byte $FF,$FF
  BLINK_TIME: .byte $FF,$FF ; two bytes
  BLINK_STATE: .byte $FF

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
 lda #50
 sta TIMER_COUNTER_10S_MS
 lda #00
 sta TIMER_COUNTER_10S_MS + 1

 lda #1
 sta SCREEN_CURSOR_ROW
 lda #16
 sta SCREEN_CURSOR_POS

 lda 0
 sta BLINK_TIME
 sta BLINK_TIME + 1
 sta BLINK_STATE

rts

loop:
  .global loop

  jsr empty_line_1
  jsr empty_line_2
  jsr update_blink_state
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

  CLC           
  LDA TIMER_COUNTER_10S_MS
  ADC #10
  STA TIMER_COUNTER_10S_MS
  LDA TIMER_COUNTER_10S_MS + 1
  ADC #0
  STA TIMER_COUNTER_10S_MS + 1

  rts

;
; right button press handler
;
on_right_button_press:
  .global on_right_button_press

  CLC           
  LDA TIMER_COUNTER_10S_MS
  ADC #100
  STA TIMER_COUNTER_10S_MS
  LDA TIMER_COUNTER_10S_MS + 1
  ADC #0
  STA TIMER_COUNTER_10S_MS + 1

  rts

;
; down button press handler
;
on_down_button_press:
  .global on_down_button_press
  sec           
  lda TIMER_COUNTER_10S_MS
  sbc #10
  sta TIMER_COUNTER_10S_MS
  lda TIMER_COUNTER_10S_MS +1 
  sbc #0
  sta TIMER_COUNTER_10S_MS +1
  bcc on_down_button_press__underflow
  jmp on_down_button_press__exit

on_down_button_press__underflow:
  lda #0 
  sta TIMER_COUNTER_10S_MS
  sta TIMER_COUNTER_10S_MS+1

on_down_button_press__exit:
  rts

;
; left button press handler
;
on_left_button_press:
  .global on_left_button_press
  sec           
  lda TIMER_COUNTER_10S_MS
  sbc #100
  sta TIMER_COUNTER_10S_MS
  lda TIMER_COUNTER_10S_MS +1 
  sbc #00
  sta TIMER_COUNTER_10S_MS +1
  bcc on_left_button_press__underflow
  jmp on_left_button_press__exit

on_left_button_press__underflow:
  lda #0 
  sta TIMER_COUNTER_10S_MS
  sta TIMER_COUNTER_10S_MS+1

on_left_button_press__exit:
  rts

;
; action button handler
;
on_action_button_press:
  .global on_action_button_press
  lda #50
  sta TIMER_COUNTER_10S_MS
  lda #0
  sta TIMER_COUNTER_10S_MS + 1 
  rts


; ------------------------------
; ROUTINES
; ------------------------------
  .section '.routines'

print_current_delay_ms:
  lda TIMER_COUNTER_10S_MS
  sta PRINT_BASE_10_VALUE
  lda TIMER_COUNTER_10S_MS + 1
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
  lda #'0'
  sta (ADDR_ARG_1),Y
  iny
  lda #' '
  sta (ADDR_ARG_1),Y
  iny
  lda #'m'
  sta (ADDR_ARG_1),Y
  iny
  lda #'s'
  sta (ADDR_ARG_1),Y

  ldy #15
  lda BLINK_STATE
  beq print_current_delay_ms__blink_off
  bne print_current_delay_ms__blink_on
 
print_current_delay_ms__blink_on:
  lda #'#'
  sta SCREEN_OUT_2,Y
  jmp print_current_delay_ms__blink_on_off__exit

print_current_delay_ms__blink_off:
  lda #' '
  sta SCREEN_OUT_2,Y
  jmp print_current_delay_ms__blink_on_off__exit

print_current_delay_ms__blink_on_off__exit:
  rts



update_blink_state:
  lda TIMER_COUNTER_10S_MS  
  ora TIMER_COUNTER_10S_MS + 1
  beq update_blink_state__exit

  sec
  lda TICKS
  sbc BLINK_TIME
  sta TMP
  lda TICKS+1
  sbc BLINK_TIME+1
  sta TMP+1


  ; check if TIMER_COUNTER_10s_MS have passed
  ; check if TMP < TIMER_COUNTER_10s_MS
  ; if it is, then exit
  lda TMP
  cmp TIMER_COUNTER_10S_MS
  lda TMP + 1
  sbc TIMER_COUNTER_10S_MS + 1

  bcc update_blink_state__exit

  ; if so, then update the blink time
  lda TICKS
  sta BLINK_TIME
  lda TICKS + 1
  sta BLINK_TIME + 1

  ; toggle the blink state
  lda BLINK_STATE
  beq update_blink_state__blink_on
  bne update_blink_state__blink_off

update_blink_state__blink_on:
  lda #1
  sta BLINK_STATE
  jmp update_blink_state__exit

update_blink_state__blink_off:
  lda #0
  sta BLINK_STATE
  jmp update_blink_state__exit

update_blink_state__exit:
  rts 


