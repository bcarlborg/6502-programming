  .include '../../global_utilities/global_constants.h.s'

; ------------------------------
; variables in RAM
; ------------------------------

  .section ".zero_page_variables"

  .section ".variables"

; 0 = movement mode
; 1 = insert chars
EDITOR_MODE: .byte $ff


LINE_1_CHAR_SET: .word $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF ; 16 bytes
LINE_2_CHAR_SET: .word $FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF ; 16 bytes


; ------------------------------
; initialized data
; ------------------------------

  .section '.initialized_data'
LOWER_CASE_CHARS: .asciiz ' abcdefghijklmnopqrstuvwxyz'
UPPER_CASE_CHARS: .asciiz ' ABCDEFGHIJKLMNOPQRSTUVWXYZ'
NUMBERS_CHARS: .asciiz ' 0123456789'
SYMBOL_CHARS: .asciiz ' !#$%&"()*+,.-/`[]^_{}|'
  

  .section '.body'

; ------------------------------
; THE PROGRAM!
; ------------------------------
reset:
  .global reset
  lda #0
  sta EDITOR_MODE
  lda #1
  sta SCREEN_CURSOR_BLINKING

  jsr intitialize_character_sets

  rts

loop:
  .global loop
  rts

  .section '.body'

; ------------------------------
; BUTTON HANDLERS
; ------------------------------

;
; BUTTON 1
;
on_up_button_press:
  .global on_up_button_press
  lda EDITOR_MODE
  beq on_up_button_press__move_mode
  cmp #1
  bne on_up_button_press__insert_mode
 
on_up_button_press__insert_mode:
  jsr increment_char_at_cursor_pos
  jmp on_up_button_press__exit

on_up_button_press__move_mode:
  jsr on_up_button_press_move_mode
  jmp on_up_button_press__exit

on_up_button_press__exit:
  rts


; moves the cursor location to the top row
on_up_button_press_move_mode:
  lda SCREEN_CURSOR_ROW
  beq on_up_button_press_move_mode__exit
  lda #0
  sta SCREEN_CURSOR_ROW
on_up_button_press_move_mode__exit:
  rts

;
; right button press handler
;
on_right_button_press:
  .global on_right_button_press
  lda EDITOR_MODE
  beq on_right_button_press__move_mode
  bne on_right_button_press__insert_mode

on_right_button_press__move_mode:
  jsr on_right_button_press_move_mode
  jmp on_right_button_press__exit

on_right_button_press__insert_mode:
  jsr on_right_button_press_insert_mode
  jmp on_right_button_press__exit

on_right_button_press__exit:
  rts


; on right button when in move mode
on_right_button_press_move_mode:
  lda SCREEN_CURSOR_POS
  clc
  cmp #15
  beq on_right_button_press_move_mode__exit
  inc SCREEN_CURSOR_POS
on_right_button_press_move_mode__exit:
  rts

; on right button when in insert mode
on_right_button_press_insert_mode:
  jsr set_next_editor_mode_at_cursor
  rts




;
; down button press handler
;
on_down_button_press:
  .global on_down_button_press
  lda EDITOR_MODE
  beq on_down_button_press__move_mode
  cmp #1
  bne on_down_button_press__insert_mode
 
on_down_button_press__insert_mode:
  jsr decrement_char_at_cursor_pos
  jmp on_down_button_press__exit

on_down_button_press__move_mode:
  jsr on_down_button_press_move_mode
  jmp on_down_button_press__exit

on_down_button_press__exit:
  rts

; moves the cursor location to the top row
on_down_button_press_move_mode:
  lda SCREEN_CURSOR_ROW
  cmp #1
  beq on_down_button_press_move_mode__exit
  lda #1
  sta SCREEN_CURSOR_ROW
on_down_button_press_move_mode__exit:
  rts


;
; left button press handler
;
on_left_button_press:
  .global on_left_button_press
  lda EDITOR_MODE
  beq on_left_button_press__move_mode
  bne on_left_button_press__insert_mode

on_left_button_press__move_mode:
  jsr on_left_button_press_move_mode
  jmp on_left_button_press__exit

on_left_button_press__insert_mode:
  jsr on_left_button_press_insert_mode
  jmp on_left_button_press__exit

on_left_button_press__exit:
  rts


; on left button when in move mode
on_left_button_press_move_mode:
  lda SCREEN_CURSOR_POS
  beq on_left_button_press_move_mode__exit
  dec SCREEN_CURSOR_POS
on_left_button_press_move_mode__exit:
  rts

