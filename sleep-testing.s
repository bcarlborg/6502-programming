PORTA = $6001 
PORTB = $6000

DDRA = $6003
DDRB = $6002

T1CL = $6004
T1CH = $6005

ACR = $600b
IFR = $600d

E =  %10000000
RW = %01000000
RS = %00100000

tmp     = $0200 ; 1 byte 
counter = $0201 ; 2 bytes



  ; our ROM address space begins at $8000
  .org $8000

reset:
  ; set last pin on port a to output to drive LED
  lda #%11111111
  sta DDRA

  ; use the auxiliary control register to set timer 1 to 00
  lda #0
  sta ACR

  ; disable our LED before looping
  lda #0
  sta PORTA

loop:
  lda #1
  sta PORTA
  jsr delay

  lda #0
  sta PORTA
  jsr delay

  jmp loop

delay:
  lda #$50
  sta T1CL
  lda #$C3
  sta T1CH

; loop until IFR is set
delay1:
  bit IFR
  bvc delay1

  ; read from T1CL to clear the interrupt
  lda T1CL
  rts

nmi:
irq:
  rti

  .org $fffa
  .word nmi
  .word reset
  .word irq
