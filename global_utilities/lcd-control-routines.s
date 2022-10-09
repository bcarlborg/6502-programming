  .include 'global_constants.h.s'

  .section ".variables"

SCREEN_CURSOR_POS: .byte $FF; 1 byte
  .global SCREEN_CURSOR_POS

SCREEN_CURSOR_ROW: .byte $FF
  .global SCREEN_CURSOR_ROW

SCREEN_OUT_1: .word $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF ; 16 bytes
  .global SCREEN_OUT_1

SCREEN_OUT_2: .word $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF ; 16 bytes
  .global SCREEN_OUT_2

INTERNAL_SCREEN_OUT_1: .word $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF ; 16 bytes

INTERNAL_SCREEN_OUT_2: .word $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF ; 16 bytes


INTERNAL_SCREEN_CURSOR_POS: .byte $FF ; 1 byte

INTERNAL_SCREEN_CURSOR_ROW: .byte $FF ; 1 byte





  .section '.routines'

; ------------------------------
; CLEAR AND WRITE SCREEN STATE FUNCTIONS
;
; These functions write the SCREEN_OUT_1 and SCREEN_OUT_2 data
; to the lcd screen on lines 1 and 2 respectively, and also
; set the cursor position and row according to the variables
; SCREEN_CURSOR_ROW and SCREEN_CURSOR_POS
; ------------------------------

lcd_display_clear_and_write_out:
  .global lcd_display_clear_and_write_out

  ; if should print lines is not true
  ; then don't print the lines
  jsr should_print_lines  
  clc
  cmp #1
  bne lcd_display_clear_and_write_out__exit__any_maybe_update_cursor
  
  jsr lcd_display_clear_display
  lda #0
  jsr lcd_display_set_ddram
  jsr lcd_display_return_home
  ldy #0

lcd_display_clear_and_write_out__print_line_1_inner:
  tya
  cmp #16
  beq lcd_display_clear_and_write_out__print_line_1_exit
  lda SCREEN_OUT_1,y
  jsr lcd_display_write_character
  iny
  jmp lcd_display_clear_and_write_out__print_line_1_inner
 
lcd_display_clear_and_write_out__print_line_1_exit:
  ; set the cursor to line two
  lda #40
  jsr lcd_display_set_ddram

  ldy #0
  ; print line 2
lcd_display_clear_and_write_out__print_line_2_inner:
  tya
  cmp #16
  beq lcd_display_clear_and_write_out__print_line_2_exit
  lda SCREEN_OUT_2,y
  jsr lcd_display_write_character
  iny
  jmp lcd_display_clear_and_write_out__print_line_2_inner
 
lcd_display_clear_and_write_out__print_line_2_exit:

  ; because we just wrote a bunch of characters,
  ; we have to set the cursor back in its correct place
  jsr set_row_and_cursor
  rts

lcd_display_clear_and_write_out__exit__any_maybe_update_cursor:
  jsr should_update_cursor
  clc
  cmp #0
  beq lcd_display_clear_and_write_out__exit
  jsr set_row_and_cursor
  rts

lcd_display_clear_and_write_out__exit:
  rts


; checks screen line 1 and 2 agaist their
; internal counter parts, if they are the same,
; then print no, if they are different, update the
; internal counter parts and return yes
should_print_lines:
  lda #(<SCREEN_OUT_1)
  sta ADDR_ARG_1
  lda #(>SCREEN_OUT_1)
  sta ADDR_ARG_1 + 1

  lda #(<INTERNAL_SCREEN_OUT_1)
  sta ADDR_ARG_2
  lda #(>INTERNAL_SCREEN_OUT_1)
  sta ADDR_ARG_2 + 1

  lda #16
  tax
  jsr are_strings_equal

  ; check if line 1 was equal, if not, then we need to print
  clc
  cmp #1
  bne should_print_lines__yes

  lda #(<SCREEN_OUT_2)
  sta ADDR_ARG_1
  lda #(>SCREEN_OUT_2)
  sta ADDR_ARG_1 + 1

  lda #(<INTERNAL_SCREEN_OUT_2)
  sta ADDR_ARG_2
  lda #(>INTERNAL_SCREEN_OUT_2)
  sta ADDR_ARG_2 + 1

  lda #16
  tax
  jsr are_strings_equal

  ; check if line 2 was not equal then lets exit
  ; else, fall through to yes
  clc
  cmp #1
  beq should_print_lines__no

