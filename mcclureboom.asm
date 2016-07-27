assume cs:code, ds:data
data	segment
message	db	'exit','$'
data	ends
code	segment
start:
	cli
	mov	ax,0b800h
	mov	ds,ax
	mov bx,0000h
	call clr1
	mov	al,'v'			;'cursor'
	add bx, 50h			;starting location
	mov	[bx],al
	mov	al, 2			;color
	inc	bx				
	mov	[bx],al
	inc bx
	jmp kb
exit:
	mov ah, 4ch
	int 21h		;quit to dos
keylistener:
	in	al,64h	;read from keyboard
	and	al,1	
	cmp	al,0	;see if something is pressed
	jnz	kb	;go to the kb method if it is
	ret
kb:
	in al, 64h	;get keyboard status from 64h
	and al, 1	;see if a key has been pressed and store in al
	cmp al, 0
	jz kb		;check again until one has been pressed
kbl:			;keystroke handler
	in	al,60h		;read from buffer
	mov	ch,al		;move to ch
	in	al,60h			
	cmp	al,0		;if kb is empty go back to keyboard loop
	jz	kbl
					;code for escape...jump to exit
	cmp	ch,1h
	jz	exit
	cmp	ch,81h
	jz	exit
	;code for right press
	cmp	ch,4dh
	jz	rightkey
	cmp	ch,0cdh
	jz	rightkey
	;code for left press
	cmp	ch,4bh
	jz	leftkey
	cmp	ch,0cbh
	jz	leftkey
	;code for space press
	cmp ch,39h
	jz bomb
clr1:			;clear top line
	mov	si,0
	jmp clrloop
clrloop:
	mov	al,' '
	mov	[si],al
	inc	si
	mov	al,0
	mov	[si],al
	inc	si
	cmp si,0a0h		;compare to the max value for top line
	jnz	clrloop
	ret
leftkey:
	mov	al,'v'
	mov	[bx],al
	inc bx
	mov	al,2
	mov	[bx],al
	sub bx,3
	call delay
	call clr1
	call bd
	call keylistener
	jmp  leftkey
rightkey:
	mov	al,'v'
	mov	[bx],al
	inc	bx
	mov	al,2
	mov	[bx],al
	inc bx
	call	delay
	call clr1
	call bd
	call keylistener
	jmp	rightkey
bomb:
	add bx,0a0h
	mov al,'*'
	mov [bx],al
	inc bx
	mov al, 2
	mov [bx],al
	sub bx,0a1h
	ret
bd:
	mov si,0fa0h		;highest value 'pixel' in text mode, start at bottom right
	call bombsdrop
	ret
bombsdrop:				;Pull characters down a line
	sub si,0a0h			;move up a line
	mov cl,[si]			;store color
	mov ah,2			;
	mov [si],ah			;replace with 2
	add si,0a0h			;move back down to original line
	mov [si],cl			;put the stored color in lower line
	dec si				;go to next smallest byte(i.e. the char byte)
	sub si,0a0h			;move up a row
	mov cl,[si]			;store character
	mov ah,' '			
	mov [si],ah			;replace character with ' '
	add si,0a0h			;move back down
	cmp si,0a1h			;check if done
	dec si				;move to next smallest byte
	jnz bombsdrop
	ret
delay:
	mov	dx,0ffffh
dloop:				;count from 0ffffh to 0 to delay execution
	dec	dx
	jnz	dloop
	ret
code ends
end start