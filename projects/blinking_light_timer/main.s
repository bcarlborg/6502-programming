  .include '../../global_utilities/global_constants.h.s'

; ------------------------------
; variables in RAM
; ------------------------------

  .section ".zero_page_variables"
; helper variable for passing a 16 bit
; argument to a function
ADDR_ARG_1: .byte $FF,$FF; 2 bytes
  .global ADDR_ARG_1

  .section ".variables"
; general purpose temporary variable!
; don't expect it to be preserved accross
; function calls
TMP: .byte $FF,$FF ; 2 bytes
  .global TMP

; count of time driven by timer 1. Incremented every 10 ms
TICKS: .byte $FF,$FF,$FF,$FF ; 4 bytes

; time of the last LED blink. Is compared against ticks in
; our prorgam loop to decide when to toggle the led
BLINK_LED_BLINK_TIME: .byte $FF ; 1 byte

; time of the last lcd screen refresh. Is compared against ticks in
; our prorgam loop to decide when to refresh the screen
FRAME_TIME: .byte $FF; 1 byte

; initialize to -1
; when set to a positive value, the ca1 interrupts are disabled
; and the variable is decremented every 10ms until it is 0
; when it is zero, ca1 interrupts are re-enabled, and the variable
; is set to -1
CA1_DEBOUNCE_DIABLE_TICKER: .byte $FF ; 1 byte

; A variable indicating if a button was pressed
; will be set to one when pressed, once the button
; press is done being processed, it can be set to 0
BUTTON_1_PRESSED: .byte $FF ; 1 byte

; A variable indicating if a button was pressed
; will be set to one when pressed, once the button
; press is done being processed, it can be set to 0
BUTTON_2_PRESSED: .byte $FF ; 1 byte

; A variable indicating if a button was pressed
; will be set to one when pressed, once the button
; press is done being processed, it can be set to 0
BUTTON_3_PRESSED: .byte $FF ; 1 byte

; A variable indicating if a button was pressed
; will be set to one when pressed, once the button
; press is done being processed, it can be set to 0
BUTTON_4_PRESSED: .byte $FF ; 1 byte

; A variable indicating if a button was pressed
; will be set to one when pressed, once the button
; press is done being processed, it can be set to 0
BUTTON_5_PRESSED: .byte $FF ; 1 byte


; ------------------------------
; initialized data
; ------------------------------

  .section '.initialized_data'
basic_print_test__message: .asciiz "Hi!"
basic_print_test__number: .word 42
  

  .section '.body'
; ------------------------------
; THE HARNESS!
; ------------------------------

reset_harness:
  ; set intterrupts as allowed on 6502
  cli

  ; diable all via interrupts, enable then as needed after
  jsr via_set_all_interrupts_off

  ; enable interrupts for buttons
  jsr via_initialize_button_interrupts

  ; initialize timers for blinking LED
  jsr via_initialize_timer1_tick_timer


  ; initialize variables
  jsr initialize_variables

  ; print a string to the screen
  jsr via_initialize_ports_for_display
  jsr lcd_display_initialize

  jsr reset
 

loop_harness:
  jsr process_button_1_press
  jsr process_button_2_press
  jsr process_button_3_press
  jsr process_button_4_press
  jsr process_button_5_press
  
  ; jsr print_data_to_lcd_screen
  
  jsr clear_screen_and_print_irq_counter

  jsr loop
  jmp loop_harness

; ------------------------------
; THE PROGRAM!
; ------------------------------
reset:
  rts

loop:
  rts

;
; BUTTON 1
;
on_up_button_press:
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
  lda SCREEN_CURSOR_POS
  clc
  cmp #15
  beq on_right_button_press__exit
  inc SCREEN_CURSOR_POS
on_right_button_press__exit:
  rts

;
; down button press handler
;
on_down_button_press:
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
  lda SCREEN_CURSOR_POS
  beq on_left_button_press__exit
  dec SCREEN_CURSOR_POS
on_left_button_press__exit:
  rts

;
; action button handler
;
on_action_button_press:
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


  .section '.routines'

; ------------------------------
; functional sub routines
; ------------------------------


clear_screen_and_print_irq_counter:
  sec
  lda TICKS
  sbc FRAME_TIME

  ; check if 250 ms have passed
  cmp #25

  ; if not exit
  bcc clear_screen_and_print_irq_counter__exit

  ; if so, then update frame time and continue
  lda TICKS
  sta FRAME_TIME

  ; update the screen
  jsr lcd_display_clear_and_write_out
  rts 


