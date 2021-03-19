.model small
.data      
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
BallVelocity_X dw 4h
BallVelocity_Y dw 4h

SpeedMode dw 4
V45X dw ?
V30X dw ?


minX dw 0
minY dw 2
MaxX  dw 138h
MaxY dw 150d
Ball_Start_X DW 6
Ball_Start_Y dw 80

;game needs 
endround db 0
keyboardinput dw 0
whocollides dw 0
noofcomputermovements dw 0

;players info
player1name db 'ahmed$'
player1score db '0$'
player2name db 'Computer$'
player2score db '0$'
comma db ':$'

;ball image data
ball_imgW equ 7
ball_imgH equ 7
ball_img DB 0, 0, 53, 53, 53, 0, 0, 0, 53, 53, 53, 53, 53, 0, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 53, 31, 31, 53, 53, 53, 53, 0, 53, 31, 53, 53 
         DB 53, 0, 0, 0, 53, 53, 53, 0, 0



.code
;;;; here we made draw as a function

MAIN  PROC FAR
;going to the graphics mode
mov AX, @data
mov DS, AX
Mov ah,0
mov al,13h
int 10h

mainmain:

call Serve
mov endround,0
Call Maindraw
jmp mainmain

HLT
MAIN    ENDP

Maindraw proc

    
    ;check if a key is Pressed
    CHECK:

    MOV CX,Ball_X ;set the initial column (X)
    MOV DX,Ball_Y  

    ;SAVING PREVIOUS LOCATION
    call InPaddleRangeforComputer
    call Draw_Ball_image

    push CX
    push dx
        ;;moving th computer
    call UP_OR_DOWN_Computer
    pop dx
    pop CX

    lcompare1:cmp endround,1
    jne x
    ret
    x:          mov Ball_X2 ,cx 
                mov Ball_Y2,dx

                MOV CX,Ball_X ;set the initial column (X)
                MOV DX,Ball_Y
                call Clear_Ball_RedRAW ;drawing a blackbox for the previous ball location
                mov cx,Ball_X2
                mov dx,Ball_Y2
                mov Ball_X,cx
                mov Ball_Y,dx
    
    call InPaddleRangeforComputer
    call draw_ball_withNoCollision
    
    lcompare2:
    cmp endround,1
    jne delay
    ret
    
    ;; delay  
    delay:
    mov ah,86h
    mov dx,7FFFh
    mov cx,00h
    int 15h
    
    ;;moving th computer
    call UP_OR_DOWN_Computer



    mov ah,1
    int 16h  
    jz MouseCheck        

    mov keyboardinput,1 ;;this flag to remove key from buffer as we provided both mouse and keyboard
    cmp ah,72
    jz MoveUp

    cmp ah,80
    jz MoveDown


    ReadKey:   ;; Remove the key from keyboard buffeer
    cmp keyboardinput,0
    je skip_removing_the_key_from_buffer
    mov ah,0
    int 16h  
    skip_removing_the_key_from_buffer:
    jmp DrawLeft

    MouseCheck:
    mov keyboardinput,0
    mov ax,3
    mov bx,0
    int 33h

    cmp bl,01h
    jz MoveUp

    cmp bl,02h
    jz MoveDown
    jmp CHECK

    DrawLeft:   
    call DrawPaddleLeft
    jmp CHECK

    MoveUp:
    mov CX , PaddleXleft
    Mov dx, PaddleYleft
    cmp dx,minY  ;check bounderies
    jz ReadKey
    call DrawUp
    jmp ReadKey


    MoveDown:
    mov CX , PaddleXleft
    Mov dx, PaddleYleft 
    call CheckDownBoundary_Paddle
    jz ReadKey
    call DrawDown
    jmp ReadKey


endmaindraw: ret
endp Maindraw

CheckYBoundary_Ball PROC

    push bx
        cmp dx,minY ;ball y<0 upper collision  
        JLE Negative_Y

        mov bx , MaxY
        sub bx , Ball_Size
        sub bx , BallVelocity_Y
        
        cmp dx,bx ;ball y>WINDOWHEIGHT lower collision  
        jge Negative_Y
        jmp ExitCheckYBoundary_Ball
        Negative_Y:
        neg BallVelocity_Y
    

ExitCheckYBoundary_Ball:    pop bx
                            RET
ENDP CheckYBoundary_Ball


CheckDownBoundary_Paddle PROC
mov bx, MaxY
sub bx , PaddleSize
cmp dx , bx
RET 
ENDP CheckDownBoundary_Paddle

DrawDown PROC

