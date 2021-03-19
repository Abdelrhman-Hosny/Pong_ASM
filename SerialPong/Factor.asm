.model small
.stack 64
.data      

;image data for paddle
imgW equ 4
imgH equ 42
img DB 0, 31, 31, 0, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 150, 150, 53, 53, 54, 150, 53, 53, 54, 150, 53, 53, 54, 150, 53, 53, 54, 150, 53, 53, 54, 150, 53, 53
 DB 54, 150, 53, 53, 54, 150, 53, 53, 54, 150,53, 53, 54, 150,53, 53, 54, 150, 53, 53, 54, 150, 53, 53, 54, 150, 53, 53, 54, 150, 53, 53, 54, 150, 53, 53, 54, 150, 53, 53, 54, 150, 53, 53, 54, 150, 53, 53
 DB 54, 150, 53, 53, 54, 150, 53, 53, 54, 150, 53, 53, 54, 150, 53, 53, 54, 150, 53, 53, 54, 150, 53, 53, 54, 150, 53, 53, 54, 150, 53, 53, 54, 150, 53, 53, 54, 150, 53, 53
 DB 54, 150, 53, 53, 54, 150, 53, 53, 54, 150, 53, 53, 54, 150, 53, 53, 54, 150, 53, 53, 150, 150, 53, 53, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 0, 31, 31, 0


;ball image data
ball_imgW equ 7
ball_imgH equ 7
ball_img DB 0, 0, 53, 53, 53, 0, 0, 0, 53, 53, 53, 53, 53, 0, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 31, 31, 53, 53, 53, 53, 0, 53, 31, 53, 53 
         DB 53, 0, 0, 0, 53, 53, 53, 0, 0


;; Drawing Paddle Variables 

Color equ 01h 
ColorLeft equ 04h                     
PaddleSize equ 42
PaddleDiv3 equ 13
PaddleX DW 315
PaddleY DW 60
PaddleXLeft DW 2
PaddleYLeft DW 60
PaddleXLeft_initially DW 2
PaddleYLeft_initially DW 60
PaddleX_initially DW 315
PaddleY_initially DW 60
;-----------------------------------
;;  Collision Variables
time db 1
Ball_X dw 6
Ball_X2 dw ?
Ball_Y dw 80
Ball_Y2 dw ?
Ball_Size dw 7
BallVelocity_X dw ?
BallVelocity_Y dw ?

; V45Y dw ?
; V30Y dw ?
; V0Y dw 0 ; might be removed

V45X dw ?
V30X dw ?

minX dw 0
minY dw 2
MaxX  dw 138h
MaxY dw 150d
Ball_Start_X_Ours DW 6
Ball_Start_X_Theirs DW 306
Ball_Start_Y dw 75
LastScored dw 1

;game needs 
endround db 0
whocollides DW 0
ESCMSSG db 'Press Esc to Pause $'

;Tutorial Mode Variables
;--------------------------------
keyboardinput dw 0
noofcomputermovements dw 0

;players info

EnterName2 db 'Enter Second Player Name                 $'
EnterName1 db 'Enter First Player Name                  $'
player1 label byte 
maxsize1 db 15
actualsizep1 db ?
player1name db 15 dup('$')
player1score db '0$'
player2 label byte 
maxsize2 db 15
actualsizep2 db ?
player2name db 15 dup('$')

player2score db '0$'
comma db ':$'


; game chatting needs
;--------------------------------
ourcursor dw ? 
othercursor dw ?
chatbyte db ? 



;Middle Paddle Variables
;--------------------------------
ColorMiddle equ 08h                   
PaddleSize equ 42
PaddleDiv3 equ 13
PaddleXMiddle DW 150
PaddleYMiddle DW 60
PaddleXMiddle_initially DW 156
PaddleYMiddle_initially DW 60
upordown dw 0 
;----------------------

;Portal Variables 
;-------------------
Colorportalright equ 01h 
Colorportalleft equ 04h                     
portalsize equ 25
portalrightX DW 200
portalrightY DW 100
PortalLeftX DW 120
PortalLeftY DW 20

;Selections From Menu
;--------------------
; Mode Selection 
;----------------

FirstSelector db 0 ; 0 Start Game ( Go get mode )
                   ; 1 Tutorial
                   ; 2 Chat Module