should_print_lines__yes:
  lda #(<SCREEN_OUT_1)
  sta ADDR_ARG_1
  lda #(>SCREEN_OUT_1)
  sta ADDR_ARG_1 + 1

  lda #(<INTERNAL_SCREEN_OUT_1)
  sta ADDR_ARG_2
  lda #(>INTERNAL_SCREEN_OUT_1)
  sta ADDR_ARG_2 + 1

  ldy #16
  jsr copy_string_by_len

  lda #(<SCREEN_OUT_2)
  sta ADDR_ARG_1
  lda #(>SCREEN_OUT_2)
  sta ADDR_ARG_1 + 1

  lda #(<INTERNAL_SCREEN_OUT_2)
  sta ADDR_ARG_2
  lda #(>INTERNAL_SCREEN_OUT_2)
  sta ADDR_ARG_2 + 1

  ldy #16
  jsr copy_string_by_len

  lda #1
  rts

should_print_lines__no:
  lda #0
  rts


; should we update the screens row and pos
; for teh cursor
should_update_cursor:
  clc
  lda SCREEN_CURSOR_POS
  cmp INTERNAL_SCREEN_CURSOR_POS
  bne should_update_cursor__yes

  clc
  lda SCREEN_CURSOR_ROW
  cmp INTERNAL_SCREEN_CURSOR_ROW
  beq should_update_cursor__no

should_update_cursor__yes:
  lda SCREEN_CURSOR_POS
  sta INTERNAL_SCREEN_CURSOR_POS
  lda SCREEN_CURSOR_ROW
  sta INTERNAL_SCREEN_CURSOR_ROW

  lda #1
  rts

should_update_cursor__no:
  lda #0
  rts


; ------------------------------
; set_row_and_cursor
;
; this function sets the cursor and row of the cursor
; according to the values in SCREEN_CURSOR_POS & SCREEN_CURSOR_ROW
; ------------------------------
set_row_and_cursor:
  lda SCREEN_CURSOR_ROW
  beq set_row_and_cursor__set_cursor__row_1

  ; set cursor to row 2
  lda #40
  jmp set_row_and_cursor__set_cursor__set_pos

  ; set cursor to row 1
set_row_and_cursor__set_cursor__row_1:
  lda #0

set_row_and_cursor__set_cursor__set_pos:
  jsr lcd_display_set_ddram

  lda SCREEN_CURSOR_POS
  tax
set_row_and_cursor__set_cursor__set_pos__inner:
  txa
  beq set_row_and_cursor__set_cursor__set_pos__exit
  
  dex
  txa
  jsr lcd_display_shift_cursor_right
  tax
  jmp set_row_and_cursor__set_cursor__set_pos__inner

set_row_and_cursor__set_cursor__set_pos__exit:
  rts


; ------------------------------
; CHARACTER WRITING
;
; write the character passed in the A register to the lcd screen
; at the current cursor position
; ------------------------------
  
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


; ------------------------------
; lcd base instruction sub routines
; ------------------------------

; sets cursor pos to lower seven bits of A
lcd_display_set_ddram:
  pha
  ora #%10000000 ; toggle top bit to set ddram
  jsr lcd_display_send_instruction
  pla
  rts

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
  lda #%00000010
  jsr lcd_display_send_instruction
  rts

lcd_display_shift_cursor_right:
  pha
  lda #%00010100
  jsr lcd_display_send_instruction
  pla
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

