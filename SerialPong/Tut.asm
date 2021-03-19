.code




MAINDRAW_TUTORIAL_MODE proc


    ;check if a key is Pressed
    CHECK_TUTORIAL_MODE:

    MOV CX,Ball_X ;set the initial column (X)
    MOV DX,Ball_Y  

    ;SAVING PREVIOUS LOCATION
    call InPaddleRangeforComputer
    call draw_ball_image


    ;;moving th computer
    call UP_OR_DOWN_Computer

    lcompare1_TUTORIAL_MODE:cmp endround,1
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
    
    lcompare2_TUTORIAL_MODE:
    cmp endround,1
    jne delay_TUTORIAL_MODE
    ret
    
    ;; delay  
    delay_TUTORIAL_MODE:
    mov ah,86h
    mov dx,7FFFh
    mov cx,00h
    int 15h
    
    ;;moving th computer
    call UP_OR_DOWN_Computer



    mov ah,1
    int 16h  
    jz MouseCheck_TUTORIAL_MODE        

    mov keyboardinput,1 ;;this flag to remove key from buffer as we provided both mouse and keyboard
    cmp ah,72
    jz MoveUp_TUTORIAL_MODE

    cmp ah,80
    jz MoveDown_TUTORIAL_MODE
    
    ;Check if Esc is pressed
    cmp ah,01h
    jnz ReadKey_TUTORIAL_MODE
    call Pause
    cmp ResetApplication,1
    jz endMAINDRAW_TUTORIAL_MODE
    jmp MouseCheck_TUTORIAL_MODE


    ReadKey_TUTORIAL_MODE:   ;; Remove the key from keyboard buffeer
    cmp keyboardinput,0
    je skip_removing_the_key_from_buffer
    mov ah,0
    int 16h  
    skip_removing_the_key_from_buffer:
    jmp DrawLeft_TUTORIAL_MODE

    MouseCheck_TUTORIAL_MODE:
    mov keyboardinput,0
    mov ax,3
    mov bx,0
    int 33h

    cmp bl,01h
    jz MoveUp_TUTORIAL_MODE

    cmp bl,02h
    jz MoveDown_TUTORIAL_MODE
    jmp CHECK_TUTORIAL_MODE

    DrawLeft_TUTORIAL_MODE:   
    call DrawPaddleLeft
    jmp CHECK_TUTORIAL_MODE

    MoveUp_TUTORIAL_MODE:
    mov CX , PaddleXleft
    Mov dx, PaddleYleft
    cmp dx,minY  ;check bounderies
    jz ReadKey_TUTORIAL_MODE
    call DrawUp
    jmp ReadKey_TUTORIAL_MODE


    MoveDown_TUTORIAL_MODE:
    mov CX , PaddleXleft
    Mov dx, PaddleYleft 
    call CheckDownBoundary_Paddle
    jz ReadKey_TUTORIAL_MODE
    call DrawDown
    jmp ReadKey_TUTORIAL_MODE

endMAINDRAW_TUTORIAL_MODE: ret
endp MAINDRAW_TUTORIAL_MODE




    InPaddleRangeforComputer PROC
        push ax ; for testing
        push bx

        cmp cx , 2  ; Compares if X passes the x co rdinate of the paddle
        jle leftcheck_TUTORIAL_MODE
        
        mov ax,CX
        add ax,Ball_Size
        cmp ax , 317
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




UP_OR_DOWN_Computer proc
push CX
push dx

    adjust:  ;; to adjust the ball with paddle 
    Mov dx,Ball_Y
    cmp dx,PaddleY
    je nomore
    cmp dx,PaddleY
    jg movedownforadjustment
    Mov dx, PaddleY
    cmp dx,minY  ;check bounderies
    jz nomore 
    Mov dx, PaddleY   ; to adjust the ball with paddle by going up 
    mov CX , PaddleX
    call DrawUp
    call DrawPaddleRight
    ; jmp adjusthorizontal
    jmp nomore

movedownforadjustment: ;; move down to adjust with the ball by going down
        mov CX , PaddleX
        Mov dx, PaddleY
        call CheckDownBoundary_Paddle
        jz  nomore ;; will go up if reached down
        Mov dx, PaddleY
        mov CX , PaddleX
        call DrawDown
        call DrawPaddleRight
        ; jmp adjusthorizontal

nomore:  pop dx 
        pop cx
ret
endp