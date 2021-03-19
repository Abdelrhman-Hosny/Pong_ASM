.code


 InPaddleRange PROC
        push ax ; for testing
        push bx

        cmp cx , 2  ; Compares if X passes the x co rdinate of the paddle
        jle leftcheck
        mov ax,CX
        add ax,Ball_Size
        cmp ax , 317
        jge rightcheck

        jmp ExitInPaddleRange        

        leftcheck:
        mov bx , PaddleYLeft
        mov whocollides,bx
        sub bx , Ball_Size
        cmp dx , bx  ; Compares lower point of ball (dx) with top of paddle
        jl PointScored
        ;-----------------------------------------------------------

        mov BX , PaddleYLeft
        add BX , PaddleSize
        cmp dx , bx ;   Compares upper point of ball (dx) with bottom of paddle
        jg PointScored

        jmp HitPaddle

        rightcheck:
        mov bx , PaddleY
        mov whocollides,bx
        sub bx , Ball_Size
        cmp dx , bx  ; Compares lower point of ball (dx) with top of paddle
        jl PointScored
        ;-----------------------------------------------------------

        mov BX , PaddleY
        add BX , PaddleSize
        cmp dx , bx ;   Compares upper point of ball (dx) with bottom of paddle
        jg PointScored

        HitPaddle: 
        ; If the code jumps to this label 
        ;this means that the ball is 100% inside the paddle
        ; \(o o)/ Whooo !!!

        ;---------------------------------

        call PaddleCollision
        jmp ExitInPaddleRange
        ;-----------------------------------------------

        ; Handles the event that the ball is scored

        ; i.e. Resetting the game and adding the score

        PointScored:  ; reset ball and printing new score 
        cmp cx , 5  ; Compares if X passes the x co rdinate of the paddle
        jle RightPlayerScores
        call IncrementPlayer1Score
        jmp SetEndRound
        RightPlayerScores: call IncrementPlayer2Score

        SetEndRound:
        mov endround,1
        jmp ExitInPaddleRange

        ;------------------------------------------------------
      

         
        ExitInPaddleRange:pop bx
                          pop ax ; testing
                          RET
        ENDP InPaddleRange

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

AbsoluteAX PROC
    ; makes numbers in AX postive

    cmp AX , 0 
    jge Exit_AbsoluteAX

    neg ax


    Exit_AbsoluteAX:ret
ENDP AbsoluteAX



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
    cmp LastScored,1
    je TheirServe
    MOV CX,Ball_Start_X_Ours ;changed ball start X to ours as they last scored
   call SendBallVelocity
   mov ax , SpeedMode   
    mov BallVelocity_X,ax

    jmp endserve
    ;Draw the ball with no motion
    TheirServe:
     MOV CX,Ball_Start_X_Theirs ;changed ball start X to theirs as we last scored
     call RecieveBallVelocity
 mov ax , SpeedMode   
neg ax
mov BallVelocity_X,ax
    
    endserve:
    MOV DX,Ball_Start_Y
    mov Ball_X,CX
    mov Ball_Y,dx
    call draw_ball_withNoCollision
    ;Waiting for key Pressed

    
;     mov ah,0    ;;;; will return when we review starting
;     int 16h
    
    ret
    ENDP Serve





SendBallVelocity proc
		push CX
		mov dx , 3FDH		; Line Status Register
		AGAIN3:
		In al , dx 			;Read Line Status
  		AND al , 00100000b
  		JZ AGAIN3                                                      ; AH            AL
                                       ;                            -Vx              Vy
        

		;cx feha velocity x
;       ax feha velocity y
       ;we get ballvelocity y    back from stack
        mov ax, BallVelocity_Y
        ;mov cx, BallVelocity_X
        mov ah , cl                 ; al already has velocity y from previous

        neg ah                      ; ah has ball velocity x negative
                                    ; so ax already has both velocities


		mov dx , 3F8H		; Transmit data register
  		out dx , ax
		
		
		; mov dx , 3FDH		; Line Status Register
		; AGAIN4:
		; In al , dx 			;Read Line Status
  		; AND al , 00100000b
  		; JZ AGAIN4
		
		; mov dx , 3F8H		; Transmit data register
  		; mov  ax,ballspeed+1
  		; out dx , ax
		  pop cx
		ret
SendBallVelocity endp


RecieveBallVelocity proc
		
		
		mov dx , 3FDH		; Line Status Register
		 ;we have to get velocity
		in al , dx 
  		AND al , 1
  		JZ CHK1
		
		mov dx , 03F8H ;recieve data in ax
  		in ax , dx 

                                                                    ; AH            AL
                                       ;                            -Vx              Vy
		push CX
        mov ch,ah    ; store -Vx in ch then 
        ; and ah,0        ;make ah,0 so that we send ball velocity Y
        cbw              ;convert al to ax with sign
        mov BallVelocity_Y,ax  ;save ball velocity y
        mov al,ch
        cbw        
       ; mov BallVelocity_X,ax
        pop cx
      CHK1:  ret
        
RecieveBallVelocity endp