GameMode dw ? ; 0 Normal
          ; 1 Middle Paddle
          ; 2 Portals ( Hopefully )
          ; 3 Tutorial Mode
		  ; 4 chat mode

SpeedMode dw ?

;Drawing Info
Load DB 'Load.bin', 0
MainMenu DB 'MainM.bin',0
Speed DB 'Speed.bin',0
Mode DB 'Mode.bin',0

;Pause message

PauseMess1 DB "PAUSE$"
PauseMess2 DB "Press ESC To Continue$"
PauseMess3 DB "Press F4 to Return to the Main Menu$"


Sendinv DB "You Got an invitation$"
waitMenu DB "Waiting For Second User$"


SentMovementKey DB ?
Exit33 Dw 0

ResetApplication DW 0

;We also want to vary in paddle size 

include Coll.asm
include Init.asm
include Draw.asm
include Mid.asm
include Portal.asm
include Tut.asm
include Menu.asm
include Invites.asm
include cha.asm

;GLOBALS
;-------------------------------------------------------------
GameReadyOur Db 0
GameReadyTheir Db 0
GeneralPause db ? 
Recived db 0


;Invites Variables to check notification
recievedchatinv DB 0	
recievedgameinv Db 0	
readytochat DB 0	
readytogame DB 0

GameInviteAccepthey DB 0
GameInviteAcceptOur DB 0
OurSendGameInvite DB 0
TheySendGameInvite DB 0


.code
;;;; here we made draw as a function

MAIN  PROC FAR


;going to the graphics mode
mov AX, @data
mov DS, AX

call serialinitialize

cmp ax,portalrightX  ;;; just to let zf=0 testing

call GetUserName

GetInv:

call invitationMessages
call clearinputbuffer
;wait for Us to get Ready
waitForReadyButtonInvite:
	cmp TheySendGameInvite,3bh
	jz alreadyrecievedInvite
    call RecieveGame  ;;these will be exectued egbary fel awal
    mov TheySendGameInvite,al 

	;compare button press with F1+
	mov ah,1
	int 16h
	jz waitForReadyButtonInvite
	call clearinputbuffer
    cmp ah,3bh
	jz SendInviteAndGoToMain
	
    ;if it is equal to F1 send it
;else Recieve a button from other
jmp waitForReadyButtonInvite

SendInviteAndGoToMain:
mov al,ah
call SendingGame
jmp ExitToMainMenu

alreadyrecievedInvite:
call notificationMess
RecievingModes:
call RecieveGame
jz RecievingModes

mov ah,0
mov GameMode,ax


RecievingSpeedModes:
call RecieveGame
jz RecievingSpeedModes

mov ah,0
mov SpeedMode,ax

jmp GameLoop

;  mov ah,0
;  int 16h


;call WaitingMess

ExitToMainMenu:

;Clear the buffer
; call clearinputbuffer

;to clear the buffer
;cmp ah,al
call MainMenuDraw
mov ResetApplication,0






; cmp Exit33,01h
; je Finish
; mov ax,1
; mov GameMode,ax
; mov SpeedMode, ax


GameLoop:

mov ax,13h
int 10h

mainmain:
; call drawChatline

	cmp GameMode , 4
	jz ChatModule
    call SetInitialVelocities ; New Line Added
                          ; Sets the Variables V45Y , V30Y  (Velocity of y at angle 45)

    call Serve

    ;wait for Us to get Ready
    waitForReadyButton:
	cmp GameReadyTheir,3bh
	jz alreadyrecieved
    call RecieveGame  ;;these will be exectued egbary fel awal
    mov GameReadyTheir,al 

	alreadyrecieved:
	;;; waiting for my key
    mov ah,1
    int 16h
    
	call clearinputbuffer ;; to clear buffer before moving 
	
	;compare button press with F1+
    cmp ah,3bh
    ;if it is equal to F1 send it
    jz OurPlayerIsReady
    ;else Recieve a button from other
    jmp waitForReadyButton

    OurPlayerIsReady:
    ;key pressed is f1 put 1 in al and GameReadyOur and Send it
    mov al , 3bh
    mov GameReadyOur,al
    ;Send 1 to the Other player to tell him that we are ready
    call SendingGame
    ;Now we need to wait for Other Player to get Ready
    
	waitingForTheirToStart:

	cmp GameReadyTheir,3bh
	jz StartGameNow
    ;Recieve the KeyPressed in al
    call RecieveGame
    mov GameReadyTheir,al 
    ;if it is equal to one start else wait for recive
    cmp GameReadyTheir,3bh
    jz StartGameNow
    jmp waitingForTheirToStart

