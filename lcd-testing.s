PORTA = $6001 
PORTB = $6000

DDRA = $6003
DDRB = $6002

E =  %10000000
RW = %01000000
RS = %00100000

tmp     = $0200 ; 1 byte 
counter = $0201 ; 2 bytes



  ; our ROM address space begins at $8000
  .org $E000

reset:
  ldx #$ff
  txs
  
  ; clear the interrupt disable bit
  cli

  ; set all pins on port b to output
  lda #%11111111
  sta DDRB

  ; set top three pins on port a to output
  lda #%11100000
  sta DDRA

  jsr initialize_display

  lda #0
  sta counter + 1
  lda #0
  sta counter

loop:
  jsr set_lcd_cursor_home
  lda counter + 1
  jsr print_8_bits
  lda counter
  jsr print_8_bits
  jmp loop  

print_8_bits:
  ldy #7
print_8_bits_loop_start:
  sty tmp
  ldx tmp
  jsr print_binary_at_index
  dey
  bmi exit_print_8_bits
  jmp print_8_bits_loop_start
exit_print_8_bits:
  rts


; prints the xth binary value [0..7]
; in the a register, resotres a for caller

print_binary_at_index:
  ; push a for return
  pha

print_binary_at_index_rotate_index_to_start_loop:
  cpx #0
  beq print_binary_at_index_rotate_index_to_start_loop_over

  ; rotate our incoming word over once
  ror

  dex
  jmp print_binary_at_index_rotate_index_to_start_loop

print_binary_at_index_rotate_index_to_start_loop_over:

  ; make sure we only have the bit we care about
  and #1

  ; add that to ascii 0 to get the value to print
  clc
  adc #48

  ; now print that
  jsr print_character

  pla
  rts

; ---------------------------------
; Clear Display
; ---------------------------------
;
; 00000001
clear_lcd_display:
  lda #%00000001
  jsr lcd_instruction
  rts


; ---------------------------------
; Set lcd cursor to home
; ---------------------------------
;
; 00000010
set_lcd_cursor_home:
  lda #%00000010
  jsr lcd_instruction
  rts



initialize_display:
  jsr clear_lcd_display 

  ; ---------------------------------
  ; LCD Function set instruction
  ; ---------------------------------
  ;
  ; 001 DL N F - - 
  ; 001    : function set instruction LCD
  ; DL = 1 : 8 bit data length
  ; N  = 1 : 2 line display
  ; F  = 0 : 5 x 8 font
  lda #%00111000
  jsr lcd_instruction

  ; ---------------------------------
  ; Display on off instruction
  ; ---------------------------------
  ;
  ; 00001 D C B
  ; 00001     ; display on off instruction code
  ; D = 1     ; display on
  ; C = 0/1   ; cursor off/on
  ; B = 0/1   ; blinking cursor off/on
 
  lda #%00001100
  jsr lcd_instruction

  ; ---------------------------------
  ; Entry mode set instruction
  ; ---------------------------------
  ;
  ; 000001 I/D S
  ; 000001    ; entry mode set set instruction code
  ; I/D = 1   ; Increment address 
  ; S   = 0   ; accompanies display shift off
 
  lda #%00000110
  jsr lcd_instruction

  rts

; ---------------------------------
; Have the lcd screen wait between
; sending instruction 
; ---------------------------------
lcd_wait:
  pha

  lda #%00000000 ; set all pins on port B as input
  sta DDRB

loop_while_lcd_busy:
  ; tell the display we want to read a value
  lda #RW
  sta PORTA
  lda  #(RW| E)
  sta PORTA

  lda PORTB ; read the ready flag from IO from display

  ; get just the ready flag,
  and #%10000000

  ; if still busy, get the ready flag again
  bne loop_while_lcd_busy

  lda #%11111111 ; set all pins on port B back to input
  sta DDRB

  pla
  rts

; ---------------------------------
; An instruction to the lcd display
;
; send the instruction in the a
; register to the screen
; ---------------------------------
lcd_instruction:
  jsr lcd_wait
  sta PORTB
  lda #0        ; clear RS/RW/E bits
  sta PORTA
  lda #E        ; enable the display causing it to accept the instruction
  sta PORTA     ; or data on port A and B
  lda #0        ; clear RS/RW/E bits
  sta PORTA
  rts

; ---------------------------------
; Send a letter to the display
;
; prints the letter loaded into a
; register
; ---------------------------------
print_character:
  jsr lcd_wait
  sta PORTB
  ; set RW and RS to 0
  lda #RS
  sta PORTA
  ; briefly set the enable to send the instruction
  lda #(RS | E)
  sta PORTA
  ; set RW and RS to 0
  lda #RS
  sta PORTA
  rts

nmi:
  inc counter
  bne exit_irq
  inc counter + 1
exit_nmi:
  rti

irq:
  inc counter
  bne exit_irq
  inc counter + 1
exit_irq:
  rti

  .org $fffa
  .word nmi
  .word reset
  .word irq
