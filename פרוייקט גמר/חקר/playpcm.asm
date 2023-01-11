;Ilia Shtorm
IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
; Your variables here
; --------------------------
	sound_index dw 0
	include '1.wav' ; 1038450 bytes
CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
; Your code here
; --------------------------
loop1:	
	;send DSP command 10h
	mov dx, 22ch
	mov al, 10h
	out dx, al
	
	;send byte audio sample
	mov si, [sound_index]
	mov al, [sound_index + si]
	out dx, al
	
	mov cx, 1000
delay:
	nop
	loop delay
	
	inc word [sound_index]
	cmp word [sound_index], 1038450
	jb loop1
exit:
	mov ax, 4c00h
	int 21h
END start