;Mov Curosr to the Right Position


     StartGameNow:
    ; mov ah,9
    ; mov dx,offset player1name
    ; int 21h
    ; mov endround,0
    cmp GameMode , 4
	jz ChatModule
    cmp GameMode,3
    jne othermodes
    call MAINDRAW_TUTORIAL_MODE
    cmp ResetApplication,1
    jz exittomaintemporary
    jmp othermodes
	exittomaintemporary:jmp GetInv

    othermodes:
    Call Maindraw
    cmp ResetApplication,1
    jz exittomaintemporary  ;; here will change it after cleaning the code
	 						;; it was jz ExitToMainMenu


jmp GetInv

ChatModule:


call ChatModuleStart

jmp GetInv


Finish:

call FinishMess

;HLT
MAIN    ENDP

ChatModuleStart proc 
call chatoutline

Returnnn:
call sending
call receiving

cmp GameMode,4
je Returnnn


ret

ChatModuleStart ENDP


Maindraw PROC

    
    ;check if a key is Pressed
    CHECK:

    MOV CX,Ball_X ;set the initial column (X)
    MOV DX,Ball_Y  

    ;SAVING PREVIOUS LOCATION
    ;------------------------------------------------------------------------------------
    ;All Draw Ball Horizontal must be preceeded by InPaddleRange and check end round
            cmp GameMode , 1  ; If mode isnt the number 1 ( Middle Paddle ) , we skip line
            jnz SkipLine1
            call InPaddleRangeforMiddle

SkipLine1:  cmp GameMode , 2    ;;portal mode
            jnz SkipLine2
            call InPortalRange

SkipLine2:  

normalmode:call InPaddleRange  ; Will change end round to 1 if a goal is scored
    
    cmp endround,1
    jnz DontExit1       ; if EndRound not equal 1 we skip over the return and continue 
    ret
    DontExit1:  call draw_ball_image
                cmp GameMode , 2
                jne RoundNotEnded
                call draw_portals  ;;;to draw portals again if ball hit the portal
    ;------------------------------------------------------------------------------------
    
    RoundNotEnded:          
                mov Ball_X2 ,cx 
                mov Ball_Y2,dx

                MOV CX,Ball_X ;set the initial column (X)
                MOV DX,Ball_Y
                call Clear_Ball_RedRAW ;drawing a blackbox for the previous ball location
                mov cx,Ball_X2
                mov dx,Ball_Y2
                mov Ball_X,cx
                mov Ball_Y,dx
    ;-----------------------------------
    ;All Draw Ball Horizontal must be preceeded by InPaddleRange and check end round
    cmp GameMode , 1                    ; If mode isnt the number 1 ( Middle Paddle ) , we skip line
    jnz SkipLine3
    call InPaddleRangeforMiddle
    SkipLine3:
              cmp GameMode , 2
              jnz SkipLine4
              call InPortalRange
    
     SkipLine4:
    ;       cmp GameMode , 3
    ;           jnz normalmode2
    ;         ;   call Tutorialmodez  ;;;tutorial mode

    normalmode2:
    call InPaddleRange      ; Will change end round to 1 if a goal is scored
    cmp endround , 1
    jnz DontExit  

    call draw_ball_withNoCollision          ; used to draw ball before serve only
    ret                     ; if EndRound not equal 1 we skip over the return and continue 
    
    DontExit: call draw_ball_image
            
            cmp GameMode , 2
            jne delay
            call draw_portals  ;;;to draw portals again if ball hit the portal
    ;--------------------------------------------
    
    ;; delay  
    delay:
    mov ah,86h
    mov dx,7FFFh
    mov cx,00h
    int 15h

    cmp GameMode , 1              ; If mode isnt the number 1 ( Middle Paddle ) , we skip line
    jnz SkipLine5
    call UP_OR_DOWN_MIDDLE