; to draw on the last pixel with black
mov al,0
mov ah,0ch
; draw black
int 10h
inc CX
int 10h
inc CX
int 10h
sub cx , 2

; to incease the y axes to move down
cmp CX , PaddleX
jz RightPaddleIncDown
inc PaddleYLeft
jmp EndDrawDownFunction

RightPaddleIncDown: inc PaddleY


EndDrawDownFunction: ret
ENDP DrawDown







DrawUp PROC
    ; remove the last Pixel
    mov al,0
    mov ah,0ch

    ; to draw on the last pixel
    add dx ,PaddleSize
    dec dx
    int 10h
    inc CX
    int 10h
    inc CX
    int 10h
    dec CX
    dec cx
    ; increase the paddle Y
    cmp CX , PaddleX
    jz RightPaddleIncUP

    dec PaddleYLeft
    jmp EndDrawDownFunction
    
    RightPaddleIncUP: dec PaddleY

    EndDrawUpFunction: ret

ENDP DrawUp




DrawPaddle PROC

mov ah,0ch ; Draw Pixel Commad
mov Bl, PaddleSize
Draw:
int 10h
inc CX
int 10h
inc cx
int 10h

inc dx ; draw next y point 
dec CX
dec CX
dec bl; draw till paddle size
jnz Draw

ret
ENDP DrawPaddle



DrawPaddleLeft PROC ;;; set color and coordinates first before calling draw paddle for the left one
mov cx,PaddleXLeft
Mov dx, PaddleYLeft
mov al,colorLeft ; pixel Color
call DrawPaddle
ret 
ENDP DrawPaddleLeft

DrawPaddleRight PROC    ;;; set color and coordinates first before calling draw paddle for the right one
mov cx,PaddleX
Mov dx, PaddleY
mov al,color ; pixel Color
call DrawPaddle
ret 
ENDP DrawPaddleRight

drawChatline proc 
mov cx,0
mov dx,MaxY
mov al,5
mov ah,0ch
back: 
    sub dx,149
    int 10h
    add dx,149
    int 10h
    add dx,10
    int 10h
    sub dx,10
    add dx,40
    int 10h
    sub dx,40
    inc CX
    cmp cx,320
    jnz back

ret 
endp

