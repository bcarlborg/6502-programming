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

; counter of the number of times the ca1 irq has been triggered
IRQ_COUNTER: .byte $FF,$FF ; two bytes

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
  ; jsr process_button_2_press
  ; jsr process_button_3_press
  ; jsr process_button_4_press
  
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

on_button_1_press:
  ; increment our IRQ counter
  inc IRQ_COUNTER
  bne on_button_1_press__inc_counter_over
  inc IRQ_COUNTER + 1
on_button_1_press__inc_counter_over:
  rts

on_button_2_press:
  rts

on_button_3_press:
  rts

on_button_4_press:
  rts


  .section '.routines'

; ------------------------------
; functional sub routines
; ------------------------------

clear_screen_and_print_irq_counter:
  sec
  lda TICKS
  sbc FRAME_TIME

  ; check if 50 ms have passed
  cmp #5

  ; if not exit
  bcc clear_screen_and_print_irq_counter

  ; if so, then update frame time and continue
  lda TICKS
  sta FRAME_TIME

  jsr lcd_display_return_home

  ; print a number from rom to the screen
  ; ensure no interrupts can happen while we are
  ; in the loop
  sei
  lda IRQ_COUNTER
  sta PRINT_BASE_10_VALUE
  lda IRQ_COUNTER + 1
  sta PRINT_BASE_10_VALUE + 1
  cli
  jsr lcd_display_write_base_10_number


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

  ; initialize our irq counter
  lda #0
  sta IRQ_COUNTER
  sta IRQ_COUNTER + 1

  lda #-1
  sta CA1_DEBOUNCE_DIABLE_TICKER

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

process_button_1_press:
  lda BUTTON_1_PRESSED
  beq process_button_1_press__exit
  
  jsr on_button_1_press

  ; mark button 1 as processed
  lda #0
  sta BUTTON_1_PRESSED

process_button_1_press__exit:
  rts

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
  ; tax ; save value for later
  
  and #%00000001
  beq irq__cai__exit
  
  ; mark button 1 as pressed
  lda #1
  sta BUTTON_1_PRESSED

irq__cai__exit:
  jmp irq__exit

irq__exit:
  pla
  rti

  .section '.vectors'
  .word nmi            ; unused handler
  .word reset_harness  ; our program
  .word irq            ; main irq handler
