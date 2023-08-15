  org  0x5ccb
  ld hl, (path_list_tail)
loop2
;  ld (current_path), hl
  ld a, h
  cp 0
  jp z, infinite_loop
  push hl
  pop iy
  ld h, (iy + 0)
  ld l, (iy + 1)
  ;check if x > 0
  ld a, (iy + 0)
  and a
  jz l1
  dec a
  ld h, a
  ld l, (iy + 1)
  call create_new_node
  jnz l1
  ex de, hl
  call create_new_path
  call check_node
  ret z
l1
  ;check if x < 7
  ld a, (iy + 0)
  sub 7
  jz l2
  ld h, (iy + 0)
  inc h
  ld l, (iy + 1)
  call create_new_node
  jnz l2
  ex de, hl
  call create_new_path
  call check_node
  ret z
l2
  ;check if y > 0
  ld a, (iy + 1)
  and a
  jz l1
  ld h, (iy + 0)
  ld l, a
  call create_new_node
  jnz l3
  ex de, hl
  call create_new_path
  call check_node
  ret z
l3
  ;check if y < 7
  ld a, (iy + 1)
  sub 7
  jz l2
  ld l, (iy + 1)
  inc l
  ld h, (iy + 0)
  call create_new_node
  jnz l4
  ex de, hl
  call create_new_path
  call check_node
  ret z
l4
  ld hl, current_path
  push hl
  pop iy
  ld h, (iy + 2)
  ld l, (iy + 3)
  push hl
  pop iy
  ld h, (iy + 2)
  ld l, (iy + 3)
  push hl
  pop iy
  ld h, (iy + 2)
  ld l, (iy + 3)
  push hl
  pop iy
  ld h, (iy + 2)
  ld l, (iy + 3)
  jp loop2

check_node
  ;de - node to check
  ;set Z if found
  push de
  pop ix
  ld d, (ix + 0)
  ld e, (ix + 1)
  push de
  pop ix
  ld d, (ix + 0)
  ld e, (ix + 1)
  ld hl, (goal)
  ld a, h
  cp d
  ret nz
  ld a, l
  cp e
  ret


create_new_path
  ;hl - head
  ;de - new head
  ld a, 4
  push hl
  call malloc
  pop hl
  push de
  pop ix
  ld (ix + 0), h
  ld (ix + 1), l
  ld (ix + 2), 0
  ld (ix + 3), 0
  ld hl, (path_list_tail)
  push hl
  pop ix
  ld (ix + 2), d
  ld (ix + 3), e
  ld (path_list_tail), de
  ret

create_new_node
  ;h - x
  ;l - y
  ;returns new node in de
  ;set Z if false
  ld ix, prev_nodes_head
check1
  ld a, (ix + 0)
  cp h
  jp nz, next
  ld a, (ix + 1)
  cp l
  ret z
next
  ld d, (ix + 2)
  ld e, (ix + 3)
  ld a, d
  and a
  jz check2
  push de
  pop ix
  jp check1
check2
  ;h - x
  ;l - y
  ;add new node into the list
  ld a, 4
  push hl
  call malloc
  pop hl
  push de
  pop ix
  ld (ix + 0), h
  ld (ix + 1), l
  ld hl, prev_nodes_head
  ld (ix + 2), h
  ld (ix + 3), l
  ld ix, prev_nodes_head
  ld (ix + 0), e
  ld (ix + 1), d
  ret






  ld hl, hello
  ld de, world
  call concat
  ld hl, $4000
  call print_word
  jp infinite_loop


len
  ;hl - Input string
  ;c - Output
  ld c, 0
len1
  ld a, (hl)
  cp 0
  ret z
  inc c
  inc hl
  jp len1


concat
  ;de - Input string 1
  ;hl - Input string 2
  ;de - Output string
  push de
  push hl
  ld a, (de)
  add (hl)
  call malloc
  pop hl
  push de
  ld c, (hl)
  inc hl
  ldir
  pop hl
  ex (sp), hl
  ld c, (hl)
  inc hl
  ldir
  pop de
  ret

malloc
  ;a - Number of bytes to allocate
  ;de - Out address of array allocated
  ld de, (user_memory)
  push de
  pop hl
  ld b, 0
  ld c, a
  add hl, bc
  ld (user_memory), hl
  ret


to_hex
  ;a - Input value
  ;de - Output
  push af
  ld a, 3
  call malloc
  pop af
  push af
  call separator
  ld (de), a ;Adding an ASCII value in array of certain ASCII values
  pop af
  rr a
  rr a
  rr a
  rr a
  call separator
  inc de
  ld (de), a
  dec de
  ret

separator ;Gets 4-bit number (a part of 8-bit) and convert it into HEX
  ;a - Input value
  ld c, 15
  and c
  ld b, 0
  ld c, a
  ld hl, bits
  add hl, bc
  ld a, (hl) ;ASCII value of symbol
  ret

