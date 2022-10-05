  .include 'global_constants.h.s'

  .section ".variables"

; helper numbers for base 10 division
PRINT_BASE_10_VALUE: .byte $FF,$FF ; 2 bytes
  .global PRINT_BASE_10_VALUE

PRINT_BASE_10_MOD_10: .byte $FF,$FF ; 2 bytes

; helper variable to store the number to write to screen
PRINT_NUMBER_OUT: .byte $FF,$FF,$FF,$FF,$FF,$FF ; 6 bytes


  .section '.routines'

; ------------------------------
; printing sub routines
; ------------------------------

; pass address of string in A
lcd_display_write_zero_terminated_string:
  .global lcd_display_write_zero_terminated_string
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
  .global lcd_display_write_character
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
  .global lcd_display_write_base_10_number
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
  lda #(<PRINT_NUMBER_OUT)
  sta ADDR_ARG_1
  
  lda #(>PRINT_NUMBER_OUT)
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




; ------------------------------
; lcd base instruction sub routines
; ------------------------------

lcd_display_clear_display:
  .global lcd_display_clear_display
  lda #%00000001 ; clear the display
  jsr lcd_display_send_instruction
  rts

lcd_display_entry_mode_set:
  .global lcd_display_entry_mode_set
  ; 000001 I\D S instruction pattern
  ; I\D : increment on / off | 1 / 0
  ; S   : shift     on / off | 1 / 0
  
  lda #%00000110 ; Increment and shift cursor; don't shift display
  jsr lcd_display_send_instruction
  rts


lcd_display_function_set:
  .global lcd_display_function_set
  lda #%00111000 ; Set 8-bit mode; 2-line display; 5x8 font
  jsr lcd_display_send_instruction
  rts

lcd_display_display_on:
  .global lcd_display_display_on
  ; 00001DCB instruction pattern
  ; D : display on / off | 1 / 0
  ; C : cursor  on / off | 1 / 0
  ; B : blink   on / off | 1 / 0
  lda #%00001110 ; Display on; cursor on; blink off
  jsr lcd_display_send_instruction
  rts


lcd_display_return_home:
  .global lcd_display_return_home
  lda #%00000001
  jsr lcd_display_send_instruction
  rts

lcd_spin_while_busy:
  .global lcd_spin_while_busy
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
