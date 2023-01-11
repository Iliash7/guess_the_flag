;Ilia Shtorm
; הקוד לקריאת קובץ תמונה ולהדפיס אותו נלקח מספר הדרכה אסמבלי באתר גבהים (עמודים 280-285)
; PIA program (sound) by Omer Rahamim
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
	final_score db 10, 13, 'your final score is: $'
	spain db 'spain$'
	israel db 'israel$'
	brazil db 'brazil$'
	africa db 'south@africa$'	; a ערך האסקי של רווח קטן יותר מערך האסקי של
	india db 'india$'
	china db 'china$'
	italy db 'italy$'
	france db 'france$'
	mauritius db 'mauritius$'
	eritrea db 'eritrea$'
	lesotho db 'lesotho$'
	malta db 'malta$'
	enter_msg db 10, 13, 'Enter your answer: $'
	maxLen_msg db 10, 13, 'Reached Maximun Length$'
	wrong_guess_msg db 10, 13, 'Wrong Guess!$'
	right_guess_msg db 10, 13, 'Right Guess!$'
	levels db 0
	mute db 0
	hard db 0
;GRAPHICS
; max length for bmp file name - 8 characters
	start_bmp db 'start.bmp', 0
	spa_bmp db 'spain.bmp', 0
	isr_bmp db 'israel.bmp', 0
	bra_bmp db 'brazil.bmp', 0
	afr_bmp db 'africa.bmp', 0
	ind_bmp db 'india.bmp', 0
	chi_bmp db 'china.bmp', 0
	ita_bmp db 'italy.bmp', 0
	fra_bmp db 'france.bmp', 0
	mau_bmp db 'mauri.bmp', 0
	eri_bmp db 'erit.bmp', 0
	les_bmp db 'lesot.bmp', 0
	mal_bmp db 'malta.bmp', 0
	filehandle dw ?
	Header db 54 dup(0)
	Palette db 256*4 dup (0)
	ScrLine db 320 dup(0)
	ErrorMsg db 'ERROR', 10, 13, '$'
;SOUND
	c6 dw 1141
	g6 dw 1436
	b6 dw 1207
	cx1 dw ?
	cx2 dw ? 
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
proc jingle
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
	ret
endp jingle
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
	in al, 61h
	and al, 11111100b
	out 61h, al
	ret
endp everynote
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
start:
	mov ax, @data
	mov ds, ax
; --------------------------
; Your code here
; --------------------------
; Process BMP file
	push offset start_bmp
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
	cmp [levels], 0
	jne start_pos
wait_for_press:
	; Wait for key press
	mov ah,1
	int 21h
	cmp al, 'm'
	je mute_ON
	cmp al, 'M'
	je mute_ON
	cmp al, 'h'
	je hard_mode_ON
	cmp al, 'H'
	je hard_mode_ON
	jmp load_spa
mute_ON:
	mov dl, 8h
	mov ah, 2
	int 21h
	mov dl, 20h
	mov ah, 2
	int 21h
	mov dl, 8h
	mov ah, 2
	int 21h
	cmp [mute], 1
	je mute_OFF
	inc [mute]
	jmp wait_for_press
mute_OFF:
	dec [mute]
	jmp wait_for_press
hard_mode_ON:
	inc [hard]
	push offset mau_bmp
	jmp hm_ON1
load_spa:
	push offset spa_bmp
hm_ON1:
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
	cmp al, 8h
	jne cont2
backspace:
	mov dl, 20h
	mov ah, 2
	int 21h
	cmp si, 0 ; בשביל לא למחוק את הטקסט באדום
	je no_ans
	mov dl, 8h
	mov ah, 2
	int 21h
	dec si
	xor bl, bl
	mov [si], bl
no_ans:
	mov ah, 1
	int 21h
	cmp al, 8h
	je backspace
cont2:
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
	cmp [levels], 4
	je india_flag
	jmp cont_find
spain_flag:
	cmp [hard], 1
	je lvl1_h
	cmp si, 5 ; spain has 5 letters
	jne cont_wrong
	jmp cont
cont_wrong:
	jmp wrong_guess
lvl1_h:
	cmp si, 9 ; mauritius has 9 letters
	je cont
	jmp wrong_guess
israel_flag:
	cmp [hard], 1
	je lvl2_h
	cmp si, 6 ; israel has 6 letters
	je cont
	jmp wrong_guess
lvl2_h:
	cmp si, 7 ; eritrea has 7 letters
	je cont
	jmp wrong_guess
