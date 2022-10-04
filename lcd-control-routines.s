  .include 'global_constants.s'




; ------------------------------
; lcd base instruction sub routines
; ------------------------------

  .section '.routines'
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