SkipLine5:
    mov ah,1
    int 16h  
    jz Recieving        

    cmp ah,72
    jz MoveUpOur

    cmp ah,80
    jz MoveDownOur

    ;Check if Esc is pressed
    cmp ah,01h
    jnz ReadKey
	mov al,ah
    call SendingGame
    call Pause
    cmp ResetApplication,1
    jz ExitMainDrawIfZero
    jmp Recieving

    ReadKey:   ;; Remove the key from keyboard buffeer
    ; mov ah,0
    ; int 16h  
    call clearinputbuffer
    call DrawPaddleLeft

;;Check if is Click
;;Check Theirs
    Recieving:
    Call RecieveGame

    cmp al,72
    jz MoveUpTheir

    cmp al,80
    jz MoveDownTheir

    cmp al,01h   ;;escape key
    jnz nopause
    call Pause
	cmp ResetApplication,1
ExitMainDrawIfZero:jz EndMainDraw
    nopause:
    jmp CHECK

    DrawRight:   
    call DrawPaddleRight
    jmp CHECK

    MoveUpTheir:
    mov CX , PaddleX
    Mov dx, PaddleY
    cmp dx,minY  ;check bounderies
    jz DrawRight
    call DrawUp
    jmp DrawRight

    MoveDownTheir:
    mov CX , PaddleX
    Mov dx, PaddleY 
    call CheckDownBoundary_Paddle
    jz DrawRight
    call DrawDown
    jmp DrawRight


    MoveUpOur:
    mov al,ah
    call SendingGame
    mov CX , PaddleXLeft
    Mov dx, PaddleYLeft
    cmp dx,minY   ;check bounderies
    jz ReadKey
    call DrawUp
    jmp ReadKey

    MoveDownOur:  ; to draw on the last pixel with black
     mov al,ah
    Call SendingGame
    mov CX , PaddleXLeft
    Mov dx, PaddleYLeft
    call CheckDownBoundary_Paddle
    jz ReadKey
    call DrawDown
    jmp ReadKey

EndMainDraw: ret
ENDP Maindraw


CheckDownBoundary_Paddle PROC
mov bx, MaxY
sub bx , PaddleSize
cmp dx , bx
RET 
ENDP CheckDownBoundary_Paddle

Pause proc

;;initialing cursor
mov ourcursor,1500h

mov othercursor,1500h 
add othercursor,18

;get a key from the in waiting mode User and if it is not ESC don't exit the Loop
pushf

;Print Pasue Message
mov  dl, 17  ;Column
mov  dh, 9   ;Row
mov  bh, 0    ;Display page
mov  ah, 02h  ;SetCursorPosition
int  10h


mov ah,9
mov dx,offset PauseMess1
int 21h
;Move to the Next Row to print another message
mov  dl, 10  ;Column
mov  dh, 10   ;Row
mov  bh, 0    ;Display page
mov  ah, 02h  ;SetCursorPosition
int  10h

mov ah,9
mov dx,offset PauseMess2
int 21h




;Print Last Pause Message
mov  dl, 2  ;Column
mov  dh, 11  ;Row
mov  bh, 0    ;Display page
mov  ah, 02h  ;SetCursorPosition
int  10h

mov ah,9
mov dx,offset PauseMess3
int 21h

call clearinputbuffer

GetKeyUser:
mov ah,1						;get key input
int 16h
jz recievenosend


call clearinputbuffer
CheckIfPause:
cmp ah,1   ;;scancode of esc
jz exitPausewithsend
cmp ah,3eh   ;; scancode of f4
jz ResetAppwithsend

call sendingpause

recievenosend:

call receivingpause
jz GetKeyUser

CheckIfPause2:
cmp chatbyte,27 ;Ascii of esc
jz exitPause
cmp chatbyte,3eh ;; scancode of f4
jz ResetApp

jmp GetKeyUser

ResetAppwithsend:
call sendingpause
ResetApp:
mov ResetApplication , 1
jmp exitPause

exitPausewithsend:
call sendingpause
exitPause:
  ;the user pressed Esc if true Exit the pause
mov ax,0600h
mov bh,00
mov cx,0
mov dx,184FH
int 10h 