clear_screen_and_print_irq_counter__exit:
  rts

; ------------------------------
; initialization sub routines
; ------------------------------

initialize_variables:
  lda #0
  sta FRAME_TIME

  lda #0
  sta BLINK_LED_BLINK_TIME

  lda #-1
  sta CA1_DEBOUNCE_DIABLE_TICKER

  lda #41
  sta SCREEN_CURSOR_POS

  lda #' '
  STA SCREEN_OUT_1
  STA SCREEN_OUT_1 + 1
  STA SCREEN_OUT_1 + 2
  STA SCREEN_OUT_1 + 3
  STA SCREEN_OUT_1 + 4
  STA SCREEN_OUT_1 + 5
  STA SCREEN_OUT_1 + 6
  STA SCREEN_OUT_1 + 7
  STA SCREEN_OUT_1 + 8
  STA SCREEN_OUT_1 + 9
  STA SCREEN_OUT_1 + 10
  STA SCREEN_OUT_1 + 11
  STA SCREEN_OUT_1 + 12
  STA SCREEN_OUT_1 + 13
  STA SCREEN_OUT_1 + 14
  STA SCREEN_OUT_1 + 15

  STA SCREEN_OUT_2
  STA SCREEN_OUT_2 + 1
  STA SCREEN_OUT_2 + 2
  STA SCREEN_OUT_2 + 3
  STA SCREEN_OUT_2 + 4
  STA SCREEN_OUT_2 + 5
  STA SCREEN_OUT_2 + 6
  STA SCREEN_OUT_2 + 7
  STA SCREEN_OUT_2 + 8
  STA SCREEN_OUT_2 + 9
  STA SCREEN_OUT_2 + 10
  STA SCREEN_OUT_2 + 11
  STA SCREEN_OUT_2 + 12
  STA SCREEN_OUT_2 + 13
  STA SCREEN_OUT_2 + 14
  STA SCREEN_OUT_2 + 15

  lda #0
  sta SCREEN_CURSOR_ROW
  lda #0
  sta SCREEN_CURSOR_POS
  rts

; todo, have this function read exisitng values and or to ensure
; we don't overwrite too many times
via_initialize_ports_for_display:
  ; set data direction of ports A and B
  lda #%11111111 ; set all of port B to output
  sta VIA_DDR_B
  lda #%11100000 ; set top 3 bits and last bit of port A to output
  sta VIA_DDR_A
  rts

lcd_display_initialize:
  ; tell the display number of lines etc
  jsr lcd_display_function_set
  jsr lcd_display_function_set

  ; clear the display
  jsr lcd_display_clear_display

  ; set the entry mode on the display
  jsr lcd_display_entry_mode_set

  ; turn the display on 
  jsr lcd_display_display_on

  rts

via_set_all_interrupts_off:
  lda #%01111111
  sta VIA_IER
  rts

via_initialize_button_interrupts:
  ; set intterupts on with MSB
  ; set CA1 interrupts on with a[1]
  lda #%10000010
  sta VIA_IER

  ; setting PCR register to 1 gives us
  ; positive edge interrupts on CA1
  lda #1
  sta VIA_PCR

  lda #0
  sta BUTTON_1_PRESSED
  sta BUTTON_2_PRESSED
  sta BUTTON_3_PRESSED
  sta BUTTON_4_PRESSED
  sta BUTTON_5_PRESSED

  rts


via_initialize_timer1_tick_timer:
  ; initialize ticks to 0
  lda #0
  sta TICKS
  sta TICKS + 1
  sta TICKS + 2
  sta TICKS + 3

  ; turn on interrupts for timer 1
  lda #%11000000
  sta VIA_IER

  ; use ACR to set timer 1 to free run mode
  lda #%01000000
  sta VIA_ACR


  ; set timer interval to:
  ; 10 ms = 10,000 micro seconds = $2710 micro seconds
  lda #$27
  sta VIA_T1_CL
  lda #$10

  sta VIA_T1_CH
  rts

; ------------------------------
; Button Interrup Helpers
; ------------------------------

;
; BUTTON 1
;
process_button_1_press:
  lda BUTTON_1_PRESSED
  beq process_button_1_press__exit
  
  jsr on_up_button_press

  ; mark button 1 as processed
  lda #0
  sta BUTTON_1_PRESSED

process_button_1_press__exit:
  rts

;
; BUTTON 2
;
process_button_2_press:
  lda BUTTON_2_PRESSED
  beq process_button_2_press__exit
  
  jsr on_right_button_press

  ; mark button 1 as processed
  lda #0
  sta BUTTON_2_PRESSED

