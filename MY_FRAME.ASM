.model tiny
.code
org 100h
x_offset                           = 30d
length_of_terminal_string          = 80d*2h ; length of terminal string
length_of_horizontal_part_of_frame = 40d    ; length of horizontal border


VIDEOSEG        equ 0B800h

start:          mov ax, VIDEOSEG
                mov es, ax

                mov si, 5h                                 ; 5h = number strings to skip
                mov cx, length_of_horizontal_part_of_frame ; length of the border
                mov di, 5d                                 ; number border's strings

                call CalculateCoordinates
                call PrintHorizontalPartOfFrame

print_vertical_part_of_frame:
                cmp di, 00d
                je  end_of_program
                dec di
                inc si
                call CalculateCoordinates
                jmp one_vertical_part_of_frame

one_vertical_part_of_frame:
                cmp cx, length_of_horizontal_part_of_frame
                je  print_one_vertical_part_of_frame
                cmp di, 2
                je  second_conditional
back3:
                add bx, 2h
                loop one_vertical_part_of_frame

                mov cx, length_of_horizontal_part_of_frame
                mov es:[bx], 0DBAh                          ; print "||" (bright magenta on black)
                jmp print_vertical_part_of_frame

print_one_vertical_part_of_frame:
                mov es:[bx], 0DBAh                          ; (bright magenta on black)
                dec cx
                jmp one_vertical_part_of_frame

second_conditional:
                cmp cx, 18h                                 ; from which value start print terminal string
                je  print_string_length
                jmp back3

print_string_length:
                call PrintString
                jmp one_vertical_part_of_frame

end_of_program:
                inc si
                call CalculateCoordinates
                mov cx, length_of_horizontal_part_of_frame
                call PrintHorizontalPartOfFrame

                mov ax, 4c00h
                int 21h

;------------------------------------------------------------------------
; Calculate Coordinates of videomemory in registrs BX and SI
; Expect: BX, SI
; Exit:   BX - calculated index
; Destr:  AX
;-------------------------------------------------------------------------
CalculateCoordinates proc
                mov ax, length_of_terminal_string
                mul si
                mov bx, ax
                add bx, x_offset
                ret
                endp

;---------------------------------------------------------------------------
;Print: terminal string (length = ds:[80h]) begin from [82h]
;Entry: no
;Exit:  no
;Destr: CX(++), BX (+=2), AX
;---------------------------------------------------------------------------
PrintString proc
                push cx
                push si
                push bx
                xor cx, cx
                mov cl, ds:[80h]
                dec cl                 ; dont need last symbol = '<enter>'
                mov si, 82h

horizontal_string:
                mov al, [si]
                mov ah, 0Bh            ; bright cyan on black
                mov es:[bx], ax
                add bx, 2h
                inc si
                loop horizontal_string

                pop bx
                pop si
                pop cx
                dec cx
                add bx, 2h
                ret
                endp

;-------------------------------------------------------------------------
; Print horizontal border length <cx> to videomemory [bx]
; Expect: CX - length of border
;         BX - adress from which border was writted
; Exit:   nothing
; Destr:  BX
;--------------------------------------------------------------------------
PrintHorizontalPartOfFrame proc
                push cx
horizontal_frame:
                cmp di, 5d
                je  upper_corner
                cmp di, 0h
                je  bottom_corner
next:
                jmp next2

upper_corner:
                cmp cx, length_of_horizontal_part_of_frame
                je  left_upper_corner
                cmp cx, 1d
                je  right_upper_corner
                jmp next2

left_upper_corner:
                mov es:[bx], 0DC9h                         ; print left up corner (magenta)
                jmp next3

right_upper_corner:
                mov es:[bx], 0DBBh                         ; print right bottom corner (magenta)
                jmp next3

bottom_corner:
                cmp cx, length_of_horizontal_part_of_frame
                je  left_back_corner
                cmp cx, 1d
                je  right_back_corner
                jmp next2

left_back_corner:
                mov es:[bx], 0DC8h                         ; print left up corner (magenta)
                jmp next3

right_back_corner:
                mov es:[bx], 0DBCh                         ; print left bottom corner (magenta)
                jmp next3

next2:
                mov es:[bx], 0DCDh                         ; print '=' (magenta)
next3:
                add bx, 2h
                loop horizontal_frame
                pop cx
                ret
                endp

end start
