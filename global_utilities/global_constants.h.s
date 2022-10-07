; ------------------------------
; constants in ROM
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

; port b data direction registers
VIA_DDR_B = $6002   

; port a data direction registers
VIA_DDR_A = $6003

; timer 1 counter low 
VIA_T1_CL = $6004

; timer 1 counter high
VIA_T1_CH = $6005

; auxiliary control register
VIA_ACR = $600B

; periferal control register
VIA_PCR = $600C

; interrupt flags register
VIA_IFR = $600D

; interrupt enable register
VIA_IER = $600E


LCD_DISPLAY_ROW_TWO_CUROR = 41
