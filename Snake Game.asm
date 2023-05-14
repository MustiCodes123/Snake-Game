[org 0x0100]

jmp start
oldisr: dd 0
oldtimer: dd 0
fruitpos: dw 3150
str1: db 'Welcome to Snakes and Apples'
str2: db 'Game Over'
str3: db 'Your score:'
str4: db 'Guide the snake to apples'
str5: db 'If you hit wall or the snake you die'
score: dw 0
life: dw 1
length: dw 2
currentdirection: dw 1
difficulty: dw 0          ; enter difficulty from 0 to 5
tickcount: dw 0
snakecoordinates:  times 100 dw 0

intro:
	pusha
	call blackscr
	mov ax , 0xb800
	mov es , ax
	mov cx , 28
	mov di , 1970
	mov si , str1
	mov ah , 0x82
nextword:
	mov al , [si]
	mov word[es:di] , ax
	add si , 1
	add di , 2
	loop nextword
	popa
	ret

blackscr:
	pusha
	mov ax , 0xb800
	mov es , ax
	mov di , 0

nextloc:
	mov word[es:di] , 0x0720
	add di , 2
	cmp di , 4000
	jne nextloc

	popa
	ret

introDelay:
	pusha
	mov ax , 40
il:
	mov dx , 0xFFFF
	dl1: sub dx , 1
	cmp dx , 0
	jne dl1
	
	sub ax , 1
	cmp ax , 0
	jne il
	popa
	ret

gameover:
	push bp 
	mov bp, sp 
	push es 
	push ax 
	push bx 
	push cx 
	push dx 
	push di 
	mov ax , 0xb800
	mov es , ax
	mov cx , 9
	mov di , 1670
	mov si , str2
	mov ah , 0x04
nextword1:
	mov al , [si]
	mov word[es:di] , ax
	add si , 1
	add di , 2
	loop nextword1

	mov cx , 11
	mov di , 1986
	mov si , str3
	mov ah , 0x04
nextword2:
	mov al , [si]
	mov word[es:di] , ax
	add si , 1
	add di , 2
	loop nextword2

	mov ax, [bp+4] 
	mov bx, 10 
	mov cx, 0 
	nextdigit: mov dx, 0 
	 div bx ; divide by 10 
	 add dl, 0x30 
	 push dx 
	 inc cx 
	 cmp ax, 0 
	 jnz nextdigit 
	 add di, 2
	nextpos: pop dx 
	 mov dh, 0x07
	 mov [es:di], dx 
	 add di, 2 
	 loop nextpos 
	 pop di 
	 pop dx 
	 pop cx 
	 pop bx 
	 pop ax 
	 pop es 
	 pop bp 
	 ret 2 

generaterandom:
	pusha
	
	randomloop:
	cmp word[fruitpos] , 3800
	jg updatedi
	add word[fruitpos] , 200
	mov di, word[fruitpos]
	cmp word[es:di] , 0x4030 ; wall
	je randomloop
	cmp word[es:di] , 0x212A ; snake
	je randomloop
	jmp exitramdom
	updatedi:
	mov word[fruitpos] , 160
	jmp randomloop

exitramdom:
	popa
	ret
	
printsnake:
	pusha
	mov ax,0xb800
	mov es,ax

;mov ah , 0x21 ; head attribute
;mov al , 0x2A ; head ascii

	mov di,1980
	mov word cx,[cs:length]
	mov bx,0
	mov ah,0x21 ; head
	mov si,0
	
	printsnake1:
	mov al,0x2A ;snake ascii
	mov word[es:di],ax
	mov word[cs:snakecoordinates+si],di
	inc bx
	add di,2
	add si,2
	loop printsnake1
	popa
	ret