; on left button when in insert mode
on_left_button_press_insert_mode:
  jsr set_previous_editor_mode_at_cursor
  rts




;
; action button handler
;
on_action_button_press:
  .global on_action_button_press

  lda EDITOR_MODE
  ; if we are in movment mode, transition to insert mode
  beq on_action_button_press__enable_insert_mode
  bne on_action_button_press__enable_movement_mode

on_action_button_press__enable_insert_mode:
  lda #0
  sta SCREEN_CURSOR_BLINKING
  lda #1
  sta EDITOR_MODE
  jmp on_action_button_press__exit
  
on_action_button_press__enable_movement_mode:
  lda #1
  sta SCREEN_CURSOR_BLINKING
  lda #0
  sta EDITOR_MODE
  jmp on_action_button_press__exit

on_action_button_press__exit:
  rts



; ------------------------------
; INITIALIZATION ROUTINES
; ------------------------------

intitialize_character_sets:
  lda #3
  ldy #0
intitialize_character_sets__line_1_loop:
  sta LINE_1_CHAR_SET,Y
  iny
  cpy #15
  bne intitialize_character_sets__line_1_loop

  ldy #0
intitialize_character_sets__line_2_loop:
  lda #4
  sta LINE_2_CHAR_SET,Y
  iny
  cpy #15
  bne intitialize_character_sets__line_2_loop

  rts


; ------------------------------
; FUNCTIONAL ROUTINES
; ------------------------------

; sets the editor mode at the currrent cursor
; to the next editor mode
set_next_editor_mode_at_cursor:
  jsr get_editor_mode_at_cursor
  cmp #4
  beq set_next_editor_mode_at_cursor__wrap
  bne set_next_editor_mode_at_cursor__inc

set_next_editor_mode_at_cursor__wrap:
  lda #1
  jsr set_editor_mode_at_cursor
  jmp set_next_editor_mode_at_cursor__update_cursor

set_next_editor_mode_at_cursor__inc:
  clc
  adc #1
  jsr set_editor_mode_at_cursor
  jmp set_next_editor_mode_at_cursor__update_cursor

set_next_editor_mode_at_cursor__update_cursor:
  jsr update_character_at_cursor_for_new_character_set

set_next_editor_mode_at_cursor__exit:
  rts

; sets the editor mode at the currrent cursor
; to the previous editor mode
set_previous_editor_mode_at_cursor:
  jsr get_editor_mode_at_cursor
  cmp #1
  beq set_previous_editor_mode_at_cursor__wrap
  bne set_previous_editor_mode_at_cursor__dec

set_previous_editor_mode_at_cursor__wrap:
  lda #4
  jsr set_editor_mode_at_cursor
  jmp set_previous_editor_mode_at_cursor__update_cursor

set_previous_editor_mode_at_cursor__dec:
  sec
  sbc #1
  jsr set_editor_mode_at_cursor
  jmp set_previous_editor_mode_at_cursor__update_cursor

set_previous_editor_mode_at_cursor__update_cursor:
  jsr update_character_at_cursor_for_new_character_set

set_previous_editor_mode_at_cursor__exit:
  rts


; sets the cursor at the current position based on the editor
; mode set for the current cursor pos
update_character_at_cursor_for_new_character_set:
  jsr get_character_at_cursor
  sta TMP
  cmp #' '
  beq update_character_at_cursor_for_new_character_set__exit
  bne update_character_at_cursor_for_new_character_set__non_space_char

update_character_at_cursor_for_new_character_set__non_space_char:
  jsr load_addr_arg_1_with_current_char_set
  ldy #1
  lda (ADDR_ARG_1),Y
  jsr set_character_at_cursor
  jmp update_character_at_cursor_for_new_character_set__exit

update_character_at_cursor_for_new_character_set__exit:
  rts

; sets the editor mode at the current cursor to 
; the value passed in the A register
set_editor_mode_at_cursor:
  sta TMP
  ldy SCREEN_CURSOR_POS
  lda SCREEN_CURSOR_ROW
  beq set_editor_mode_at_cursor__line_1
  bne set_editor_mode_at_cursor__line_2

set_editor_mode_at_cursor__line_1:
  lda TMP
  sta LINE_1_CHAR_SET,y
  jmp get_character_at_cursor__exit
set_editor_mode_at_cursor__line_2:
  lda TMP
  sta LINE_2_CHAR_SET,y
  jmp get_character_at_cursor__exit

set_editor_mode_at_cursor__exit:
  rts


