;Ilia Shtorm
IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
; Your variables here
; --------------------------
	string db 10 dup('$')
	spain db 'spain$'
	enter_msg db 10, 13, 'Enter String: $'
	maxLen_msg db 10, 13, 'Reached Maximun Length$'
	wrong_guess_msg db 10, 13, 'Wrong Guess!$'
	right_guess_msg db 10, 13, 'Right Guess!$'
CODESEG
start:
	mov ax, @data
	mov ds, ax
; --------------------------
; Your code here
; --------------------------
start_pos:
	mov dx, offset enter_msg
	mov ah, 9
	int 21h
	mov si, offset string
input_str:
	mov ah, 1
	int 21h
	cmp al, 13
	je find_str
	mov [si], al
	inc si
	cmp si, 10
	je len_reached
	jmp input_str
len_reached:
	mov ah, 9
	mov dx, offset maxLen_msg
	int 21h
find_str: ; ?האם המחרוזת שקלטנו שווה למחרוזת הרצויה
	cmp si, 5 ; spain has 5 letters
	je cont
	jmp wrong_guess
cont:
	mov cx, si
	xor si, si
	mov bl, 'a'
	mov dl, 20h
find_str_loop:
	cmp [si], bl
	jb make_lower
	inc si
	loop find_str_loop
	jmp check_str
make_lower:
	add [si], dl
	inc si
	loop find_str_loop
check_str:
	xor si, si
	mov bx, offset spain
	mov cx, 5
check_str_loop:
	mov dl, [bx]
	cmp [si], dl
	jne wrong_guess
	inc bx
	inc si
	loop check_str_loop
	jmp right_guess
wrong_guess:
	mov dx, offset wrong_guess_msg
	mov ah, 9
	int 21h
	jmp exit
right_guess:
	mov dx, offset right_guess_msg
	mov ah, 9
	int 21h
exit:
	mov ax, 4c00h
	int 21h
END start