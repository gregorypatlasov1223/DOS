.model tiny
.code
org 100h

	; read scan code and write symbol with this value of ascii code

start:		mov ax, 0b800h
		mov es, ax

		mov bx, (5*80d + 40d) * 2
		mov ah, 4eh

next:		in al, 60h  ; command "in" read from a port
		mov es:[bx], ax

		cmp al, 1h
		jne next

		mov ax, 4c00h
		int 21h


end 		start
