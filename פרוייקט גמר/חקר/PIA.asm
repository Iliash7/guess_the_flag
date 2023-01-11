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
	g6 dw 761
	gf6 dw 718
	a6 dw 678
	af6 dw 640
	b6 dw 604
CODESEG
proc everynote
play:
;turn on speakers
	in al, 61h
	or al, 00000011b
	out 61h, al
;gain premission to change frequency
	mov al, 0B6h
	out 43h, al
;change notes
	mov ax, cx
	out 42h, al
	mov al, ah
	out 42h, al 
;check keyboard	
WaitForKey:
	;check if there is a a new key in buffer
	in al, 64h
	cmp al, 10b
	je WaitForKey
	in al, 60h
	;check if the key is same as already pressed
	cmp al, [saveKey]
	je WaitForKey
	;new key- store it
	mov [saveKey], al
	;check if the key was pressed or released
	and al, 80h
	jnz turnoff
	jmp play	
; turn off speakers	
turnoff:	 
	in al, 61h
	and al, 11111100b
	out 61h, al
	ret 
endp everynote	
start:  
	mov ax, @data
	mov ds, ax
	mov ah, 2
	mov dl, 10
	int 21h
	mov ah, 9
	mov bl, 9 ;<--- color, eg bright blue in this case
	mov cx, 11 ;<--- number of chars
	int 10h
	
	mov dx, offset msg
	mov ah, 9
	int 21h
	mov ah, 9h
	int 21h;message
input:
;input	
	mov ah, 1h
	int 21h
cmpnote:
	cmp al, 'a'
	je notec
	cmp al, 'w'
	je notecf
	cmp al, 's'
	je noted
	cmp al, 'e'
	je notedf
	cmp al, 'd'
	je notee
	cmp al, 'f'
	je notef
	cmp al, 't'
	je noteff
	cmp al, 'g'
	je noteg
	cmp al, 'y'
	je notegf
	cmp al, 'h'
	je notea
	cmp al, 'u'
	je noteaf
	cmp al, 'j'
	je noteb
	cmp al, 1Bh
	je exit
	jne start
notec:
	mov cx, [c6]
	call everynote
	jmp input
notecf:
	mov cx, [cf6]
	call everynote
	jmp input
noted:
	mov cx, [d6]
	call everynote
	jmp input
notedf:
	mov cx, [df6]
	call everynote
	jmp input	
notee:
	mov cx, [e6]
	call everynote
	jmp input
notef:
	mov cx, [f6]
	call everynote
	jmp input
noteff:
	mov cx, [ff6]
	call everynote
	jmp input	
noteg:
	mov cx, [g6]
	call everynote
	jmp input
notegf:
	mov cx, [gf6]
	call everynote
	jmp input	
notea:
	mov cx, [a6]
	call everynote
	jmp input
noteaf:
	mov cx, [af6]
	call everynote
	jmp input	
noteb:
	mov cx, [b6]
	call everynote
	jmp input	
;--------------------------------------------	
exit:
	mov ax, 4c00h
	int 21h
END start