;Ilia Shtorm
IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
; Your variables here
; --------------------------
	buffer db 100 dup('$')
	var1 db 10, 13, 'good$'
CODESEG
start:
    mov ax, @data
    mov ds, ax
; --------------------------
; Your code here
; --------------------------
;	mov si, offset buffer
;	mov ah, 1
;	int 21h
;	mov [si], al
;	cmp al, 's'
;	
;	inc si
;	cmp dx, 's'
;	je spain
l1: ; קולט את האותיות אחת אחת
	mov ah, 1
	int 21h
	cmp al, 13 ; ברגע שלחצת אנטר תדפיס את המחרוזת שנכתבה
	je p1
	mov [si], al
	cmp al, 's'
	je spain
	inc si
	jmp l1
p1: ; ההדפסה
	mov dx, offset buffer
;	cmp [si], 's'
;	je spain
	mov ah, 9
	int 21h
	jmp exit
spain:
	mov dx, offset var1
	mov ah, 9
	int 21h
exit:
    mov ax, 4C00h
    int 21h
END start