print_word ;Gets an array of certain ASCII values and passes each value in print_char
  ;de - Input array
  ;hl - Screen adress
  ;a - Output value
  ld a, (de) ;Taking an ASCII value from array of certain ASCII values
  and a
  ret z
  push de
  push hl
  call print_char
  pop hl
  pop de
  inc hl
  inc de
  jp print_word

print_char ;Gets ASCII value and convert it into text
  ;a - Input value
  ld b, 0
  push hl
  sub a, 32
  ld c, a
  rl c
  rl b
  rl c
  rl b
  rl c
  rl b ;Getting the index of the symbol beginning
  ld hl, symbol_table ;Graphic table of symbols
  add hl, bc
  ex de, hl
  pop hl
  ld b, 8 ;Line counter
loop ;Prints symbol line by line
  ;de - Input array
  ld a, (de)
  ld (hl), a
  inc de
  inc h
  djnz loop
  ret

get_labirint_cell
  ;d - x
  ;e - y
  ;returns cell value in a
  ld hl, labirint
  rl e
  rl e
  rl e
  ld a, e
  add a, d
  ld e, a
  ld d, 0
  add hl, de
  ld a, (hl)
  ret

infinite_loop
  jp infinite_loop

hello
  defb 5, "HELLO"

world
  defb 5, "WORLD"


bits
  defb "0123456789ABCDEF"

labirint
  defb 0,0,0,0,0,0,0,0
  defb 0,0,0,0,0,0,0,0
  defb 0,0,0,0,0,0,0,0
  defb 0,0,1,0,0,0,0,0
  defb 0,0,0,0,0,0,0,0
  defb 0,0,0,0,0,0,0,0
  defb 0,0,0,0,0,0,0,0
  defb 0,0,0,0,0,0,0,0

