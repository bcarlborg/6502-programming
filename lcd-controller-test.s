;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;     =======================================
;     Addr space
;     =======================================
;     ------
;     $0000 |
;     $1000 | -- V65C22 VIA
;     $2000 |
;     $3000 |
;     ------
;     $4000
;     $5000
;     ------
;     $6000 | -- V65C22 VIA
;     ------
;     $7000
;     $8000
;     $9000
;     $A000
;     $B000
;     $C000
;     $D000
;     ------
;     $E000 | -- 28C64B EEPROM
;     $FFFF |
;     ------
;
;     =======================================
;     65C22 VIA to HD44780U LCD Display
;     =======================================
;
;     VIA_PORT_B[0..7] --> LCD controlelr D[0..7]
;     VIA_PORT_A[0]    --> LCD controller enable bit
;     VIA_PORT_A[1]    --> LCD controller R/W bit
;     VIA_PORT_A[2]    --> LCD controller RS bit
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; ------------------------------
; constants
; ------------------------------

; 65C22 to HD44780U
; lcd enable bit
VIA_PORT_A_LCD_E_BIT = %10000000
; lcd read write bit
VIA_PORT_A_LCD_RW_BIT = %01000000
; lcd register select bit
VIA_PORT_A_LCD_RS_BIT = %00100000

; 65C22 VIA CONSTANTS
; via porta a and b
VIA_PORT_B = $6000
VIA_PORT_A = $6001
; port a and b data direction registers
VIA_DDR_B = $6002   
VIA_DDR_A = $6003

; timer 1 counter low and high
VIA_T1_CL = $6004
VIA_T1_CH = $6005

; auxiliary control register
VIA_ACR = $600B

; periferal control register
VIA_PCR = $600C
; interrupt flags register
VIA_IFR = $600D
; interrupt enable register
VIA_IER = $600E

lcd_display_write_zero_terminated_string__input_low = $6004
lcd_display_write_zero_terminated_string__input_high = $6005

; ------------------------------
; variables
; ------------------------------

; helper variables
ADDR_ARG_1 = $0000 ; 2 bytes

PRINT_BASE_10_VALUE = $0200 ; 2 bytes
PRINT_BASE_10_MOD_10 = $0202 ; 2 bytes

PRINT_NUMBER_OUT = $0204 ; 6 bytes

IRQ_COUNTER = $020A ; two bytes

TICKS = $020C ; 4 bytes

BLINK_LED_BLINK_TIME = $0210 ; 1 byte

TMP = $0211 ; 2 bytes



  ; program instructions begin at 8000
  .org $E000

; TODO: make each thing we can do with this program a sub routine with its own
; loop function so that we can easily switch between them and see what the options are

reset:
  ; set intterrupts as allowed on 6502
  cli

  ; diable all via interrupts, enable then as needed after
  jsr via_set_all_interrupts_off

  ; enable interrupts on the ca1 line of the VIA
  jsr via_initialize_ca1_interrupts

  ; initialize timers for blinking LED
  jsr via_initialize_timer1_tick_timer

  lda #0
  sta BLINK_LED_BLINK_TIME

  ; initialize our irq counter
  lda #0
  sta IRQ_COUNTER
  sta IRQ_COUNTER + 1

  ; print a string to the screen
  jsr via_initialize_ports_for_display
  jsr lcd_display_initialize
 
  ; jsr basic_print_test


loop:
  jsr clear_screen_and_print_irq_counter
  jsr blink_led_on_delay
  jmp loop

; ------------------------------
; functional sub routines
; ------------------------------

blink_led_on_delay:
  sec
  lda TICKS
  sbc BLINK_LED_BLINK_TIME

  ; check if 250 ms have passed
  cmp #25
  bcc blink_led__no_blink

  ; toggle the lowest bit on port a
  lda VIA_PORT_A
  eor #%00000001
  sta VIA_PORT_A

  ; store lowest byte of ticks as new toggle time
  lda TICKS
  sta BLINK_LED_BLINK_TIME

blink_led__no_blink:
  rts

clear_screen_and_print_irq_counter:
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
  rts

