# Architecture and System overview
This system is based off of the Design a 6502 from scratch [youtube series](https://www.youtube.com/playlist?list=PLowKtXNTBypFbtuVMUVXNR0z1mu7dp7eH) created by ben eater. 

## System Hardware Features
- The system is entirely implemented on bread boards
- The system features two clocks that can be toggled using a jumper wire
  - A 1 MHz crystal oscilator clock for production use
  - A variable rate step wise clock that can be use to run the system at very slow clock speeds, or using a push button to trigger clock cycles.
- The system includes an LCD display attached to the W65C22 Versital interface adapter
- The system leaves a number of pins on the versital interface adapter open for additional use

## System Details
The system I have implemented closely aligns with the schematic provided by Ben Eater for the 6502 with a few small exceptions. _(schematic provided below in the images section)_
- Many of my projects wire the 65C22 Versital Interface adapter pins differently to provide different periferal devices to the chip (namely pins `CA[1,2]`, `CB[1,2]`, `CB[1,2]`, `PA[0,1,2,3,4]`)
- My system does not use a 28C25B EEPROM like Ben Eaters, rather mine uses a smaller 628C64B EEPROM. The 64B EEPROM was easier to aquire when I burnt out my original 28C25B EEPROM that the set included originally 😅

## Schematic
<img
  src="https://user-images.githubusercontent.com/18710035/194106846-9253489c-890c-476f-b3d5-a14f14d86146.png"
  alt="6502 project schematic from Ben Eater"
  style="margin: 0 auto; max-width: 300px">

## Memory Map
```
=======================================
Address space
=======================================
------
$0000 |
$1000 | -- V65C22 VIA
$2000 |
$3000 |
------
$4000
$5000
------
$6000 | -- V65C22 VIA
------
$7000
$8000
$9000
$A000
$B000
$C000
$D000
------
$E000 | -- 28C64B EEPROM
$FFFF |
------

=======================================
65C22 VIA to HD44780U LCD Display
=======================================

VIA_PORT_B[0..7] --> LCD controlelr D[0..7]
VIA_PORT_A[7]    --> LCD controller enable bit
VIA_PORT_A[6]    --> LCD controller R/W bit
VIA_PORT_A[5]    --> LCD controller RS bit

=======================================
65C22 VIA to blinking LED
=======================================

VIA_PORT_A[0]    --> LED

=======================================
65C22 VIA to button
=======================================

VIA_PORT_A[CA1]   --> negative transition push button
```

## Images
| System on board  | Annotated system on board |
| ------------- | ------------- |
| <img width="728" alt="6502 on board as of 2022-10-04" src="https://user-images.githubusercontent.com/18710035/194104879-ade6bda7-72d2-4f17-b37f-e2d8d81312ca.png"> | <img width="728" alt="Annotated 6502 on board as of 2022-10-04" src="https://user-images.githubusercontent.com/18710035/194104595-60f03871-c6de-4e33-91be-af4ae55edb9f.png"> |