symbol_table
  ;space
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  ;.
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  ;.
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  ;.
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  ;.
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  ;.
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  ;.
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  ;.
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  ;.
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  ;.
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  ;.
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  ;.
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  ;.
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  ;.
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  ;.
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  ;.
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  ;0
  defb 00111000b
  defb 01000100b
  defb 01001100b
  defb 01010100b
  defb 01100100b
  defb 01000100b
  defb 00111000b
  defb 00000000b
  ;1
  defb 00010000b
  defb 00110000b
  defb 00010000b
  defb 00010000b
  defb 00010000b
  defb 00010000b
  defb 00111000b
  defb 00000000b
  ;2
  defb 00111000b
  defb 01000100b
  defb 00000100b
  defb 00011000b
  defb 00100000b
  defb 01000000b
  defb 01111100b
  defb 00000000b
  ;3
  defb 01111100b
  defb 00001000b
  defb 00010000b
  defb 00001000b
  defb 00000100b
  defb 01000100b
  defb 00111000b
  defb 00000000b
  ;4
  defb 00001000b
  defb 00011000b
  defb 00101000b
  defb 01001000b
  defb 01111100b
  defb 00001000b
  defb 00001000b
  defb 00000000b
  ;5
  defb 01111100b
  defb 01000000b
  defb 01111000b
  defb 00000100b
  defb 00000100b
  defb 01000100b
  defb 00111000b
  defb 00000000b
  ;6
  defb 00011000b
  defb 00100000b
  defb 01000000b
  defb 01111000b
  defb 01000100b
  defb 01000100b
  defb 00111000b
  defb 00000000b
  ;7
  defb 01111100b
  defb 00000100b
  defb 00001000b
  defb 00010000b
  defb 00100000b
  defb 00100000b
  defb 00100000b
  defb 00000000b
  ;8
  defb 00111000b
  defb 01000100b
  defb 01000100b
  defb 00111000b
  defb 01000100b
  defb 01000100b
  defb 00111000b
  defb 00000000b
  ;9
  defb 00111000b
  defb 01000100b
  defb 01000100b
  defb 00111100b
  defb 00000100b
  defb 00001000b
  defb 00110000b
  defb 00000000b
  ;.
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  ;.
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  ;.
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  ;.
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  ;.
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  ;.
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  ;.
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  defb 00000000b
  ;a
  defb 00111000b
  defb 01000100b
  defb 01000100b
  defb 01111100b
  defb 01000100b
  defb 01000100b
  defb 01000100b
  defb 00000000b
  ;b
  defb 01111000b
  defb 01000100b
  defb 01000100b
  defb 01111000b
  defb 01000100b
  defb 01000100b
  defb 01111000b
  defb 00000000b
  ;c
  defb 00111000b
  defb 01000100b
  defb 01000000b
  defb 01000000b
  defb 01000000b
  defb 01000100b
  defb 00111000b
  defb 00000000b
  ;d
  defb 01111000b
  defb 01000100b
  defb 01000100b
  defb 01000100b
  defb 01000100b
  defb 01000100b
  defb 01111000b
  defb 00000000b
  ;e
  defb 01111100b
  defb 01000000b
  defb 01000000b
  defb 01111000b
  defb 01000000b
  defb 01000000b
  defb 01111100b
  defb 00000000b
  ;f
  defb 01111100b
  defb 01000000b
  defb 01000000b
  defb 01111000b
  defb 01000000b
  defb 01000000b
  defb 01000000b
  defb 00000000b
  ;g
  defb 00111000b
  defb 01000100b
  defb 01000000b
  defb 01011100b
  defb 01000100b
  defb 01000100b
  defb 00111000b
  defb 00000000b
  ;h
  defb 01000100b
  defb 01000100b
  defb 01000100b
  defb 01111100b
  defb 01000100b
  defb 01000100b
  defb 01000100b
  defb 00000000b
  ;i
  defb 00111000b
  defb 00010000b
  defb 00010000b
  defb 00010000b
  defb 00010000b
  defb 00010000b
  defb 00111000b
  defb 00000000b
  ;j
  defb 00001110b
  defb 00000100b
  defb 00000100b
  defb 00000100b
  defb 00000100b
  defb 00100100b
  defb 00011000b
  defb 00000000b
  ;k
  defb 01000100b
  defb 01001000b
  defb 01010000b
  defb 01100000b
  defb 01010000b
  defb 01001000b
  defb 01000100b
  defb 00000000b
  ;l
  defb 01000000b
  defb 01000000b
  defb 01000000b
  defb 01000000b
  defb 01000000b
  defb 01000000b
  defb 01111100b
  defb 00000000b
  ;m
  defb 01000100b
  defb 01101100b
  defb 01010100b
  defb 01010100b
  defb 01000100b
  defb 01000100b
  defb 01000100b
  defb 00000000b
  ;n
  defb 01000100b
  defb 01100100b
  defb 01010100b
  defb 01001100b
  defb 01000100b
  defb 01000100b
  defb 01000100b
  defb 00000000b
  ;o
  defb 00111000b
  defb 01000100b
  defb 01000100b
  defb 01000100b
  defb 01000100b
  defb 01000100b
  defb 00111000b
  defb 00000000b
  ;p
  defb 01111000b
  defb 01000100b
  defb 01000100b
  defb 01111000b
  defb 01000000b
  defb 01000000b
  defb 01000000b
  defb 00000000b
  ;q
  defb 00111000b
  defb 01000100b
  defb 01000100b
  defb 01000100b
  defb 01010100b
  defb 01001000b
  defb 00110100b
  defb 00000000b
  ;r
  defb 01111000b
  defb 01000100b
  defb 01000100b
  defb 01111000b
  defb 01010000b
  defb 01001000b
  defb 01000100b
  defb 00000000b
  ;s
  defb 00111000b
  defb 01000100b
  defb 01000000b
  defb 00111000b
  defb 00000100b
  defb 01000100b
  defb 00111000b
  defb 00000000b
  ;t
  defb 01111100b
  defb 00010000b
  defb 00010000b
  defb 00010000b
  defb 00010000b
  defb 00010000b
  defb 00010000b
  defb 00000000b
  ;u
  defb 01000100b
  defb 01000100b
  defb 01000100b
  defb 01000100b
  defb 01000100b
  defb 01000100b
  defb 00111000b
  defb 00000000b
  ;v
  defb 01000100b
  defb 01000100b
  defb 01000100b
  defb 01000100b
  defb 00101000b
  defb 00101000b
  defb 00010000b
  defb 00000000b
  ;w
  defb 01000100b
  defb 01000100b
  defb 01000100b
  defb 01000100b
  defb 01010100b
  defb 01010100b
  defb 00101000b
  defb 00000000b
  ;x
  defb 01000100b
  defb 01000100b
  defb 00101000b
  defb 00010000b
  defb 00101000b
  defb 01000100b
  defb 01000100b
  defb 00000000b
  ;y
  defb 01000100b
  defb 01000100b
  defb 01000100b
  defb 00101000b
  defb 00010000b
  defb 00010000b
  defb 00010000b
  defb 00000000b
  ;z
  defb 01111100b
  defb 00000100b
  defb 00001000b
  defb 00010000b
  defb 00100000b
  defb 01000000b
  defb 01111100b
  defb 00000000b

  org 8000h

goal
  defb 6, 6

current_path
  defb 2, 1
  defw 0

path_list_tail
  defw current_path
  defw 0

prev_nodes_head
  defb 2, 1
  defw 0

user_memory
  defw user_memory_base

user_memory_base
  defb 0

  org 0xff57
        defb 00h