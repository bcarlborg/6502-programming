# 6502-programming

Programs written for the 6502 8 bit computer.

These programs are specifically designed to run on the system designed and implemented in Ben Eaters Design a 6502 from scratch [youtube series](https://www.youtube.com/playlist?list=PLowKtXNTBypFbtuVMUVXNR0z1mu7dp7eH). My specific implementation of the system is described in more depth in Architecture.md

## System overview
This system is based off of the Design a 6502 from scratch [youtube series](https://www.youtube.com/playlist?list=PLowKtXNTBypFbtuVMUVXNR0z1mu7dp7eH) created by ben eater. The systems _features_ are as follows:
- The system is entirely implemented on bread boards
- The system features two clocks that can be toggled using a jumper wire
  - A 1 MHz crystal oscilator clock for production use
  - A variable rate step wise clock that can be use to run the system at very slow clock speeds, or using a push button to trigger clock cycles.
- The system includes an LCD display attached to the W65C22 Versital interface adapter
- The system leaves a number of pins on the versital interface adapter open for additional use

## System details
The system I have implemented closely aligns with the schematic provided by Ben Eater for the 6502 with a few small exceptions. _(schematic provided below in the images section)_
- Many of my projects wire the 65C22 Versital Interface adapter pins differently to provide different periferal devices to the chip (namely pins `CA[1,2]`, `CB[1,2]`, `CB[1,2]`, `PA[0,1,2,3,4]`)
- My system does not use a 28C25B EEPROM like Ben Eaters, rather mine uses a smaller 628C64B EEPROM. The 64B EEPROM was easier to aquire when I burnt out my original 28C25B EEPROM that the set included originally 😅



## Images
| System on board  | Annotated system on board |
| ------------- | ------------- |
| <img width="728" alt="6502 on board as of 2022-10-04" src="https://user-images.githubusercontent.com/18710035/194104879-ade6bda7-72d2-4f17-b37f-e2d8d81312ca.png"> | <img width="728" alt="Annotated 6502 on board as of 2022-10-04" src="https://user-images.githubusercontent.com/18710035/194104595-60f03871-c6de-4e33-91be-af4ae55edb9f.png"> |


Ben eater's schematic for the 6502 Project:
![image](https://user-images.githubusercontent.com/18710035/194106846-9253489c-890c-476f-b3d5-a14f14d86146.png)

##
