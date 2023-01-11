;Omer Rahamim
IDEAL
MODEL small
STACK 1000h
DATASEG
; --------------------------
; Your variables here
; --------------------------
	msg db 'a=do, w= do#, s= re, e= re#, d= mi, f= fa, t=fa#, g= sol, y= sol#, h= la, u= la#, j= si', 10, 13, '$'
	saveKey db 0
	sound dw ?
	note db ?
	c6 dw 1141
	cf6 dw 1076
	d6 dw 1016
	df6 dw 958
	e6 dw 904
	f6 dw 854
	ff6 dw 806
	g6 dw 1436;761
	gf6 dw 718
	a6 dw 678
	af6 dw 640
	b6 dw 1207;604
	cx1 dw ?
	cx2 dw ? 
CODESEG
proc delay 
	push cx
	mov cx, [cx1] ; מהירות של כל תו
DL1:
	push cx
	mov cx, [cx2]
DL2:
	nop
	loop DL2
	pop cx
	loop DL1
	pop cx
	ret             
endp delay 
proc everynote
play:
;turn on speakers
	in al, 61h
	or al, 00000011b
	out 61h, al
;change notes                                         
	mov ax, bx
	out 42h, al
	mov al, ah
	out 42h, al
	call delay
; turn off speakers	
turnoff:	 
	in al, 61h;
	and al, 11111100b
	out 61h, al
	ret
endp everynote	
start:  
	mov ax, @data
	mov ds, ax
	mov [cx1], 0AAAh
	mov [cx2], 0Ah
	mov cx, 5
	mov bx, [c6]
notec:
	call everynote
	loop notec
	call delay
	
	mov cx, 5
notec2:
	call everynote
	loop notec2
	call delay
	
	mov cx, 5
notec3:
	call everynote
	loop notec3
	call delay
	
	mov cx, 15
notec4:
	call everynote
	loop notec4
	call delay
	
	mov cx, 15
	mov bx, [g6]
noteg:
	call everynote
	loop noteg
	call delay
	
	mov cx, 15
	mov bx, [b6]
noteb:
	call everynote
	loop noteb
	call delay
	
	mov cx, 12
	mov bx, [b6]
noteb2:
	call everynote
	loop noteb2
	call delay
	
	mov cx, 3
	mov bx, [b6]
noteb3:
	call everynote
	loop noteb3
	call delay
	
	mov cx, 20
	mov bx, [b6]
notec6:
	call everynote
	loop notec6

;--------------------------------------------	
exit:
	mov ax, 4c00h
	int 21h
END start

;NOTES
;good dialog sound
	mov ax, bx
	out 42h, al
	out 42h, al 