call drawChatline
call DrawPaddleLeft
call DrawPaddleRight
call PrintFirstPlayer
call PrintSecondPlayer
;Draw the ball with no motion
call draw_ball_withNoCollision
; ;Waiting for key Pressed

popf
ret
endp Pause 


sendingpause proc


        ; mov ah,1						;get key input
		; int 16
		; jz midret					;if no keypress move to readingkeypresses
		; ; ; if keypress then send it and print it
		
		mov chatbyte,al  ;; now we change to ah to save scan code 5:20
		call clearinputbuffer
		
		cmp ah,3eh   ;; scancode of f4
		jne normally
		mov chatbyte,ah

normally:
		mov dx , 3FDH		; Line Status Register
		AGAINc1:  	
		In al , dx 			;Read Line Status
  		AND al , 00100000b
  		JZ AGAINc1
		
		mov dx , 3F8H		; Transmit data register
  		mov  al,chatbyte
  		out dx , al 
		
        mov ah,2                 ;move cursor at player1 pos
		mov bh,0
		mov dx,ourcursor             ;a5er el screen
		int 10h
		
		call displaychatbyte
		
		mov ah,3
		mov bh,0
		int 10h
		mov ourcursor,dx
		call checkscroll1Pause

		
		; ret
		
		cmp chatbyte,0DH				;cmp with enter
		je enter1
		
		cmp chatbyte,8					;cmp with backspace
		je  backspace1
		
		cmp chatbyte,27					;cmp with esc
		je chattomenu
		
		ret
		
		enter1:
		mov ah,2                 ;move cursor at player1 pos
		mov bh,0
		mov dx,ourcursor             ;a5er el screen
		inc dh
		mov dl,0h
		mov ourcursor,dx
		int 10h
		call checkscroll1Pause
		midret:
		ret
		

		backspace1:
		mov dx,ourcursor
		cmp dl,0
		jne notatendx1
		;here at end x

		; cmp dh,1
		; jne notatendy1
		
		;here at end x and y 
		
		mov ah,2
		mov dl,0    ;;; printing null
		int 21h

				
		ret

		notatendy1:
		;here at end x but not end y
		; call outro
		mov bx,ourcursor
		dec bh
		add bl,79
		mov ourcursor,bx
		mov ah,2                 ;move cursor at player1 pos
		mov bh,0
		mov dx,ourcursor             ;a5er el screen
		int 10h
		
		mov ah,2
		mov dl,0    ;;; printing null
		int 21h
		
		mov ah,3
		mov bh,0
		int 10h
		mov dl,79
		mov ourcursor,dx
		ret


		notatendx1:
		;here at not end x and not end y
		mov ah,2                 ;move cursor at player1 pos
		mov bh,0
		mov dx,ourcursor             ;a5er el screen
		int 10h
		
		
		mov ah,2
		mov dl,0
		int 21h
		
		mov ah,3
		mov bh,0
		int 10h
		mov ourcursor,dx
		dec ourcursor
		
		ret 


		
		
		chattomenu:
		; mov mode,1h
		; call resetindicators
		ret
		
		; keypressret:
		ret
endp sendingpause