; returns the character currently under the cursor
get_character_at_cursor:
  ldy SCREEN_CURSOR_POS
  lda SCREEN_CURSOR_ROW
  beq get_character_at_cursor__line_1
  bne get_character_at_cursor__line_2

get_character_at_cursor__line_1:
  lda SCREEN_OUT_1,y
  jmp get_character_at_cursor__exit
get_character_at_cursor__line_2:
  lda SCREEN_OUT_2,y
  jmp get_character_at_cursor__exit

get_character_at_cursor__exit:
  rts


; sets character at current cursor position into the A register
get_editor_mode_at_cursor:
  ldy SCREEN_CURSOR_POS
  lda SCREEN_CURSOR_ROW
  beq get_editor_mode_at_cursor__line_1
  bne get_editor_mode_at_cursor__line_2

get_editor_mode_at_cursor__line_1:
  lda LINE_1_CHAR_SET,y
  jmp get_editor_mode_at_cursor__exit
get_editor_mode_at_cursor__line_2:
  lda LINE_2_CHAR_SET,y
  jmp get_editor_mode_at_cursor__exit

get_editor_mode_at_cursor__exit:
  rts


; set the character at the cursor to the value in a
set_character_at_cursor:
  sta TMP
  ldy SCREEN_CURSOR_POS
  lda SCREEN_CURSOR_ROW
  beq set_character_at_cursor__line_1
  bne set_character_at_cursor__line_2

set_character_at_cursor__line_1:
  lda TMP
  sta SCREEN_OUT_1,Y
  jmp set_character_at_cursor__exit

set_character_at_cursor__line_2:
  lda TMP
  sta SCREEN_OUT_2,Y
  jmp set_character_at_cursor__exit

set_character_at_cursor__exit:
  rts


load_addr_arg_1_with_current_char_set:
  jsr get_editor_mode_at_cursor

  cmp #1
  beq load_addr_arg_1_with_current_char_set__mode_1
  cmp #2
  beq load_addr_arg_1_with_current_char_set__mode_2
  cmp #3
  beq load_addr_arg_1_with_current_char_set__mode_3
  cmp #4
  beq load_addr_arg_1_with_current_char_set__mode_4


load_addr_arg_1_with_current_char_set__mode_1:
  lda #(<LOWER_CASE_CHARS)
  sta ADDR_ARG_1
  lda #(>LOWER_CASE_CHARS)
  sta ADDR_ARG_1 + 1
  jmp load_addr_arg_1_with_current_char_set__mode_select_exit
load_addr_arg_1_with_current_char_set__mode_2:
  lda #(<UPPER_CASE_CHARS)
  sta ADDR_ARG_1
  lda #(>UPPER_CASE_CHARS)
  sta ADDR_ARG_1 + 1
  jmp load_addr_arg_1_with_current_char_set__mode_select_exit
load_addr_arg_1_with_current_char_set__mode_3:
  lda #(<NUMBERS_CHARS)
  sta ADDR_ARG_1
  lda #(>NUMBERS_CHARS)
  sta ADDR_ARG_1 + 1
  jmp load_addr_arg_1_with_current_char_set__mode_select_exit
load_addr_arg_1_with_current_char_set__mode_4:
  lda #(<SYMBOL_CHARS)
  sta ADDR_ARG_1
  lda #(>SYMBOL_CHARS)
  sta ADDR_ARG_1 + 1
  jmp load_addr_arg_1_with_current_char_set__mode_select_exit

load_addr_arg_1_with_current_char_set__mode_select_exit:
  rts




; -------------------------------------------
; get the next char for the current pos
; -------------------------------------------

increment_char_at_cursor_pos:
  jsr load_addr_arg_1_with_current_char_set

  jsr get_character_at_cursor
  sta TMP
  ldy #0

increment_char_at_cursor_pos__find_current_char_loop:
  lda (ADDR_ARG_1),Y
  
  ; if the value matches our current char, exit
  cmp TMP
  beq increment_char_at_cursor_poos__current_char_found_at_y

  ; if the value is the end of the array, then exit
  cmp #0
  beq increment_char_at_cursor_pos__current_char_not_found

  iny
  jmp increment_char_at_cursor_pos__find_current_char_loop

increment_char_at_cursor_poos__current_char_found_at_y:
  ; get the next character to render out
  iny 
  lda (ADDR_ARG_1),Y

  cmp 0
  beq increment_char_at_cursor_poos__current_char_found_at_y__wrap_around

  ; if the next char isn't the end of the character set
  ; set the value to zero and exit
  jsr set_character_at_cursor
  jmp increment_char_at_cursor_pos__exit