printupdatedDOWNsnake:
	pusha
	mov ax,0xb800
	mov es,ax
	
	mov word cx,[cs:length]
	mov bx,0
	mov ah,0x21 ; head
	mov si,0
	mov bx , word[cs:length]
	shl bx , 1
	sub bx , 2
	add di , 160
	mov ax , di
	mov word[cs:snakecoordinates+bx] , ax
	mov di , word[cs:snakecoordinates+si]
	mov ax , 0x212A ; snake 
	mov word[es:di] ,ax 

	mov ah , 0x21 ;snake attribute
	mov al,0x2A ; snake ascii
	printsnake2down:
	mov di , word[cs:snakecoordinates+si]
	mov word[es:di],ax
	inc bx
	add si,2

	loop printsnake2down
	add si , 2
	popa
	ret

printupdatedUPsnake:
	pusha
	mov ax,0xb800
	mov es,ax
	
	mov word cx,[cs:length]
	mov bx,0
	mov ah,0x21 ; head
	mov si,0
	mov bx , word[cs:length]
	shl bx , 1
	sub bx , 2
	sub di , 160
	mov ax , di
	mov word[cs:snakecoordinates+bx] , ax
	mov di , word[cs:snakecoordinates+si]
	mov ax , 0x212A ; snake
	mov word[es:di] ,ax 

	mov ah , 0x21
	mov al,0x2A
	printsnake2up:
	mov di , word[cs:snakecoordinates+si]
	mov word[es:di],ax
	inc bx
	add si,2
	loop printsnake2up
	add si , 2

	popa
	ret

printupdatedLEFTsnake:
	pusha
	mov ax,0xb800
	mov es,ax
	
	mov word cx,[cs:length]
	mov bx,0
	mov ah,0x21 ; head
	mov si,0

	mov bx , word[cs:length]
	shl bx , 1
	sub bx , 2
	sub di , 2
	mov ax , di
	mov word[cs:snakecoordinates+bx] , ax
	mov di , word[cs:snakecoordinates+si]
	mov ax , 0x212A
	mov word[es:di] ,ax 
	
	mov ah , 0x21  ; snake attribute
	mov al,0x2A ; snake ascii
	printsnake2left:
	
	mov di , word[cs:snakecoordinates+si]
	mov word[es:di],ax
	inc bx
	add si,2
	loop printsnake2left

	add si , 2
	popa
	ret

printupdatedRIGHTsnake:
	pusha
	mov ax,0xb800
	mov es,ax
	
	mov word cx,[cs:length]
	mov bx,0
	mov ah,0x21 ; head
	mov si,0

	mov bx , word[cs:length]
	shl bx , 1
	sub bx , 2
	add di , 2
	mov ax , di
	mov word[cs:snakecoordinates+bx] , ax
	mov di , word[cs:snakecoordinates+si]
	mov ax , 0x212A
	mov word[es:di] ,ax 
	
	mov ah , 0x21
	mov al,0x2A
	printsnake2right:
	mov di , word[cs:snakecoordinates+si]
	mov word[es:di],ax
	inc bx
	add si,2

	loop printsnake2right
	add si , 2
	popa
	ret

Delay:
	mov dx , 0xFFFF
	D1: dec dx
	jnz D1
	mov dx , 0xFFFF
	D2: dec dx
	jnz D2
	ret

clrscr:
	pusha
	mov ax , 0xb800
	mov es , ax
	mov di , 0
	mov ah , 0x20 ; green background
	mov al , 0x20 ;green background
nextchar:
	mov word[es:di] , ax
	add di , 2
	cmp di , 4000
	jne nextchar
	popa
	ret

border:
	pusha
	mov ax , 0xb800
	mov es , ax
	mov ah , 0x40 ;wall
	mov al , 0x30 ;wall
	
	mov cx , 80
	mov di , 0
border1:
	mov word[es:di] , ax
	add di , 2
	loop border1
	
	mov di , 0
	mov cx , 25

border2:

	mov word[es:di] , ax
	add di , 160
	loop border2

mov di , 158
mov cx , 25
border3:
	mov word[es:di] , ax
	add di , 160
	loop border3
mov di , 3840
mov cx , 80

border4:
	mov word[es:di] , ax
	add di , 2
	loop border4
	popa
ret