receivingpause proc
		
		mov dx , 3FDH		; Line Status Register
		in al , dx 
  		AND al , 1
  		JZ mid2
		
		mov dx , 03F8H
  		in al , dx 
  		mov chatbyte , al
		
		; ;; just testing f4
		; cmp chatbyte,3eh   ;; scancode of f4
		; jne normally2
		; jmp mid2
		
		normally2:
		mov ah,2                 ;move cursor at player1 pos
		mov bh,0
		mov dx,othercursor             ;a5er el screen
		int 10h
		
		call displaychatbyte
		
		mov ah,3
		mov bh,0
		int 10h
		mov othercursor,dx
		call checkscroll2Pause
		
		
		cmp chatbyte,0DH				;cmp with enter
		je enter2
		
		cmp chatbyte,8					;cmp with backspace
		je backspace2
		
		cmp chatbyte,27			;will be  ((cmp with f4 ;;;;;;;;; will be changed soooon 
		je chattomenu2
		mid2:
		ret
		
		enter2:
		mov ah,2                 ;move cursor at player1 pos
		mov bh,0
		mov dx,othercursor             ;a5er el screen
		inc dh
		mov dl,0h
		mov othercursor,dx
		int 10h
		call checkscroll2Pause
		ret
		
		backspace2:
		mov dx,othercursor
		cmp dl,3
		jae notatendx2
		cmp dh,14
		jae notatendy2
		ret
		
		notatendy2:
		dec dh
		mov dl,79
		
		notatendx2:
		mov ah,2                 ;move cursor at player1 pos
		mov bh,0
		mov dx,othercursor             ;a5er el screen
		int 10h
		
		mov ah,2
		mov dl,0
		int 21h
		
		mov ah,3
		mov bh,0
		int 10h
		mov othercursor,dx
		dec othercursor
		
		ret 
		
		chattomenu2: cmp chatbyte,2h  ;;; jestletting zf != 1 testing
		; mov mode,1h
		; call resetindicators
		; ret
		
		receivingret:
		ret
receivingpause endp









checkscroll1Pause proc
		
		mov dx,ourcursor
		cmp dl,17
		je scroll

        cmp dh,23
		jne dontscroll1
		
    scroll:    
		mov ah,6       ; function 6
		mov al,1        ; scroll by 1 line    
		mov bh,0       ; normal video attribute         
		mov ch,21       ; upper left Y
		mov cl,0        ; upper left X
		mov dh,23     ; lower right Y
		mov dl,17     ; lower right X 
		int 10h 
		
		mov dx,ourcursor
		mov dh,22
        mov dl,0
		mov ourcursor,dx
		dontscroll1:
		ret
checkscroll1Pause endp



checkscroll2Pause proc
		
		mov dx,othercursor
		cmp dl,38
		je scroll2

        cmp dh,23
		jne dontscroll2
		
    scroll2:    
		mov ah,6       ; function 6
		mov al,1        ; scroll by 1 line    
		mov bh,0       ; normal video attribute         
		mov ch,21       ; upper left Y
		mov cl,18        ; upper left X
		mov dh,23     ; lower right Y
		mov dl,38     ; lower right X 
		int 10h 
		
		mov dx,othercursor
		mov dh,22
        mov dl,18
		mov othercursor,dx
		dontscroll2:
		ret
checkscroll2Pause endp

; displaychatbyte proc
		
; 		mov ah,2
; 		mov dl,chatbyte
; 		int 21h
		
; 		ret
; displaychatbyte endp








FinishMess proc

mov ax,0600h
mov bh,07
mov cx,0
mov dx,184fh
int 10h

; mov ah,0 ;Change into Text mode
; mov al,01h
; int 10h

; mov ah,2 ;Move Cursor To half screen
; mov dl,3
; mov dh,10
; mov bh,00
; int 10h

; mov ah,9 ;PRINT enter name 1 at x=1 y=10
; mov bl, 0bh ; color, eg bright blue in this case
; mov cx, 35; number of chars
; int 10h
; mov dx,offset EnterName1
; int 21h

ret
endp FinishMess

SendingGame PRoc

  		mov  SentMovementKey,al
		Send:
		mov dx , 3FDH		; Line Status Register
		AGAINc:  	
		In al , dx 			;Read Line Status
  		AND al , 00100000b
  		JZ AGAINc

        mov dx , 3F8H		; Transmit data register
  		mov  al,SentMovementKey
  		out dx , al 
        ret
endp SendingGame



RecieveGame Proc
    	mov dx , 3FDH		; Line Status Register
		in al , dx 
  		AND al , 1
          ;no movement
  		JZ mid3
		mov dx , 03F8H
  		in al , dx 
		mov Recived,al

    mid3:
    ret
endp RecieveGame

serialinitialize proc
		
		mov dx,3fbh 			; Line Control Register
		mov al,10000000b		;Set Divisor Latch Access Bit
		out dx,al	
		
		mov dx,3f8h				;set lsb of baud rate divisor
		mov al,0ch			
		out dx,al
		
		mov dx,3f9h				;set msb of baud rate divisor
		mov al,00h
		out dx,al
		
		mov dx,3fbh
		mov al,00011011b
		out dx,al

		ret
serialinitialize endp

ClearinputBuffer proc
push ax
mov al,0
mov ah,0CH
int 21H
pop ax
ret
endp ClearinputBuffer 

END MAIN
