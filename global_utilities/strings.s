  .include 'global_constants.h.s'

  .section ".variables"

; helper numbers for base 10 division
PRINT_BASE_10_VALUE: .byte $FF,$FF ; 2 bytes
  .global PRINT_BASE_10_VALUE

PRINT_BASE_10_MOD_10: .byte $FF,$FF ; 2 bytes

; helper variable to store the number to write to screen
PRINT_NUMBER_OUT: .byte $FF,$FF,$FF,$FF,$FF,$FF ; 6 bytes

  .section '.routines'

; pass address of string to write in ADDR_ARG_1
write_zero_terminated_string_line_1:
  .global write_zero_terminated_string_line_1
  lda #(<SCREEN_OUT_1)
  sta ADDR_ARG_2
  lda #(>SCREEN_OUT_1)
  sta ADDR_ARG_2 + 1
  jsr write_zero_terminated_string 
  rts

; pass address of string to write in ADDR_ARG_1
write_zero_terminated_string_line_2:
  .global write_zero_terminated_string_line_2
  lda #(<SCREEN_OUT_2)
  sta ADDR_ARG_2
  lda #(>SCREEN_OUT_2)
  sta ADDR_ARG_2 + 1
  jsr write_zero_terminated_string
  rts


; pass address of string to write in ADDR_ARG_1
; pass the destination pointer in ADDR_ARG_2
; DOES NOT ACTUALLY WRITE 0 data to dest, simply
; stops writing at 0,
; if you want a fucntion tahat carries the zero, implement a
; str copy function ;~)
write_zero_terminated_string:
  .global write_zero_terminated_string
  ldy #0

write_zero_terminated_string__inner:
  lda (ADDR_ARG_1),Y   ; get the character to write
  beq write_zero_terminated_string__exit
  sta (ADDR_ARG_2),Y   ; write the character
  iny
  jmp write_zero_terminated_string__inner

write_zero_terminated_string__exit:
  rts


; writes a 16 bit number passed in PRINT_BASE_10_VALUE and PRINT_BASE_10_VALUE + 1
write_base_10_number_line_1:
  .global write_base_10_number_line_1
  lda #(<SCREEN_OUT_1)
  sta ADDR_ARG_2
  lda #(>SCREEN_OUT_1)
  sta ADDR_ARG_2 + 1
  jsr write_base_10_number
  rts


; writes a 16 bit number passed in PRINT_BASE_10_VALUE and PRINT_BASE_10_VALUE + 1
write_base_10_number_line_2:
  .global write_base_10_number_line_2
  lda #(<SCREEN_OUT_2)
  sta ADDR_ARG_2
  lda #(>SCREEN_OUT_2)
  sta ADDR_ARG_2 + 1
  jsr write_base_10_number
  rts

; writes a 16 bit number passed in PRINT_BASE_10_VALUE and PRINT_BASE_10_VALUE + 1
; to a destination at ADDR_ARG_2
write_base_10_number:
  .global write_base_10_number
  lda #0
  sta PRINT_NUMBER_OUT

write_base_10_number__divide:
  ; initialize remainder to 0
  lda #0
  sta PRINT_BASE_10_MOD_10
  sta PRINT_BASE_10_MOD_10 + 1

  ldx #16
  clc
write_base_10_number__divloop:
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
  bcc write_base_10_number__ignore_result ; branch if dividend < divisor
  sty PRINT_BASE_10_MOD_10
  sta PRINT_BASE_10_MOD_10 + 1

write_base_10_number__ignore_result:
  dex
  bne write_base_10_number__divloop
  rol PRINT_BASE_10_VALUE
  rol PRINT_BASE_10_VALUE + 1

  lda PRINT_BASE_10_MOD_10
  clc
  adc #"0"
  jsr print_base_10_push_char

  ; if value != 0, then continue dividing
  lda PRINT_BASE_10_VALUE
  ora PRINT_BASE_10_VALUE + 1
  bne write_base_10_number__divide ; brnach if value not zero

  ; write the final result out to lcd display
  lda #(<PRINT_NUMBER_OUT)
  sta ADDR_ARG_1
  
  lda #(>PRINT_NUMBER_OUT)
  sta ADDR_ARG_1 + 1
  
  jsr write_zero_terminated_string
  rts

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


empty_line_1:
  .global empty_line_1
  lda #(<SCREEN_OUT_1)
  sta ADDR_ARG_2
  lda #(>SCREEN_OUT_1)
  sta ADDR_ARG_2 + 1
  lda #16
  tax
  jsr print_blanks_length
  rts

empty_line_2:
  .global empty_line_2
  lda #(<SCREEN_OUT_2)
  sta ADDR_ARG_2
  lda #(>SCREEN_OUT_2)
  sta ADDR_ARG_2 + 1
  lda #16
  tax
  jsr print_blanks_length
  rts

; puts spaces into a string at ADDR_ARG_2
; number of bytes to zero passed in x
print_blanks_length:
  .global print_blanks_length
  txa
  sta TMP

  .global write_zero_terminated_string
  ldy #0

print_blanks_for_length__inner:
  lda #' '             ; get the character to write
  sta (ADDR_ARG_2),Y   ; write the character
  iny
  tya
  cmp TMP
  beq pint_blanks_for_length__exit
  jmp print_blanks_for_length__inner 

pint_blanks_for_length__exit:
  rts