brazil_flag:
	cmp [hard], 1
	je lvl3_h
	cmp si, 6 ; brazil has 6 letters
	je cont
	jmp wrong_guess
lvl3_h:
	cmp si, 7 ; lesotho has 7 letters
	je cont
	jmp wrong_guess
africa_flag:
	cmp [hard], 1
	je lvl4_h
	cmp si, 12 ; south africa has 12 letters
	je cont
	jmp wrong_guess
lvl4_h:
	cmp si, 5 ; malta has 5 letters
	je cont
	jmp wrong_guess
india_flag:
	cmp si, 5 ; india has 5 letters
	je cont
	jmp wrong_guess
cont_find:
	cmp [levels], 5
	je china_flag
	cmp [levels], 6
	je italy_flag
	cmp [levels], 7
	je france_flag
china_flag:
	cmp si, 5 ; china has 5 letters
	je cont
	jmp wrong_guess
italy_flag:
	cmp si, 5 ; italy has 5 letters
	je cont
	jmp wrong_guess
france_flag:
	cmp si, 6 ; france has 6 letters
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
	jmp cont_check
check_str_spa:
	xor si, si
	cmp [hard], 1
	je lvl1_hA
	mov bx, offset spain
	mov cx, 5 ; check answer length
	jmp check_str_loop
lvl1_hA:
	mov bx, offset mauritius
	mov cx, 9 
	jmp check_str_loop
check_str_isr:
	xor si, si
	cmp [hard], 1
	je lvl2_hA
	mov bx, offset israel
	mov cx, 6 ; check answer length
	jmp check_str_loop
lvl2_hA:
	mov bx, offset eritrea
	mov cx, 7
	jmp check_str_loop
check_str_bra:
	xor si, si
	cmp [hard], 1
	je lvl3_hA
	mov bx, offset brazil
	mov cx, 6 ; check answer length
	jmp check_str_loop
lvl3_hA:
	mov bx, offset lesotho
	mov cx, 7
	jmp check_str_loop
check_str_afr:
	xor si, si
	cmp [hard], 1
	je lvl4_hA
	mov bx, offset africa
	mov cx, 12 ; check answer length
	jmp check_str_loop
lvl4_hA:
	mov bx, offset malta
	mov cx, 5
	jmp check_str_loop
cont_check:
	cmp [levels], 4
	je check_str_ind
	cmp [levels], 5
	je check_str_chi
	cmp [levels], 6
	je check_str_ita
	cmp [levels], 7
	je check_str_fra
check_str_ind:
	xor si, si
	mov bx, offset india
	mov cx, 5 ; check answer length
	jmp check_str_loop
check_str_chi:
	xor si, si
	mov bx, offset china
	mov cx, 5 ; check answer length
	jmp check_str_loop
check_str_ita:
	xor si, si
	mov bx, offset italy
	mov cx, 5 ; check answer length
	jmp check_str_loop
check_str_fra:
	xor si, si
	mov bx, offset france
	mov cx, 6 ; check answer length
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
	mov ah,1
	int 21h
	jmp fin
right_guess:
	mov dx, offset right_guess_msg
	mov ah, 9
	int 21h
	inc [points]
	cmp [mute], 1
	je fin
	call jingle 
fin:
; Wait for key press
	inc [levels]
	cmp [levels], 1
	je push_isr
	cmp [levels], 2
	je push_bra
	cmp [levels], 3
	je push_afr
	cmp [levels], 4
	je push_ind
	jmp cont_push
push_isr:
	cmp [hard], 1
	je lvl1_hB
	push offset isr_bmp
	jmp game_fin
lvl1_hB:
	push offset eri_bmp
	jmp game_fin
push_bra:
	cmp [hard], 1
	je lvl2_hB
	push offset bra_bmp
	jmp game_fin
lvl2_hB:
	push offset les_bmp
	jmp game_fin
push_afr:
	cmp [hard], 1
	je lvl3_hB
	push offset afr_bmp
	jmp game_fin
lvl3_hB:
	push offset mal_bmp
	jmp game_fin
push_ind:
	push offset ind_bmp
	jmp game_fin
cont_push:
	cmp [levels], 5
	je push_chi
	cmp [levels], 6
	je push_ita
	cmp [levels], 7
	je push_fra
	jmp exit
push_chi:
	push offset chi_bmp
	jmp game_fin
push_ita:
	push offset ita_bmp
	jmp game_fin
push_fra:
	push offset fra_bmp
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