MoveDown:
	pusha
	mov ax , 0xb800
	mov es , ax
	mov word[currentdirection] , 4
	mov word si , [cs:length]
	add si , si ; twice
	sub si , 2 ;in db

dowmwallcheck:
	mov ah , 0x40 ; wall
	mov al , 0x30 ; wall
	mov di , [cs:snakecoordinates+si] ; head coordinates
	cmp ax , word[es:di+160]
	jne downsnakecheck
	jmp lostD1

downsnakecheck:
	mov ah , 0x21 ; head attribute
	mov al , 0x2A ; head ascii
	mov di , [cs:snakecoordinates + si] ; head coordinates
	cmp ax , [es:di+160]
	jne downfruitcheck
	jmp lostD1

downfruitcheck:
	mov ax , 0x202B ; fruit
	mov di , [cs:snakecoordinates + si] ; head coordinates
	cmp ax , word[es:di+160]
	
	jne keepmovingdown

	call generaterandom
	call printfruit
	
	add word[cs:length] , 1
	inc word[cs:score]
	call printupdatedDOWNsnake
	jmp exitD1

keepmovingdown:
	mov word cx,[cs:length]
	dec cx
	mov word si,[cs:length]
	shl si,1
	sub si,2
	mov ah,0x21
	mov di,[cs:snakecoordinates+si] ; head coordinates
	mov al,0x2A 
	mov word[es:di+160],ax
	add word[cs:snakecoordinates+si],160
movingdown:
	mov bx,[cs:snakecoordinates+si-2]
	mov ax,[es:bx]
	mov word[es:di],ax
	mov [cs:snakecoordinates+si-2],di
	mov di,bx
	sub si,2
	loop movingdown
	mov dx,0x2020 ; background

	mov word[es:di],dx
exitD1:
	popa
	ret
lostD1:
mov word[life] , 0
	popa
	ret


resetscreen:
	pusha
	call clrscr
	call border
	popa
	ret


MoveLeft:
	pusha
	mov ax , 0xb800
	mov es , ax

	mov word[currentdirection] , 2
	mov word si , [cs:length]
	add si , si ; twice
	sub si , 2 ;in db

leftwallcheck:
	mov ah , 0x40 ; wall
	mov al , 0x30 ; wall
	mov di , [cs:snakecoordinates+si] ; head coordinates
	cmp ax , word[es:di-2]
	jne leftsnakecheck
	jmp lostL1

leftsnakecheck:
	mov ah , 0x21 ; head attribute
	mov al , 0x2A ; head ascii
	mov di , [cs:snakecoordinates + si] ; head coordinates
	cmp ax , [es:di-2]
	jne leftfruitcheck
	jmp lostL1

leftfruitcheck:
	mov ax , 0x202B ; fruit
	cmp ax , word[es:di-2]
	jne keepmovingleft
	
	call generaterandom
	call printfruit
	
	add word[cs:length] , 1
	inc word[cs:score]
	
	call printupdatedLEFTsnake
	jmp exitL1


keepmovingleft:
	mov word cx,[cs:length]
	dec cx
	mov word si,[cs:length]
	shl si,1
	sub si,2
	mov ah,0x21
	mov di,[cs:snakecoordinates+si] 
	mov al,0x2A; Get value of HEAD
	mov word[es:di-2],ax
	sub word[cs:snakecoordinates+si],2
movingleft:
	mov bx,[cs:snakecoordinates+si-2]
	mov ax,[es:bx]
	mov word[es:di],ax
	mov [cs:snakecoordinates+si-2],di
	mov di,bx
	sub si,2
	loop movingleft
	mov dx,0x2020
	mov word[es:di],dx
	
exitL1:
	popa
	ret

lostL1:
	mov word[life] , 0
	popa
	ret


MoveUp:
	pusha
	mov ax , 0xb800
	mov es , ax
	mov word[currentdirection] , 3
	mov word si , [cs:length]
	add si , si ; twice
	sub si , 2 ; in db

