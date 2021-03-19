.data
include Load.asm


.CODE
GetUserName proc
pushf

	mov dx, offset Load
	call DrawL
;Get Player name
mov ax,0600h
mov bh,07
mov cx,0
mov dx,184fh
int 10h

mov ah,0 ;Change into Text mode
mov al,01h
int 10h

mov ah,2 ;Move Cursor To half screen
mov dl,3
mov dh,10
mov bh,00
int 10h

mov ah,9 ;PRINT enter name 1 at x=1 y=10
mov bl, 0bh ; color, eg bright blue in this case
mov cx, 35; number of chars
int 10h
mov dx,offset EnterName1
int 21h
mov ah,2 ;Move Cursor To X=26 Y=10
mov dl,27
mov dh,10
mov bh,00
int 10h
  

mov  ah,0ah 
mov  dx,offset player1
int 21h
	
	mov si,0
		nameloop:
		call sendname
		call recievename
		
		inc si
		cmp si,15
		jne nameloop
		call ClearinputBuffer
popf
ret
endp GetUserName







MainMenuDraw proc 
	pushf
	;Draw the main Menu
	mov dx, offset MainMenu
	call DrawL
	popf
	pushf
;get the key to choose the mode 
;-----------------------
Check_Key: ;check for key pressed
mov ah,0
int 16h

Cmp Ah,3bh ;comparing with letters f1,f2,f3,f4
je ModeMenu ; go to choose mode 
cmp ah,3ch
je Tutorial ; change to tutorial
cmp ah,3dh
je ModeMenu ; change chat menu
cmp ah,3eh
je Tern; change to terimainate
; Tern: jmp Terminate
jmp Check_Key

Tern:
Mov bx,1
Mov Exit33,bx
jmp skip

;-------------------------------------------

;Mode Menu
ModeMenu:
;draw the mode Menu
mov dx, offset Mode
call DrawL
popf
pushf
;get the key of which mode
Check_Key_Mode: ;check for key pressed
mov ah,0
int 16h
;jz Check_Key
;----------------------------
Cmp Ah,3bh ;comparing with letters f1,f2,f3
je SaveGameMode1
cmp ah,3ch
je SaveGameMode2
cmp ah,3dh
je SaveGameMode3
cmp ah,3eh
je SaveGameMode4

jmp Check_Key ;IF non of the keys we initiated is pressed should check again
;-------------------------------------------
SaveGameMode1: ; saving GameMode 1 as Obstucal
mov bx,1
mov GameMode,bx
jmp SpeedMenu

SaveGameMode2:; saving GameMode 0 as Normal mode
mov bx,0
mov GameMode,bx
jmp SpeedMenu

SaveGameMode3:; saving GameMode 2 as PortalMode
mov bx,2
mov GameMode,bx
jmp SpeedMenu


SaveGameMode4:; saving GameMode 2 as PortalMode
mov bx,4
mov GameMode,bx
jmp SpeedMenu

;after saving we go to get the speed 


Tutorial:
;Game mode = 3
mov bx,3
mov GameMode,bx

;will go to the speed menu to choose the speed of the tutorial


SpeedMenu:; open speed menu

mov dx, offset Speed
call DrawL
popf
pushf

;Get the Speed value
Check_Key_Mode_Speed: ;check for key pressed
mov ah,0
int 16h
;jz Check_Key_Mode_Speed
;----------------------------
Cmp Ah,3bh ;comparing with letters f1,f2,f3
je SaveGameSpeed1
cmp ah,3ch
je SaveGameSpeed2
cmp ah,3dh
je SaveGameSpeed3
jmp Check_Key_Mode_Speed ;IF non of the keys we initiated is pressed should check again
;-------------------------------------------

SaveGameSpeed1: ; saving Game Speed  1 as low
mov bx,1
mov SpeedMode,bx
jmp Terminate

SaveGameSpeed2:; saving Game Speed  2 as medium
mov bx,2
mov SpeedMode,bx
jmp Terminate

SaveGameSpeed3:; saving Game Speed 3 as High 
mov bx,3
mov SpeedMode,bx
jmp Terminate

Terminate:

   
 
popf

;;;Sending GameMode

mov ax, GameMode
call SendingGame

mov ax, SpeedMode
call SendingGame

mov ax , 2
mov LastScored, ax







skip:

RET

endp MainMenuDraw 


sendname proc

		mov dx , 3FDH		; Line Status Register
AGAINn:  	In al , dx 			;Read Line Status
  		AND al , 00100000b
  		JZ AGAINn
		
		mov dx , 3F8H		; Transmit data register
  		mov  al,player1name[si]
  		out dx , al 
		
		ret
sendname endp
;=============================================================;
recievename proc

		mov dx , 3FDH		; Line Status Register
	CHK:	in al , dx 
  		AND al , 1
  		JZ CHK
		
		mov dx , 03F8H
  		in al , dx 
  		mov player2name[si] , al
		
		ret
recievename endp
;========================================