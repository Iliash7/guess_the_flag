;Ilia Shtorm
IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
; Your variables here
; --------------------------
;GAME
	string db 10 dup('$')
	spain db 'spain$'
	enter_msg db 10, 13, 'Enter String: $'
	maxLen_msg db 10, 13, 'Reached Maximun Length$'
	wrong_guess_msg db 10, 13, 'Wrong Guess!$'
	right_guess_msg db 10, 13, 'Right Guess!$'
;GRAPHICS
	filename db 'spain2.bmp',0
	filehandle dw ?
	msg db 'Hello World!'
	Header db 54 dup(0)
	Palette db 256*4 dup (0)
	ScrLine db 320 dup(0)
	ErrorMsg db 'ERROR', 10, 13, '$'
CODESEG
proc OpenFile
; Open file
	mov ah, 3Dh
	xor al, al
	mov dx, offset filename
	int 21h
	jc openerror
	mov [filehandle], ax
	ret
openerror :
	mov dx, offset ErrorMsg
	mov ah, 9h
	int 21h
	ret
endp OpenFile
proc ReadHeader
; Read BMP file header, 54 bytes
	mov ah,3fh
	mov bx, [filehandle]
	mov cx,54
	mov dx,offset Header
	int 21h
	ret
endp ReadHeader 
proc ReadPalette
; Read BMP file color palette, 256 colors * 4 bytes (400h)
	mov ah,3fh
	mov cx,400h
	mov dx,offset Palette
	int 21h
	ret
endp ReadPalette
proc CopyPal
; Copy the colors palette to the video memory
; The number of the first color should be sent to port 3C8h
; The palette is sent to port 3C9h
	mov si,offset Palette
	mov cx,256
	mov dx,3C8h
	mov al,0
; Copy starting color to port 3C8h
	out dx,al
; Copy palette itself to port 3C9h
	inc dx
PalLoop:
; Note: Colors in a BMP file are saved as BGR values rather than RGB .
	mov al,[si+2] ; Get red value .
	shr al,2 ; Max. is 255, but video palette maximal
; value is 63. Therefore dividing by 4.
	out dx,al ; Send it .
	mov al,[si+1] ; Get green value .
	shr al,2
	out dx,al ; Send it .
	mov al,[si] ; Get blue value .
	shr al,2
	out dx,al ; Send it .
	add si,4 ; Point to next color .
; (There is a null chr. after every color.)
	loop PalLoop
	ret
endp CopyPal
proc CopyBitmap
; BMP graphics are saved upside-down .
; Read the graphic line by line (200 lines in VGA format),
; displaying the lines from bottom to top.
	mov ax, 0A000h
	mov es, ax
	mov cx,200
PrintBMPLoop :
	push cx
; di = cx*320, point to the correct screen line
	mov di,cx
	shl cx,6
	shl di,8
	add di,cx
; Read one line
	mov ah,3fh
	mov cx,320
	mov dx,offset ScrLine
	int 21h
; Copy one line into video memory
	cld ; Clear direction flag, for movsb
	mov cx,320
	mov si,offset ScrLine
	rep movsb ; Copy line to the screen
;rep movsb is same as the following code :
;mov es:di, ds:si
;inc si
;inc di
;dec cx
;loop until cx=0
	pop cx
	loop PrintBMPLoop
	ret
endp CopyBitmap
start:
	mov ax, @data
	mov ds, ax
; --------------------------
; Your code here
; --------------------------
; Graphic mode
	mov ax, 13h
	int 10h 
; Process BMP file
	call OpenFile
	call ReadHeader
	call ReadPalette
	call CopyPal
	call CopyBitmap
; these two loops place the text in the middle of the screen
	mov cl, 18
loop1:
	mov dl, 10
	mov ah, 2
	int 21h
	loop loop1
	mov cl, 10
loop2:
	mov dl, ' '
	mov ah, 2
	int 21h
	loop loop2
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
	jmp fin
right_guess:
	mov dx, offset right_guess_msg
	mov ah, 9
	int 21h
fin:
; Wait for key press
	mov ah,1
	int 21h
; Back to text mode
	mov ah, 0
	mov al, 2
	int 10h
exit:
	mov ax, 4c00h
	int 21h
END start