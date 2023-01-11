;Ilia Shtorm
; הקוד לקריאת קובץ תמונה ולהדפיס אותו נלקח מספר הדרכה אסמבלי באתר גבהים (עמודים 280-285)
IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
; Your variables here
; --------------------------
;GAME
	string db 20 dup('$')
	score db 'SCORE: $'
	points db 30h, '$'
	final_score db 'your final score is: $'
	spain db 'spain$'
	israel db 'israel$'
	brazil db 'brazil$'
	africa db 'south@africa$' ; a ערך האסקי של רווח קטן יותר מערך האסקי של
	enter_msg db 10, 13, 'Enter your answer: $'
	maxLen_msg db 10, 13, 'Reached Maximun Length$'
	wrong_guess_msg db 10, 13, 'Wrong Guess!$'
	right_guess_msg db 10, 13, 'Right Guess!$'
	levels db 0
;GRAPHICS
	spa_bmp db 'spain.bmp', 0
	isr_bmp db 'israel.bmp', 0
	bra_bmp db 'brazil.bmp', 0
	afr_bmp db 'africa.bmp', 0
	filehandle dw ?
	Header db 54 dup(0)
	Palette db 256*4 dup (0)
	ScrLine db 320 dup(0)
	ErrorMsg db 'ERROR', 10, 13, '$'
CODESEG
proc OpenFile
; Open file
	push bp
	mov bp, sp
	mov ah, 3Dh
	xor al, al
	mov dx, [bp+4]
	int 21h
	jc openerror
	mov [filehandle], ax
	pop bp
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
; Process BMP file
	push offset spa_bmp
game_start:
; Graphic mode
	mov ax, 13h
	int 10h 
	; this loop places the text in the middle of the screen
	mov cl, 18
loop1:
	mov dl, 10
	mov ah, 2
	int 21h
	loop loop1
	call OpenFile
	call ReadHeader
	call ReadPalette
	call CopyPal
	call CopyBitmap
start_pos:
	mov dx, offset score
	mov ah, 9
	int 21h
	mov dx, offset points
	mov ah, 9
	int 21h
	mov dx, offset enter_msg
	mov ah, 9
	int 21h
	mov si, offset string
input_str:
	mov ah, 1
	int 21h
	cmp al, 13
	je find_lvl
	mov [si], al
	inc si
	cmp si, 20
	je len_reached
	jmp input_str
len_reached:
	mov ah, 9
	mov dx, offset maxLen_msg
	int 21h
find_lvl: ; לבדוק באיזה שלב השחקן נמצא
	cmp [levels], 0
	je spain_flag
	cmp [levels], 1
	je israel_flag
	cmp [levels], 2
	je brazil_flag
	cmp [levels], 3
	je africa_flag
spain_flag:
	cmp si, 5 ; spain has 5 letters
	je cont
	jmp wrong_guess
israel_flag:
	cmp si, 6 ; israel has 6 letters
	je cont
	jmp wrong_guess
brazil_flag:
	cmp si, 6 ; brazil has 6 letters
	je cont
	jmp wrong_guess
africa_flag:
	cmp si, 12 ; south africa has 12 letters
	je cont
	jmp wrong_guess
cont:
	mov cx, si ; בודק רק את האותיות ולא גולש לסימנים מעבר
	xor si, si ; יתחיל מבדיקת האות הראשונה
	mov bl, 'a'
	mov dl, 20h ; כמו 30 הקסה אבל לאותיות
find_str_loop:
	cmp [si], bl
	jb make_lower ; בטבלת אסקי האותיות הגדולות באות לפני האותיות הקטנות
	inc si
	loop find_str_loop
	jmp check_level
make_lower:
	add [si], dl
	inc si
	loop find_str_loop
check_level:
	cmp [levels], 0
	je check_str_spa
	cmp [levels], 1
	je check_str_isr
	cmp [levels], 2
	je check_str_bra
	cmp [levels], 3
	je check_str_afr
check_str_spa:
	xor si, si
	mov bx, offset spain
	mov cx, 5 ; check answer length
	jmp check_str_loop
check_str_isr:
	xor si, si
	mov bx, offset israel
	mov cx, 6 ; check answer length
	jmp check_str_loop
check_str_bra:
	xor si, si
	mov bx, offset brazil
	mov cx, 6 ; check answer length
	jmp check_str_loop
check_str_afr:
	xor si, si
	mov bx, offset africa
	mov cx, 12 ; check answer length
check_str_loop:
	mov dl, [bx]
	cmp [si], dl ; כרגע מכיל את התשובה של השחקן
	jne wrong_guess
	inc bx
	inc si
	loop check_str_loop
	jmp right_guess ; הלולאה עברה על כל האותיות ואין יוצאי דופן לכן התשובה נכונה
wrong_guess:
	mov dx, offset wrong_guess_msg
	mov ah, 9
	int 21h
	jmp fin
right_guess:
	mov dx, offset right_guess_msg
	mov ah, 9
	int 21h
	inc [points]
fin:
; Wait for key press
	mov ah,1
	int 21h
	inc [levels]
	cmp [levels], 1
	je push_isr
	cmp [levels], 2
	je push_bra
	cmp [levels], 3
	je push_afr
	cmp [levels], 4
	je exit
push_isr:
	push offset isr_bmp
	jmp game_fin
push_bra:
	push offset bra_bmp
	jmp game_fin
push_afr:
	push offset afr_bmp
game_fin:
; Back to text mode
	mov ah, 0
	mov al, 2
	int 10h
	jmp game_start
exit:
	mov dx, offset final_score
	mov ah, 9
	int 21h
	mov dx, offset points
	mov ah, 9
	int 21h
	mov ah, 1
	int 21h
; Back to text mode
	mov ah, 0
	mov al, 2
	int 10h
	mov ax, 4c00h
	int 21h
END start