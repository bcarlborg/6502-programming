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
; don't expect it to be initialized before using it
; and don't expect it to be preserved accross
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

; ------------------------------
; initialized data
; ------------------------------

  .section '.initialized_data'
basic_print_test__message: .asciiz "Hi!"
basic_print_test__number: .word 42


; ------------------------------
; THE PROGRAM!
; ------------------------------
  

  .section '.body'
reset:
  ; set intterrupts as allowed on 6502
  cli

  ; diable all via interrupts, enable then as needed after
  jsr via_set_all_interrupts_off

  ; enable interrupts on the ca1 line of the VIA
  jsr via_initialize_ca1_interrupts

  ; initialize timers for blinking LED
  jsr via_initialize_timer1_tick_timer

  ; initialize variables
  jsr initialize_variables

  ; print a string to the screen
  jsr via_initialize_ports_for_display
  jsr lcd_display_initialize
 
  ; jsr basic_print_test


loop:
  jsr clear_screen_and_print_irq_counter
  jsr blink_led
  jmp loop


  .section '.routines'

; ------------------------------
; functional sub routines
; ------------------------------

blink_led:
  sec
  lda TICKS
  sbc BLINK_LED_BLINK_TIME

  ; check if 250 ms have passed
  cmp #25

  ; if not, exit
  bcc blink_led__no_blink

  ; if so store lowest byte of ticks as new toggle time
  lda TICKS
  sta BLINK_LED_BLINK_TIME

  ; toggle the lowest bit on port a
  lda VIA_PORT_A
  eor #%00000001
  sta VIA_PORT_A


blink_led__no_blink:
  rts

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

basic_print_test:
  lda #(<basic_print_test__message)
  sta ADDR_ARG_1
 
  lda #(>basic_print_test__message)
  sta ADDR_ARG_1 + 1
  
  jsr lcd_display_write_zero_terminated_string

  lda #" "
  jsr lcd_display_write_character

  ; print a number from rom to the screen
  lda basic_print_test__number
  sta PRINT_BASE_10_VALUE
  lda basic_print_test__number + 1
  sta PRINT_BASE_10_VALUE + 1
  jsr lcd_display_write_base_10_number

  lda #" "
  jsr lcd_display_write_character

  ; dynamically print a number from rom to the screen
  lda #$CD
  sta PRINT_BASE_10_VALUE
  lda #$AB
  sta PRINT_BASE_10_VALUE + 1
  jsr lcd_display_write_base_10_number
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

via_initialize_ports_for_display:
  ; set data direction of ports A and B
  lda #%11111111 ; set all of port B to output
  sta VIA_DDR_B
  lda #%11100001 ; set top 3 bits and last bit of port A to output
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

via_initialize_ca1_interrupts:
  ; set intterupts on with MSB
  ; set CA1 interrupts on with a[1]
  lda #%10000010
  sta VIA_IER

  ; setting PCR register to 0 gives us
  ; negative edge interrupts on CA1
  lda #0
  sta VIA_PCR

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

  ; increment our cunter
  inc IRQ_COUNTER
  bne irq__cai__exit
  inc IRQ_COUNTER + 1

irq__cai__exit:
  jmp irq__exit

irq__exit:
  pla
  rti

  .section '.vectors'
  .word nmi
  .word reset  ; our program
  .word irq    ; unused interrupt vector
