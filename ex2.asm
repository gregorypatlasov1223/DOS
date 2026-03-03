.model tiny
.code
org 100h

start:		mov ax, 0 ; table of interuptrs
		mov es, ax
		cli

		mov bx, 09h * 4
		mov es:[bx], offset oldnew09 ; write adress of new our function
		mov ax, cs
		mov es:[bx+2], ax ; [bx
		sti

		mov ax, 3100h
		mov dx, offset endofprogramm  ; in paragraphes (one = 16 bytes)
		shr dx, 4  ; div by 16 because of paragraphes
		inc dx     ; prozapas
		int 21h

oldnew09	proc
		push ax bx es di cx ; remember

		mov ax, 0b800h
		mov es, ax

		mov bx, (5*80d + 40d) * 2
		mov ah, 4eh

		in al, 60h
		xor di, di
		xor cx, cx
		mov cl, al
		mov di, cx

		mov es:[bx+di], ax

;		BLINK HIGHT BIT
		in al, 61h ; in 61h port we need blink bit
		or al, 80h ; set old bit to 1
		out 61h, al
		and al, not 80h ; not 80h = 7fh
		out 61h, al

		mov al, 20h
		out 20h, al ; controller needs to know about we done our work

		pop cx di es bx ax ; reversed
		iret
		endp



endofprogramm:		; to calculate size of our programm

end		start




