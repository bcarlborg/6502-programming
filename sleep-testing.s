PORTA = $6001 
PORTB = $6000

DDRA = $6003
DDRB = $6002

T1CL = $6004
T1CH = $6005

ACR = $600b
IFR = $600d
IER = $600e

E =  %10000000
RW = %01000000
RS = %00100000

ticks = $00 ; 4 bytes
toggle_time = $04


  ; our ROM address space begins at $8000
  .org $8000

reset:
  ; set last pin on port a to output to drive LED
  lda #%11111111
  sta DDRA


  ; zero out some variables
  lda #0
  sta PORTA ; disable our LED before looping
  sta toggle_time

  jsr init_timer

loop:
  jsr update_led
  jmp loop

update_led:
  sec
  lda ticks
  sbc toggle_time
  cmp #250 ; have 2500 miliseconds passed
  bcc loop

  ; xor port A with 1 to invert it
  lda #$01
  eor PORTA
  sta PORTA

  lda ticks
  sta toggle_time

  jmp update_led

init_timer:
  lda #0
  sta ticks
  sta ticks + 1
  sta ticks + 2
  sta ticks + 3

  lda #%01000000
  sta ACR

  lda #$0E
  sta T1CL
  lda #$27
  sta T1CH

  lda #%11000000
  sta IER

  cli

  rts

nmi:
  rti

irq:
  ; use bit op to read from T1CL
  bit T1CL

  inc ticks
  bne irq_end
  inc ticks + 1
  bne irq_end
  inc ticks + 2
  bne irq_end
  inc ticks + 3

irq_end:
  rti

  .org $fffa
  .word nmi
  .word reset
  .word irq