process_button_2_press__exit:
  rts

;
; BUTTON 3
;
process_button_3_press:
  lda BUTTON_3_PRESSED
  beq process_button_3_press__exit
  
  jsr on_down_button_press

  ; mark button 3 as processed
  lda #0
  sta BUTTON_3_PRESSED

process_button_3_press__exit:
  rts

;
; BUTTON 4
;
process_button_4_press:
  lda BUTTON_4_PRESSED
  beq process_button_4_press__exit
  
  jsr on_left_button_press

  ; mark button 4 as processed
  lda #0
  sta BUTTON_4_PRESSED

process_button_4_press__exit:
  rts

;
; BUTTON 5
;
process_button_5_press:
  lda BUTTON_5_PRESSED
  beq process_button_5_press__exit
  
  jsr on_action_button_press

  ; mark button 5 as processed
  lda #0
  sta BUTTON_5_PRESSED

process_button_5_press__exit:
  rts


;
; IRQ Handlers
;

nmi:
  rti

irq:
  pha

  ; figure out which interrupts we need to service
  
  ; Timer 1 interrupt
  lda VIA_IFR
  and #%01000000
  bne irq__timer_1

  ; Timer CA1 interrupt
  lda VIA_IFR
  and #%00000010
  bne irq__ca1

  jmp irq__exit

irq__timer_1:
  ; clear the timer 1 interrupt
  bit VIA_T1_CL

  inc TICKS
  bne irq__timer_1__post_ticks
  inc TICKS + 1
  bne irq__timer_1__post_ticks
  inc TICKS + 2
  bne irq__timer_1__post_ticks
  inc TICKS + 3
irq__timer_1__post_ticks:

  ; check if we need to update our ca1 disable timers
  ; if CA1_DEBOUNCE_DIABLE_TICKER is -1, do nothing
  lda CA1_DEBOUNCE_DIABLE_TICKER
  sec
  cmp #0
  bcc irq__timer_1__post_ca1_toggle

  ; if it is zero, re-enable interrupts
  beq irq__timer_1__ca1_interrupt_enable

  ; if it is greater than zero, decrement the counter
  bcs irq__timer_1__ca1_interrupt_disable_decrement
  jmp irq__timer_1__post_ca1_toggle

irq__timer_1__ca1_interrupt_enable:
  ; enable ca1 interrupts again
  lda #%10000010
  sta VIA_IER

  ; set debounce counter to -1 so we don't keep disabling
  lda #-1
  sta CA1_DEBOUNCE_DIABLE_TICKER
  jmp irq__timer_1__post_ca1_toggle

irq__timer_1__ca1_interrupt_disable_decrement:
  dec CA1_DEBOUNCE_DIABLE_TICKER
  jmp irq__timer_1__post_ca1_toggle

irq__timer_1__post_ca1_toggle:

irq__timer_1__exit:
  jmp irq__exit

irq__ca1:
  ; disable ca1 interrupts
  lda #%00000010
  sta VIA_IER

  ; disable ca1 interrupts for 370 ms
  lda #37
  sta CA1_DEBOUNCE_DIABLE_TICKER

  ; clear the interrupt
  lda VIA_PORT_A
  tax              ; save value for later
  
  and #%00000001
  beq irq__cai__button_2_check
  
  ; mark button 1 as pressed
  lda #1
  sta BUTTON_1_PRESSED
  jmp irq__cai__exit

irq__cai__button_2_check:
  txa
  and #%00000010
  beq irq__cai__button_3_check

  ; mark button 2 as pressed
  lda #1
  sta BUTTON_2_PRESSED
  jmp irq__cai__exit

irq__cai__button_3_check:
  txa
  and #%00000100
  beq irq__cai__button_4_check

  ; mark button 3 as pressed
  lda #1
  sta BUTTON_3_PRESSED
  jmp irq__cai__exit

irq__cai__button_4_check:
  txa
  and #%00001000
  beq irq__cai__button_5_check

  ; mark button 4 as pressed
  lda #1
  sta BUTTON_4_PRESSED
  jmp irq__cai__exit

irq__cai__button_5_check:
  txa
  and #%00010000
  beq irq__cai__exit

  ; mark button 5 as pressed
  lda #1
  sta BUTTON_5_PRESSED

  jmp irq__cai__exit

irq__cai__exit:
  jmp irq__exit

irq__exit:
  pla
  rti

  .section '.vectors'
  .word nmi            ; unused handler
  .word reset_harness  ; our program
  .word irq            ; main irq handler