;--------------------  DrawPBall
;When joining files remove clear screen
DRAW_BALL_HORIZONTAL PROC near
push cx
push dx
label1:
			MOV AH,0Ch ;set the configuration to writing a pixel
			MOV AL,0Fh ;choose white as color
			MOV BH,00h ;set the page number 
			INT 10h    ;execute the configuration
			
			INC CX     ;CX = CX + 1
			MOV AX,CX          ;CX - BALL_X > BALL_SIZE (Y -> We go to the next line,N -> We continue to the next column
			SUB AX,Ball_X
			CMP AX,Ball_Size
			JNG label1
			MOV CX,Ball_X ;the CX register goes back to the initial column
			INC DX        ;we advance one line
			MOV AX,DX              ;DX - BALL_Y > BALL_SIZE (Y -> we exit this procedure,N -> we continue to the next line
			SUB AX,Ball_Y
			CMP AX,Ball_Size
			JNG label1
        pop dx
        pop cx

        ;-----------------------------------------------------------------

        
        ;-----------------------------------------------------------------

        call InPaddleRangeforComputer
        cmp endround,1
        je exitdraw_horizontal

        add cx , BallVelocity_X ; Increment X and Y
        add dx , BallVelocity_Y 
        
CHECK_Y:
        call CheckYBoundary_Ball

        ;  call InPaddleRangeforComputer
    
       exitdraw_horizontal:     ret
            DRAW_BALL_HORIZONTAL ENDP


draw_ball_image proc 
push cx
push dx

	       MOV AH,0Bh   	;set the configuration
	       MOV CX, ball_imgW
	       add cx,Ball_X  	;set the width (X) up to image width (based on image resolution)
	       MOV DX, ball_imgH 	;set the hieght (Y) up to image height (based on image resolution)
	       add dx,Ball_Y
	       mov DI, offset ball_img  ; to iterate over the pixels
	       jmp Start    	;Avoid drawing before the calculations
	Drawit:
	       MOV AH,0Ch   	;set the configuration to writing a pixel
           mov al, [DI]     ; color of the current coordinates
	       MOV BH,00h   	;set the page number
	       INT 10h      	;execute the configuration
	Start: 
		   inc DI
	       DEC Cx
	       cmp cx,Ball_X       	;  loop iteration in x direction
	       JNZ Drawit      	;  check if we can draw c urrent x and y and excape the y iteration
	       mov Cx, ball_imgW
	       add cx,Ball_X 	;  if loop iteration in y direction, then x should start over so that we sweep the grid
	       DEC DX     
	       cmp dx,Ball_Y  	;  loop iteration in y direction
	       JZ  ENDING   	;  both x and y reached 00 so end program
		   Jmp Drawit

	ENDING:
           
           Ending: pop dx
           pop cx
        
        call InPaddleRangeforComputer
        cmp endround,1
        je exitdraw_horizontal2

        add cx , BallVelocity_X ; Increment X and Y
        add dx , BallVelocity_Y 

CHECK_Y2:
        call CheckYBoundary_Ball
    
       exitdraw_horizontal2:  ret
endp draw_ball_image







    Clear_Ball_RedRAW PROC near
    push cx
    push dx
    label2:
            MOV AH,0Ch ;set the configuration to writing a pixel
			MOV AL,0 ;choose black as color
			MOV BH,00h ;set the page number 
			INT 10h    ;execute the configuration
	        INC CX     ;CX = CX + 1
			MOV AX,CX          ;CX - BALL_X > BALL_SIZE (Y -> We go to the next line,N -> We continue to the next column
			SUB AX,Ball_X
			CMP AX,Ball_Size
			JNG label2
			
			MOV CX,Ball_X ;the CX register goes back to the initial column
			INC DX        ;we advance one line
			
			MOV AX,DX              ;DX - BALL_Y > BALL_SIZE (Y -> we exit this procedure,N -> we continue to the next line
			SUB AX,Ball_Y
			CMP AX,Ball_Size
			JNG label2
            pop dx
            pop cx
            add dx, BALLVELOCITY_Y
        
            ret
        Clear_Ball_RedRAW ENDP


 InPaddleRangeforComputer PROC
        push ax ; for testing
        push bx

        cmp cx , 5  ; Compares if X passes the x co rdinate of the paddle
        jle leftcheck_TUTORIAL_MODE
        
        mov ax,CX
        add ax,Ball_Size
        cmp ax , 315
        jge rightcheck_TUTORIAL_MODE

        jmp ExitInPaddleRangeforComputer        

        leftcheck_TUTORIAL_MODE:
        mov bx , PaddleYLeft
        mov whocollides,bx ;; here we saved the ycoordinates of the paddle hitting
        sub bx , Ball_Size
        cmp dx , bx  ; Compares lower point of ball (dx) with top of paddle
        jl PointScored_TUTORIAL_MODE
        ;-----------------------------------------------------------

        mov BX , PaddleYLeft
        add BX , PaddleSize  
        cmp dx , bx ;   Compares upper point of ball (dx) with bottom of paddle
        jg PointScored_TUTORIAL_MODE

        jmp HitPaddle_TUTORIAL_MODE

        rightcheck_TUTORIAL_MODE:
        mov bx , PaddleY
        mov whocollides,bx  ;; here we saved the ycoordinates of the paddle hitting
        sub bx , Ball_Size
        cmp dx , bx  ; Compares lower point of ball (dx) with top of paddle
        jl PointScored_TUTORIAL_MODE
        ;-----------------------------------------------------------

        mov BX , PaddleY
        add BX , PaddleSize
        cmp dx , bx ;   Compares upper point of ball (dx) with bottom of paddle
        jg PointScored_TUTORIAL_MODE

        HitPaddle_TUTORIAL_MODE: 
        ; If the code jumps to this label 
        ;this means that the ball is 100% inside the paddle
        ; \(o o)/ Whooo !!!

        ;---------------------------------
        cmp ax,PaddleX_initially
        jl dontchangeangle
        call SetPlayingVelocity

        dontchangeangle:
        call PaddleCollision
        jmp ExitInPaddleRangeforComputer
        
            ;-----------------------------------------------

        ; Handles the event that the ball is scored

        ; i.e. Resetting the game and adding the score

        PointScored_TUTORIAL_MODE: ;;;; reset ball and printing new score 
        cmp cx , 5  ; Compares if X passes the x co rdinate of the paddle
        jle rightplayerscores_TUTORIAL_MODE
        
        call IncrementPlayer1Score
        
        jmp endthisround_TUTORIAL_MODE
        rightplayerscores_TUTORIAL_MODE: call IncrementPlayer2Score

        endthisround_TUTORIAL_MODE:
        mov endround,1
        jmp ExitInPaddleRangeforComputer

        ;------------------------------------------------------
      

         
        ExitInPaddleRangeforComputer:pop bx
                          pop ax ; testing
                          RET
        ENDP InPaddleRangeforComputer



PaddleCollision PROC

  ; This assumes that the program has PaddleY position in BX
;---------------------------------------------------------------
  ;Check which part in the paddle the ball hit
        
        ;therefore we need what in bx and add to it paddlediv3
        ; add bx , PaddleDiv3
        ; mov ax , Ball_Y
        ; add ax , Ball_Size
        ; xchg ax , bx

        mov ax,whocollides
        add ax ,PaddleDiv3
        
        mov bx , Ball_Y
        add bx , Ball_Size

        cmp bx , ax
        jle HitTopOrBottom

        add ax , PaddleDiv3
        cmp bx , ax
        jle HitMiddle

        jmp HitTopOrBottom


;------------------------------------------------------------          
        ; Handle the velocities when the ball hits
        ; different parts of the paddle

        HitTopOrBottom:
                
                mov ax , BallVelocity_Y
                cmp ax,0        ;Checks if angle hit was 0
                jz AngleIsZero 


                ; if Y angle isnt 0 compare X velocity with X velocity at angle 45
                mov ax , BallVelocity_X
                call AbsoluteAx
                
                cmp ax,V45X
                jz AngleIs45
                jmp AngleIs30




        HitMiddle:
                neg BallVelocity_X
                jmp ExitPaddleCollision


        AngleIsZero:
                neg BallVelocity_X
                mov ax , SpeedMode
                                        ;Magnitude is right but not angle
                                        ;Velocity is down
                call CompareUpperLower
                jge Upper 

                neg ax

                Upper:
                mov BallVelocity_Y , ax
                jmp ExitPaddleCollision 


        AngleIs30:
            mov ax , 0
            mov BallVelocity_Y , ax

            ; Speed if Angle is 30 , Velocity X = 2 * speedMode
            ; Divide Velocity X by 2 and get the negative
            
            mov ax , BallVelocity_X
            sar ax , 1
            mov BallVelocity_X , ax
            neg BallVelocity_X      

            jmp ExitPaddleCollision   

        AngleIs45:
            
            ; if Angle is 45 , Coming velocity is Speed Mode
            ; We want to invert Direction and double the speed
            ; so we multiply the ball velocity by -2

            mov ax , BallVelocity_X

            sal ax , 1

            neg ax
            mov BallVelocity_X , ax

            
            jmp ExitPaddleCollision



ExitPaddleCollision:
call DrawOnceAndClearAfterCollide
ret
ENDP PaddleCollision



DrawOnceAndClearAfterCollide PROC


mov cx , Ball_X
mov dx , Ball_Y

call Clear_Ball_RedRAW
add cx , BallVelocity_X
add dx , BallVelocity_Y
mov Ball_Y , dx
mov Ball_X , cx

mov cx,PaddleX
mov dx,PaddleY
call DrawPaddleRight

mov cx,PaddleXLeft
mov dx,PaddleYLeft
call drawpaddleleft


mov cx , Ball_X
mov dx , Ball_Y

RET
ENDP DrawOnceAndClearAfterCollide




Serve PROC
    
    call SetPlayingVelocity ;New Line Added
                            ; Sets a random velocity at the start of each serve (-45 , 0 , 45)
    mov ax,0600h
    mov bh,00h
    mov cx,0
    mov dx,184fh
    int 10h

    redraw:
    ;; returing left paddle current position to its initial and drawing
    mov cx,PaddleXLeft_initially
    mov dx,PaddleYLeft_initially
    mov PaddleXLeft,cx
    mov PaddleYLeft,dx
    call DrawPaddleLeft

    ;; returing right paddle current position to its initial and drawing
    mov cx,PaddleX_initially
    mov dx,PaddleY_initially
    mov PaddleX,cx
    mov PaddleY,dx
    call DrawPaddleRight


    call drawChatline
    call PrintFirstPlayer
    call PrintSecondPlayer
    MOV CX,Ball_Start_X ;putting the ball coordinate in its initial position again in current pos(ballx,bally)
    MOV DX,Ball_Start_Y
    mov Ball_X,CX
    mov Ball_Y,dx
    ;Waiting for key Pressed
    mov ah,0
    int 16h
    ret
    ENDP Serve



UP_OR_DOWN_Computer proc

    cmp BallVelocity_Y,0  ;; here comparing the velcity_Y with 0 meaning its horizontally moving
    je nomore  ;;so dont move the paddle
  
    cmp BallVelocity_Y,0  ;; if the velocity is greater than 0, therefore moving down
    jg MoveDownComputer

    MoveUpComputer:
    mov CX , PaddleX
    Mov dx, PaddleY

    cmp dx,minY  ;check bounderies
    jz nomore 
    call DrawUp
    call DrawPaddleRight
    mov CX , PaddleX
    Mov dx, PaddleY
    call DrawUp
    call DrawPaddleRight
    jmp nomore

    MoveDownComputer:
    mov CX , PaddleX
    Mov dx, PaddleY
    call CheckDownBoundary_Paddle
    jz  nomore ;; will go up if reached down
    call DrawDown
    call DrawPaddleRight
    mov CX , PaddleX
    Mov dx, PaddleY
    call DrawDown
    call DrawPaddleRight
nomore:  
ret
endp


SetPlayingVelocity PROC  ;New Proc added

push ax
push cx 
push dx

mov ah , 02CH
int 21h ; Gets system time , CX has hours & min
        ; dx has seconds in dh and seconds/100 in dl
mov dl , 0 ; clear second
mov ax , 3

xchg ax , dx ; ax now has time in second in ah
             ; dx has 3 which is the condition asked in document

xchg ah , al 

div dl


mov cx , SpeedMode ; Since Angle is either 45 , -45 or 0 Velocity X will always be equal speed mode
mov BallVelocity_X , cx

cmp ah , 1
jz SetStartVelocity0



SetVelocity45:
            cmp ah , 0
            xchg ax , cx
            jz ExitSetPlayingVelocity
            neg ax
            jmp ExitSetPlayingVelocity

            
            
SetStartVelocity0:
                    mov ax ,0
                    jmp ExitSetPlayingVelocity



ExitSetPlayingVelocity:
    mov BallVelocity_Y , ax
    pop dx 
    pop CX
    pop ax
    
    ret

ENDP SetPlayingVelocity



AbsoluteAx PROC
    ;makes A = |Ax|
    cmp AX , 0 
    jge Exit_AbsoluteAX

    neg ax


    Exit_AbsoluteAX:ret
ENDP AbsoluteAx

CompareUpperLower PROC
    ; Checks if ball is in upper half of paddle or lower half of paddle
    ;jge is true if its in upper
push ax

mov ax , PaddleY
add ax , PaddleDiv3

cmp dx , ax
jge ExitCompareUpperLower ; Output is upper
ExitCompareUpperLower:
pop ax
ret
ENDP CompareUpperLower







PrintFirstPlayer proc

mov  dl, 0  ;Column
mov  dh, 19   ;Row
mov  bh, 0    ;Display page
mov  ah, 02h  ;SetCursorPosition
int  10h


mov ah,9
mov dx,offset player1name
int 21h

mov dx,offset comma
int 21h

mov dx,offset player1score
int 21h

ret 
endp PrintFirstPlayer 


PrintSecondPlayer proc

mov  dl, 70  ;Column
mov  dh, 19   ;Row
mov  bh, 0    ;Display page
mov  ah, 02h  ;SetCursorPosition
int  10h


mov ah,9
mov dx,offset player2name
int 21h

mov dx,offset comma
int 21h

mov dx,offset player2score
int 21h

ret 
endp PrintSecondPlayer


INCREMENTPLAYER1SCORE proc

inc player1score
call PrintFirstPlayer
ret 
endp INCREMENTPLAYER1SCORE



INCREMENTPLAYER2SCORE proc

inc player2score
call PrintSecondPlayer
ret 
endp INCREMENTPLAYER2SCORE




draw_ball_withNoCollision   proc


push cx
push dx

	       MOV AH,0Bh   	;set the configuration
	       MOV CX, ball_imgW
	       add cx,Ball_X  	;set the width (X) up to image width (based on image resolution)
	       MOV DX, ball_imgH 	;set the hieght (Y) up to image height (based on image resolution)
	       add dx,Ball_Y
	       mov DI, offset ball_img  ; to iterate over the pixels
	       jmp Start1   	;Avoid drawing before the calculations
	Drawit1:
	       MOV AH,0Ch   	;set the configuration to writing a pixel
           mov al, [DI]     ; color of the current coordinates
	       MOV BH,00h   	;set the page number
	       INT 10h      	;execute the configuration
	Start1: 
		   inc DI
	       DEC Cx
	       cmp cx,Ball_X       	;  loop iteration in x direction
	       JNZ Drawit1      	;  check if we can draw c urrent x and y and excape the y iteration
	       mov Cx, ball_imgW
	       add cx,Ball_X 	;  if loop iteration in y direction, then x should start over so that we sweep the grid
	       DEC DX     
	       cmp dx,Ball_Y  	;  loop iteration in y direction
	       JZ  ENDING1   	;  both x and y reached 00 so end program
		   Jmp Drawit1

	ENDING1:
          pop dx
           pop cx
   
ret
endp draw_ball_withNoCollision



END MAIN



