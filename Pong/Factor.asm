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
Ball_Start_X DW 6
Ball_Start_Y dw 75

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



;Middle Paddle Variables
;--------------------------------
ColorMiddle equ 08h                   
PaddleSize equ 42
PaddleDiv3 equ 13
PaddleXMiddle DW 150
PaddleYMiddle DW 60
PaddleXMiddle_initially DW 150
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

SpeedMode dw ?

;Drawing Info
Load DB 'Load.bin', 0
MainMenu DB 'MainM.bin',0
Speed DB 'Speed.bin',0
Mode DB 'Mode.bin',0

;Pause message
Win1Message db "Player 1 wins!! $"
Win2Message db "Player 2 wins!! $"
PauseMess1 DB "PAUSE$"
PauseMess2 DB "Press ESC To Continue$"
PauseMess3 DB "Press F4 to Return to the Main Menu$"

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




.code
;;;; here we made draw as a function

MAIN  PROC FAR

ExitToMainMenu:
;going to the graphics mode
mov AX, @data
mov DS, AX
;Clear the buffer
mov al,0 
mov ah , 0ch
int 21h

;to clear the buffer
;cmp ah,al
call MainMenuDraw
mov ResetApplication,0

; cmp Exit33,01h
; je Finish




GameLoop:

Mov ah,0
mov al,13h
int 10h

mainmain:
; call drawChatline

    call SetInitialVelocities ; New Line Added
                          ; Sets the Variables V45Y , V30Y  (Velocity of y at angle 45)


    call Serve
    mov endround,0

    cmp GameMode,3
    jne othermodes
    call MAINDRAW_TUTORIAL_MODE
    cmp ResetApplication,1
    jz ExitToMainMenu
    jmp mainmain

    othermodes:
    Call Maindraw
    cmp ResetApplication,1
    jz ExitToMainMenu


jmp mainmain

ChatModule:




Finish:

call FinishMess

;HLT
MAIN    ENDP



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
    jz MouseCheck        

    cmp ah,72
    jz MoveUp

    cmp ah,80
    jz MoveDown

    ;Check if Esc is pressed
    cmp ah,01h
    jnz ReadKey
    call Pause
    cmp ResetApplication,1
    jz EndMainDraw
    jmp MouseCheck


    


    ReadKey:   ;; Remove the key from keyboard buffeer
    mov ah,0
    int 16h  
    call DrawPaddleRight


    MouseCheck:
    mov ax,3
    mov bx,0
    int 33h

    cmp bl,01h
    jz MoveUpLeft

    cmp bl,02h
    jz MoveDownLeft
    jmp CHECK

    DrawLeft:   
    call DrawPaddleLeft
    jmp CHECK

    MoveUp:
    mov CX , PaddleX
    Mov dx, PaddleY
    cmp dx,minY  ;check bounderies
    jz ReadKey
    call DrawUp
    jmp ReadKey


    MoveDown:
    mov CX , PaddleX
    Mov dx, PaddleY 
    call CheckDownBoundary_Paddle
    jz ReadKey
    call DrawDown
    jmp ReadKey


    MoveUpLeft:
    mov CX , PaddleXLeft
    Mov dx, PaddleYLeft
    cmp dx,minY   ;check bounderies
    jz DrawLeft
    call DrawUp
    jmp DrawLeft

    MoveDownLeft:  ; to draw on the last pixel with black
    mov CX , PaddleXLeft
    Mov dx, PaddleYLeft
    call CheckDownBoundary_Paddle
    jz DrawLeft
    call DrawDown
    jmp DrawLeft

EndMainDraw: ret
ENDP Maindraw


CheckDownBoundary_Paddle PROC
mov bx, MaxY
sub bx , PaddleSize
cmp dx , bx
RET 
ENDP CheckDownBoundary_Paddle

Pause proc
;get a key from the in waiting mode User and if it is not ESC don't exit the Loop
pushf
mov ah,0
int 16h

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



GetKeyUser:
mov ah,0
int 16h
; check if the key is esc
CheckIfPause:
cmp ah,01h ;Ascii of esc
jz exitPause
cmp ah,3eh
jz ResetApp

;the key is not esc return to the loop
jmp GetKeyUser

ResetApp:
mov ResetApplication , 1




exitPause:  ;the user pressed Esc if true Exit the pause
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

       

END MAIN
