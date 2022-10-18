# Programmers Guide
Here I provide a brief overview of how a program can be written for the 6502 using the tools provided in this repository

## Creating a project
All prgrams for the 6502 system outlined in this repository have thir own directory in `projects/`. This directory conventionally
should contain a `main.s` file. An entry in the Makefile can also be added for the program in order to build the objects required to run that program.

## Writing assembly for this system
This project provides a number of basic libraries and frameworks in the `global_utilities` directory that make writing software for the 6502 slightly easier.
`lcd-control-routines.s` and `strings.s` are basic libararies that provide simple sub routines for working with strings in memory and writing output
to the LCD in the system.

`program_harness.s` is a simple framework that allows projects to easily implement application level logic for 6502 programs without needing to
worry about system initialization, interfacing with buttons or the LCD.

## Basic program structure
Using the framwork that `program_harness.s` provides, a 6502 program can be added to this repository with the following structure. `program_harness.s` can
be used with any assembly file by linking the program object file with the `GLOBAL_UTILITIES` specificied in the Makefile.

The following subroutines
must be implemented in any program that uses the `program_harness.s` framework. If one of the functions is not needed, it should simply be implemented as an
empty subroutine that immediately calls `rts`.
- `reset`: subroutine that is run once at the start of the program
- `loop`: subroutine that is in a continuous loop after reset
- `on_up_button_press`: subroutine that is run immediately before the next `loop` after the up button was pressed
- `on_down_button_press`: subroutine that is run immediately before the next `loop` after the down button was pressed
- `on_left_button_press`: subroutine that is run immediately before the next `loop` after the left button was pressed
- `on_right_button_press`: subroutine that is run immediately before the next `loop` after the right button was pressed
- `on_action_button_press`: subroutine that is run immediately before the next `loop` after the action button was pressed

The linker script that is used with `program_harness.s` also defines a number of `sections` that can be used in project programs:
- `.zero_page_variables`: a section for data that lives in RAM from `0x0000` to `0x00FF`
- `.variables`: a section for data that lives in RAM after the stack from `0x0200` onward
- `.initialized_data`: a section for data that is initialized and defined in ROM
- `.body`: The section containing the `reset` and `loop` subroutines
- `.routines`: The section containing all other user defined helper routines

Some additional global variables are also provided by `lcd-control-routines.s` that can be used to make writing to the LCD display easier
- `SCREEN_CURSOR_ROW` and `SCREEN_CURSOR_POS`: these global variables specify the row and column of the cursor on the screen
- `SCREEN_OUT_1` and `SCREEN_OUT_2` : these global variables specify the data to render in the ascii characters to render in the first
and second row of the LCD respectively

## Example assembly program using program_harness.s
```x86asm
  .include '../../global_utilities/global_constants.h.s'

; ------------------------------
; variables in RAM
; ------------------------------

  .section ".zero_page_variables"
  ; specify variables you would like in the zero page of RAM here

  .section ".variables"
  ; specify all other variables outside of the zero page here

; ------------------------------
; initialized data
; ------------------------------

  .section '.initialized_data'  
  ; specify data loaded into the program ROM here
 
; ------------------------------
; THE PROGRAM!
; ------------------------------
  .section '.body'

reset:
 .global reset
 
  ; implement your reset routine here
  
  rts

loop:
  .global loop
  
  ; implement your reset routine here
  
  rts

  .section '.body'

; ------------------------------
; BUTTON HANDLERS
; ------------------------------

;
; implement your button handler sub routines here
;
on_up_button_press:
  .global on_up_button_press
  rts

on_right_button_press:
  .global on_right_button_press
  rts

on_down_button_press:
  .global on_down_button_press
  rts

on_left_button_press:
  .global on_left_button_press
  rts

on_action_button_press:
  .global on_action_button_press
  rts


; ------------------------------
; ROUTINES
; ------------------------------

  .section '.routines'
  
  ; implement all other helper functions here

```