upwallcheck:
	mov ah , 0x40 ; wall
	mov al , 0x30 ; wall
	mov di , [cs:snakecoordinates+si] ; head coordinates
	cmp ax , word[es:di-160]
	jne upsnakecheck
	
	jmp lostU1


upsnakecheck:
	mov ah , 0x21 ; head attribute
	mov al , 0x2A ; head ascii
	mov di , [cs:snakecoordinates + si] ; head coordinates
	cmp ax , [es:di-160]
	jne upfruitcheck
	jmp lostU1


upfruitcheck:
	mov ax , 0x202B ; fruit
	mov di , [cs:snakecoordinates + si] ; head coordinates
	
	cmp ax , word[es:di-160]
	jne keepmovingup
	call generaterandom
	call printfruit

	add word[cs:length] , 1
	inc word[cs:score]
	call printupdatedUPsnake
	jmp exitU1

	
keepmovingup:
	mov word cx,[cs:length]
	dec cx
	mov word si,[cs:length]
	shl si,1
	sub si,2
	mov ah,0x21
	mov di,[cs:snakecoordinates+si] ;head cordinates
	mov al,0x2A
	mov word[es:di-160],ax
	sub word[cs:snakecoordinates+si],160
movingup:
	mov bx,[cs:snakecoordinates+si-2]
	mov ax,[es:bx]
	mov word[es:di],ax
	mov [cs:snakecoordinates+si-2],di
	mov di,bx
	sub si,2
loop movingup
	mov dx,0x2020
	mov word[es:di],dx

exitU1:
	popa
	ret
lostU1:
	mov word[life] , 0
	popa
	ret

MoveRight:
	pusha
	mov ax , 0xb800
	mov es , ax
	
	mov word[currentdirection] , 1

	mov word si,[cs:length]
	add si , si ;twice
	sub si , 2 ; sub 2 to get length in db


rightwallcheck:
	mov ah , 0x40 ; wall
	mov al , 0x30 ; wall
	mov di , [cs:snakecoordinates+si] ; head coordinates
	cmp ax , word[es:di+2]
	jne rightsnakecheck
	jmp lostR1


rightsnakecheck:
	mov ah , 0x21 ; head attribute
	mov al , 0x2A ; head ascii
	mov di , [cs:snakecoordinates + si] ; head coordinates
	cmp ax , [es:di+2]
	jne rightfruitcheck
	jmp lostR1

rightfruitcheck:
	mov ax , 0x202B ; fruit
	mov di , [cs:snakecoordinates + si] ; head coordinates
	cmp ax , word[es:di+2]
	
	jne keepmovingright
	
	call generaterandom
	call printfruit
	
	add word[cs:length] , 1
	inc word[cs:score]
	call printupdatedRIGHTsnake
	jmp exitR1

keepmovingright:

	mov word cx,[cs:length]
	dec cx
	mov word si,[cs:length]
	shl si,1
	sub si,2
	mov ah,0x21 ; head

	mov di,[cs:snakecoordinates+si] ;position of head from top
	mov al,0x2A ; value of head
	mov word[es:di+2],ax ; print at di+2 i.e one step ahead
	add word[cs:snakecoordinates+si],2 ; update video address of head by adding 2
movingright:
	mov bx,[cs:snakecoordinates+si-2] ; the next asterik from head and so on
	;its video mem address stored in bx
	mov ax,[es:bx] 
	mov word[es:di],ax ; print that asterik
	mov [cs:snakecoordinates+si-2],di
	mov di,bx
	sub si,2
	loop movingright
	mov dx,0x2020; background
	mov word[es:di],dx

exitR1:
	popa
	ret
lostR1:
	mov word[life] , 0
	popa
	ret

printfruit:
	pusha
	mov ax,0xb800
	mov es,ax
	mov di,[cs:fruitpos]
	mov ah,0x20 ;fruit
	mov al, 0x2B ;fruit
	mov word[es:di],ax
	popa
	ret