basic_print_test__message: .asciiz "Hi!"
basic_print_test__number: .word 42
basic_print_test:
  lda #(basic_print_test__message & $FF)
  sta ADDR_ARG_1
  
  lda #(basic_print_test__message >> 8)
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
  lda #$FF
  sta PRINT_BASE_10_VALUE
  lda #0
  sta PRINT_BASE_10_VALUE + 1
  jsr lcd_display_write_base_10_number
  rts


; ------------------------------
; initialization sub routines
; ------------------------------

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
  lda #0
  sta VIA_IER
  rts

via_initialize_ca1_interrupts:
  ; set intterupts on with MSB
  ; set CA1 interrupts on with a[1]
  lda VIA_IER
  ora #%10000010
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
  lda VIA_IER
  ora #%11000000
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
; lcd base instruction sub routines
; ------------------------------

lcd_display_clear_display:
  lda #%00000001 ; clear the display
  jsr lcd_display_send_instruction
  rts

lcd_display_entry_mode_set:
  ; 000001 I\D S instruction pattern
  ; I\D : increment on / off | 1 / 0
  ; S   : shift     on / off | 1 / 0
  
  lda #%00000110 ; Increment and shift cursor; don't shift display
  jsr lcd_display_send_instruction
  rts


lcd_display_function_set:
  lda #%00111000 ; Set 8-bit mode; 2-line display; 5x8 font
  jsr lcd_display_send_instruction
  rts

lcd_display_display_on:
  ; 00001DCB instruction pattern
  ; D : display on / off | 1 / 0
  ; C : cursor  on / off | 1 / 0
  ; B : blink   on / off | 1 / 0
  lda #%00001110 ; Display on; cursor on; blink off
  jsr lcd_display_send_instruction
  rts


lcd_display_return_home:
  lda #%00000001
  jsr lcd_display_send_instruction
  rts


; pass instruction for data lines in regiester A
lcd_display_send_instruction:
  jsr lcd_spin_while_busy

  ; send the instruction to the display instr register
  sta VIA_PORT_B

  ; save the lower bits of port a so we can leave them
  ; unmodified
  lda VIA_PORT_A
  and #%00011111
  sta TMP

  ; set Enable, Register select, and Read write to 0
  lda TMP
  sta VIA_PORT_A

  ; briefly set the enable instruction to kick off
  ; display processing of instruction
  lda TMP
  ora #VIA_PORT_A_LCD_E_BIT
  sta VIA_PORT_A

  ; turn off all three again
  lda TMP
  sta VIA_PORT_A

  rts

lcd_spin_while_busy:
  pha
lcd_spin_while_busy_inner:
  ; get the busy flag and address in A
  jsr lcd_read_busy_flag_and_address
 
  ; get just the busy flag
  and #%10000000

  ; the busy flag is set, read the busy flag again
  bne lcd_spin_while_busy_inner

  pla
  rts

lcd_read_busy_flag_and_address:
  ; set DDRB as input
  lda #%00000000
  sta VIA_DDR_B

  ; save the lower bits of port a so we can leave them
  ; unmodified
  lda VIA_PORT_A
  and #%00011111
  sta TMP

  ; set Enable, Register select to 0, Read write to 1
  lda TMP
  ora #VIA_PORT_A_LCD_RW_BIT
  sta VIA_PORT_A

  ; briefly set the enable instruction to kick off
  ; display processing of instruction
  lda TMP
  ora #(VIA_PORT_A_LCD_E_BIT | VIA_PORT_A_LCD_RW_BIT)
  sta VIA_PORT_A

  ; read the busy flag data
  ldx VIA_PORT_B

  ; set Enable, Register select to 0, Read write to 1
  lda TMP
  ora #VIA_PORT_A_LCD_RW_BIT
  sta VIA_PORT_A

  ; restore DDRB as output
  lda #$FF
  sta VIA_DDR_B

  ; put the read value back in A
  txa
  rts

; ------------------------------
; printing sub routines
; ------------------------------

; pass address of string in A
lcd_display_write_zero_terminated_string:
  ldy #0

