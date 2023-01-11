;-----------------------
; Asaf 	delay2.asm
;-----------------------
IDEAL
MODEL small
STACK 100h
DATASEG
CODESEG
;--------------------------
proc proc_delay 
	push ax
	push cx
	push dx
	mov cx, 1 		;HIGH WORD.
	mov dx, 08690h 	;LOW WORD(time of the delay).
	mov ah, 86h    	;WAIT numbers of milli-seconds
	int 15h   		;WAIT interrupt
	pop dx
	pop cx
	pop ax
	ret             
endp proc_delay 
;--------------------------
proc delay 
	push cx
	mov cx, 0Fh
DL1:
	push cx
	mov cx, 0FFFh
DL2:
	nop
	loop DL2
	pop cx
	loop DL1
	pop cx
	ret             
endp delay 
; --------------------------
start:
	mov ax, @data
	mov ds, ax
; --------------------------
; Your code here					
; --------------------------
begin:
	mov cx, 5
loop1:	
	mov ah, 02h
	mov dl,	'*'
	int 21h
	call delay	
	mov dl,	','
	int 21h
	call proc_delay
	loop loop1 
exit:
mov ax, 4c00h
int 21h
END start