timer:
	push ax 
	push es 

	mov ax , word[difficulty]
	mov cx , 5
	sub cx , ax	

	incloop:
	inc word[tickcount]	
	cmp word[tickcount] , cx
	jb skiptmr
	
	
	checkright:
	cmp word[currentdirection],1 ;if in right direction
	jne checkup
	call MoveRight
	mov word[tickcount],0
	checkup:
	cmp word[currentdirection],3 ; if in up direction
	jne checkleft 
	call MoveUp
	mov word[tickcount],0
	checkleft:
	cmp word[currentdirection],2 ; if in left direction
	jne checkdown
	call MoveLeft
	mov word[tickcount],0
	checkdown:
	cmp word[currentdirection],4 ; if in down direction
	jne ExitTimer
	call MoveDown
	mov word[tickcount],0

	ExitTimer:
	skiptmr:
	mov al, 0x20
	out 0x20, al 
	pop es 
	pop ax 
	iret 

kbisr:
	push ax 
	push es 
	mov ax, 0xb800 
	mov es, ax 
	in al, 0x60 
	cmp al, 0x48 ; is the key up 
	jne nextcmp

	cmp word[currentdirection] , 4 ; i.e if it is going down
	je nextcmp

	call MoveUp
	jmp nomatch
	nextcmp: cmp al, 0x50  ; is the key down
	jne nextcmp1

	cmp word[currentdirection] , 3 ; i.e if it is going up
	je nextcmp1

	call MoveDown 
	nextcmp1: cmp al, 0x4b ; is the key left
	jne nextcmp2

	cmp word[currentdirection] , 1 ; i.e if it is going right
	je nextcmp2

	call MoveLeft 
	
	nextcmp2: cmp al, 0x4d ; is the right
	jne nomatch 
	
	cmp word[currentdirection] , 2
	je nomatch
	
	call MoveRight

	nomatch:
	 mov al, 0x20 
	out 0x20, al
	pop es 
	pop ax 
	;iret
	jmp far [cs:oldisr]

instscreen:
	pusha
	call blackscr
	mov ax , 0xb800
	mov es , ax
	mov cx , 25
	mov di , 1970
	mov si , str4
	mov ah , 0x07
nextword3:
	mov al , [si]
	mov word[es:di] , ax
	add si , 1
	add di , 2
	loop nextword3

	mov cx , 36
	mov di , 2122
	mov si , str5

nextword4:
	mov al , [si]
	mov word[es:di] , ax
	add si , 1
	add di , 2
	loop nextword4


	popa
	ret

start:
	call intro
	call introDelay
	call instscreen
	call introDelay
	call clrscr
	call border
	call printsnake
	call generaterandom
	call printfruit
	
	xor ax, ax 
	mov es, ax ; point es to IVT base
	mov ax , [es:9*4]
	mov [oldisr] , ax
	mov ax , [es:9*4+2]
	mov [oldisr+2] , ax

	xor ax, ax 
	mov es, ax ; point es to IVT base
	mov ax , [es:8*4]
	mov [oldtimer] , ax
	mov ax , [es:8*4+2]
	mov [oldtimer+2] , ax	


	
	cli 
	mov word [es:9*4], kbisr
	mov [es:9*4+2], cs 
	sti

	l1:
	xor ax, ax
	mov es, ax ; point es to IVT base
	cli 
	mov word [es:8*4], timer
	mov [es:8*4+2], cs 
	sti

	cmp word[cs:life] , 0
	je exitgame


	;mov ah, 0 
	;int 0x16 
	;cmp al, 27 
	;je exitgame

	jmp l1
	
	exitgame:
	
	xor ax, ax
	mov es, ax 
	mov ax , [oldisr]
	mov bx , [oldisr + 2]
	cli
	mov [es: 9 * 4] , ax
	mov [es: 9 * 4 + 2] , bx
	sti

	mov ax , [oldtimer]
	mov bx , [oldtimer + 2]
	cli
	mov [es: 8 * 4] , ax
	mov [es: 8 * 4 + 2] , bx
	sti

	call blackscr
	mov ax, word[cs:score]
	push ax 
	call gameover
	
	mov ax, 0x4c00
	int 0x21