increment_char_at_cursor_poos__current_char_found_at_y__wrap_around:
  ; if our current character was the last in the array, set it to be the first
  ; char in the array
  ldy #0
  lda (ADDR_ARG_1),Y
  jsr set_character_at_cursor

  jmp increment_char_at_cursor_pos__exit

increment_char_at_cursor_pos__current_char_not_found:
  ; if our character wasn't found, then just set it to be the first char
  ; in the current character set
  ldy #0
  lda (ADDR_ARG_1),Y
  jsr set_character_at_cursor
  jmp increment_char_at_cursor_pos__exit

increment_char_at_cursor_pos__exit:
  rts

; -------------------------------------------
; decrememnt the char at the current position
; -------------------------------------------

decrement_char_at_cursor_pos:
  jsr get_editor_mode_at_cursor

  cmp #1
  beq decrement_char_at_cursor_pos__mode_1
  cmp #2
  beq decrement_char_at_cursor_pos__mode_2
  cmp #3
  beq decrement_char_at_cursor_pos__mode_3
  cmp #4
  beq decrement_char_at_cursor_pos__mode_4


decrement_char_at_cursor_pos__mode_1:
  lda #(<LOWER_CASE_CHARS)
  sta ADDR_ARG_1
  lda #(>LOWER_CASE_CHARS)
  sta ADDR_ARG_1 + 1
  jmp decrement_char_at_cursor_pos__mode_select_exit
decrement_char_at_cursor_pos__mode_2:
  lda #(<UPPER_CASE_CHARS)
  sta ADDR_ARG_1
  lda #(>UPPER_CASE_CHARS)
  sta ADDR_ARG_1 + 1
  jmp decrement_char_at_cursor_pos__mode_select_exit
decrement_char_at_cursor_pos__mode_3:
  lda #(<NUMBERS_CHARS)
  sta ADDR_ARG_1
  lda #(>NUMBERS_CHARS)
  sta ADDR_ARG_1 + 1
  jmp decrement_char_at_cursor_pos__mode_select_exit
decrement_char_at_cursor_pos__mode_4:
  lda #(<SYMBOL_CHARS)
  sta ADDR_ARG_1
  lda #(>SYMBOL_CHARS)
  sta ADDR_ARG_1 + 1
  jmp decrement_char_at_cursor_pos__mode_select_exit

decrement_char_at_cursor_pos__mode_select_exit:

  jsr get_character_at_cursor
  sta TMP
  ldy #0

decrement_char_at_cursor_pos__find_current_char_loop:
  lda (ADDR_ARG_1),Y
  
  ; if the value matches our current char, exit
  cmp TMP
  beq decrement_char_at_cursor_poos__current_char_found_at_y

  ; if the value is the end of the array, then exit
  cmp #0
  beq decrement_char_at_cursor_pos__current_char_not_found

  iny
  jmp decrement_char_at_cursor_pos__find_current_char_loop

decrement_char_at_cursor_poos__current_char_found_at_y:
  ; if y is 0, we need to get the last value in our list
  cpy #0
  beq decrement_char_at_cursor_poos__current_char_found_at_y__wrap_around


  ; otherwise, get get the previous character to render out
  dey
  lda (ADDR_ARG_1),Y
  jsr set_character_at_cursor
  jmp decrement_char_at_cursor_pos__exit

decrement_char_at_cursor_poos__current_char_found_at_y__wrap_around:
  ; loop through the chars until we find the last one
  ldy #0
decrement_char_at_cursor_poos__current_char_found_at_y__wrap_around__loop:
  lda (ADDR_ARG_1),Y
  cmp #0
  beq decrement_char_at_cursor_poos__current_char_found_at_y__wrap_around__loop_exit
  iny
  jmp decrement_char_at_cursor_poos__current_char_found_at_y__wrap_around__loop
decrement_char_at_cursor_poos__current_char_found_at_y__wrap_around__loop_exit:
  dey
  lda (ADDR_ARG_1),Y
  jsr set_character_at_cursor
  jmp decrement_char_at_cursor_pos__exit


decrement_char_at_cursor_pos__current_char_not_found:
  ; if our character wasn't found, then just set it to be the first char
  ; in the current character set
  ldy #0
  lda (ADDR_ARG_1),Y
  jsr set_character_at_cursor
  jmp decrement_char_at_cursor_pos__exit

decrement_char_at_cursor_pos__exit:
  rts

  .section '.routines'
