.model tiny

x_offset                           = 20d*2d
length_of_terminal_string          = 80d*2h          ; 160 bytes per row
length_of_horizontal_part_of_frame = 40d

.code
org 100h

VIDEOSEG equ 0B800h

start:
                mov ax, VIDEOSEG
                mov es, ax

                mov si, 10h                                ; skip 16 lines (0..15), start at line 16
                mov cx, length_of_horizontal_part_of_frame
                mov di, 5d                                 ; number of inner rows

                call CalculateCoordinates
                call PrintHorizontalPartOfFrame

                ; как в коде друга: перед вертикалями гарантируем CX=ширина
                mov cx, length_of_horizontal_part_of_frame

print_vertical_part_of_frame:
                cmp di, 0
                je  end_of_program
                dec di
                inc si
                call CalculateCoordinates
                jmp one_vertical_part_of_frame

one_vertical_part_of_frame:
                cmp cx, length_of_horizontal_part_of_frame
                je  print_left_vertical
                cmp di, 2
                je  second_conditional

back3:
                add bx, 2
                loop one_vertical_part_of_frame

                ; ВАЖНО: этот блок ты потерял — он ставит правую границу и переводит на след. строку
                mov cx, length_of_horizontal_part_of_frame
                mov es:word ptr [bx], 0DBAh               ; рамка: bright magenta ║ on black
                jmp print_vertical_part_of_frame

print_left_vertical:
                mov es:word ptr [bx], 0DBAh               ; рамка: bright magenta ║ on black
                dec cx
                jmp one_vertical_part_of_frame

second_conditional:
                cmp cx, 35d                               ; с какого места печатать строку
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

                mov ax, 4C00h
                int 21h

;------------------------------------------------------------------------
; CalculateCoordinates: BX = SI * length_of_terminal_string + x_offset
;------------------------------------------------------------------------
CalculateCoordinates proc
                mov ax, length_of_terminal_string
                mul si
                mov bx, ax
                add bx, x_offset
                ret
CalculateCoordinates endp

;---------------------------------------------------------------------------
; PrintString: prints command tail from PSP (length = DS:[80h]), from DS:[82h]
; (сохраняем “костыль” друга: после печати делаем dec cx / add bx,2)
; Цвет текста: bright cyan (0Bh)
;---------------------------------------------------------------------------
PrintString proc
                push cx
                push si
                push bx

                xor cx, cx
                mov cl, ds:[80h]
                jcxz ps_done                 ; если аргументов нет — ничего не печатаем

                dec cl                       ; как у друга (не трогаем логику)
                mov si, 82h

horizontal_string:
                mov al, [si]
                mov ah, 0Bh                  ; текст: bright cyan on black
                mov es:word ptr [bx], ax
                add bx, 2
                inc si
                loop horizontal_string

ps_done:
                pop bx
                pop si
                pop cx
                dec cx                       ; костыль друга
                add bx, 2                    ; костыль друга
                ret
PrintString endp

;------------------------------------------------------------------------
; PrintHorizontalPartOfFrame: печатает верх/низ рамки
; Цвет рамки: bright magenta (0Dh)
;------------------------------------------------------------------------
PrintHorizontalPartOfFrame proc
                push cx

horizontal_frame:
                cmp di, 5d
                je  upper_corner
                cmp di, 0
                je  bottom_corner
                jmp draw_hor

upper_corner:
                cmp cx, length_of_horizontal_part_of_frame
                je  left_upper_corner
                cmp cx, 1
                je  right_upper_corner
                jmp draw_hor

left_upper_corner:
                mov es:word ptr [bx], 0DC9h              ; ╔ magenta
                jmp advance

right_upper_corner:
                mov es:word ptr [bx], 0DBBh              ; ╗ magenta
                jmp advance

bottom_corner:
                cmp cx, length_of_horizontal_part_of_frame
                je  left_bottom_corner
                cmp cx, 1
                je  right_bottom_corner
                jmp draw_hor

left_bottom_corner:
                mov es:word ptr [bx], 0DC8h              ; ╚ magenta
                jmp advance

right_bottom_corner:
                mov es:word ptr [bx], 0DBCh              ; ╝ magenta
                jmp advance

draw_hor:
                mov es:word ptr [bx], 0DCDh              ; ═ magenta

advance:
                add bx, 2
                loop horizontal_frame

                pop cx
                ret
PrintHorizontalPartOfFrame endp

end start
