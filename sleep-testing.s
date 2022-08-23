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
  .org $8000

reset:
  ldx #$ff
  txs
  
  ; clear the interrupt disable bit
  cli

  ; set all pins on port b to output
  lda #%11111111
  sta DDRB

  ; set last pin on port a to output to drive LED
  lda #%11111111
  sta DDRA

  ; disable our LED before looping
  lda #0
  sta PORTA

loop:
  inc PORTA ; turn led on
  jsr delay

  dec PORTA ; turn led off
  jsr delay

  jmp loop

delay:
  ldy #$FF
delay_outer:

  ldx #$FF
delay_inner:
  nop
  dex
  bne delay_inner 

  dey
  bne delay_outer 

  rts

nmi:
irq:
  rti

  .org $fffa
  .word nmi
  .word reset
  .word irq
