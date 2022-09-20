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
VIA_PORT_B = $6000
VIA_PORT_A = $6001
VIA_DDR_B = $6002   
VIA_DDR_A = $6003

lcd_display_write_zero_terminated_string__input_low = $6004
lcd_display_write_zero_terminated_string__input_high = $6005

; ------------------------------
; variables
; ------------------------------

; helper variables
ADDR_ARG_1_LOW = $0000
ADDR_ARG_1_HIGH = $0001


  ; program instructions begin at 8000
  .org $E000

message: .asciiz "Hello world!"

reset:
  jsr via_initialize_ports_for_display
  jsr lcd_display_initialize
  
  lda #(message & $FF)
  sta ADDR_ARG_1_LOW
  
  lda #(message >> 8)
  sta ADDR_ARG_1_HIGH
  
  jsr lcd_display_write_zero_terminated_string

loop:
  jmp loop


; ------------------------------
; initialization sub routines
; ------------------------------

via_initialize_ports_for_display:
  ; set data direction of ports A and B
  lda #%11111111 ; set all of port B to output
  sta VIA_DDR_B
  lda #%11100000 ; set top 3 bits of port A to output
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


lcd_display_display_return_home:
  lda #%00000001
  jsr lcd_display_send_instruction
  rts


; pass instruction for data lines in regiester A
lcd_display_send_instruction:
  jsr lcd_spin_while_busy

  ; send the instruction to the display instr register
  sta VIA_PORT_B

  ; set Enable, Register select, and Read write to 0
  lda #0
  sta VIA_PORT_A

  ; briefly set the enable instruction to kick off
  ; display processing of instruction
  lda #VIA_PORT_A_LCD_E_BIT
  sta VIA_PORT_A

  lda #0
  sta VIA_PORT_A

  rts

; pass address of string in A
lcd_display_write_zero_terminated_string:
  ldy #0

lcd_display_write_zero_terminated_string__inner:
  lda (ADDR_ARG_1_LOW),Y
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

  sta VIA_PORT_B
  lda #VIA_PORT_A_LCD_RS_BIT ; Set RS; Clear RW/E bits

  sta VIA_PORT_A
  lda #(VIA_PORT_A_LCD_RS_BIT | VIA_PORT_A_LCD_E_BIT)   ; Set E bit to send instruction

  sta VIA_PORT_A
  lda #VIA_PORT_A_LCD_RS_BIT ; Set RS; Clear RW/E bits

  sta VIA_PORT_A

  pla
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

  ; set Enable, Register select to 0, Read write to 1
  lda VIA_PORT_A_LCD_RW_BIT
  sta VIA_PORT_A

  ; briefly set the enable instruction to kick off
  ; display processing of instruction
  lda #(VIA_PORT_A_LCD_E_BIT | VIA_PORT_A_LCD_RW_BIT)
  sta VIA_PORT_A

  ; read the busy flag data
  ldx VIA_PORT_B

  lda VIA_PORT_A_LCD_RW_BIT
  sta VIA_PORT_A

  ; restore DDRB as output
  lda #$FF
  sta VIA_DDR_B

  ; put the read value back in A
  txa
  rts

  .org $fffc
  .word reset  ; our program
  .word $0000  ; unused interrupt vector