lcd_display_write_zero_terminated_string__inner:
  lda (ADDR_ARG_1),Y
  beq lcd_display_write_zero_terminated_string__exit
  jsr lcd_display_write_character
  iny
  jmp lcd_display_write_zero_terminated_string__inner

lcd_display_write_zero_terminated_string__exit:
  rts
  
; pass character data to write in register a
lcd_display_write_character:
  pha

  jsr lcd_spin_while_busy
  ; write the character to port b
  sta VIA_PORT_B

  ; save the lower bits of port a so we can leave them
  ; unmodified
  lda VIA_PORT_A
  and #%00011111
  sta TMP

  ; set Enable, Register select to 1, Read write to 0
  lda TMP
  ora #VIA_PORT_A_LCD_RS_BIT
  sta VIA_PORT_A

  ; temporarily set enable bit
  lda TMP
  ora #(VIA_PORT_A_LCD_RS_BIT | VIA_PORT_A_LCD_E_BIT)   ; Set E bit to send instruction
  sta VIA_PORT_A

  ; set Enable, Register select to 1, Read write to 0 back
  lda TMP
  ora #VIA_PORT_A_LCD_RS_BIT
  sta VIA_PORT_A

  pla
  rts

; writes a 16 bit number passed in PRINT_BASE_10_VALUE, PRINT_BASE_10_VALUE + 1
lcd_display_write_base_10_number:
  lda #0
  sta PRINT_NUMBER_OUT

lcd_display_write_base_10_number__divide:
  ; initialize remainder to 0
  lda #0
  sta PRINT_BASE_10_MOD_10
  sta PRINT_BASE_10_MOD_10 + 1

  ldx #16
  clc
lcd_display_write_base_10_number__divloop:
  ; rotate quotient and remainder
  rol PRINT_BASE_10_VALUE
  rol PRINT_BASE_10_VALUE + 1
  rol PRINT_BASE_10_MOD_10
  rol PRINT_BASE_10_MOD_10 + 1

  ; a,y = dividend - divisor
  sec
  lda PRINT_BASE_10_MOD_10
  sbc #10
  tay ; save the low byte in y
  lda PRINT_BASE_10_MOD_10 + 1
  sbc #0
  bcc lcd_display_write_base_10_number__ignore_result ; branch if dividend < divisor
  sty PRINT_BASE_10_MOD_10
  sta PRINT_BASE_10_MOD_10 + 1

lcd_display_write_base_10_number__ignore_result:
  dex
  bne lcd_display_write_base_10_number__divloop
  rol PRINT_BASE_10_VALUE
  rol PRINT_BASE_10_VALUE + 1

  lda PRINT_BASE_10_MOD_10
  clc
  adc #"0"
  jsr print_base_10_push_char

  ; if value != 0, then continue dividing
  lda PRINT_BASE_10_VALUE
  ora PRINT_BASE_10_VALUE + 1
  bne lcd_display_write_base_10_number__divide ; brnach if value not zero

  ; write the final result out to lcd display
  lda #(PRINT_NUMBER_OUT & $FF)
  sta ADDR_ARG_1
  
  lda #(PRINT_NUMBER_OUT >> 8)
  sta ADDR_ARG_1 + 1
  
  jsr lcd_display_write_zero_terminated_string

; have character in the a register
; add that character to the beginning of null terminated string in
; PRINT_NUMBER_OUT location
print_base_10_push_char:
  pha
  ldy #0

print_base_10_push_char__loop:
  lda PRINT_NUMBER_OUT,y  ; get char on string and put into x
  tax
  pla
  sta PRINT_NUMBER_OUT,y ; pull char off stack and add it to the string
  iny
  txa
  pha                    ; psuh char from string onto stack
  bne print_base_10_push_char__loop

  pla
  sta PRINT_NUMBER_OUT,y ; pull null off the stack and add that to the string
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
  bne irq__timer_1__exit
  inc TICKS + 1
  bne irq__timer_1__exit
  inc TICKS + 2
  bne irq__timer_1__exit
  inc TICKS + 3

irq__timer_1__exit:
  jmp irq__exit

irq__ca1:
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

  .org $fffa
  .word nmi
  .word reset  ; our program
  .word irq    ; unused interrupt vector
