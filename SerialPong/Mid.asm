.code



UP_OR_DOWN_MIDDLE PROC

cmp upordown,0
jne MoveDownMiddle

MoveUpMiddle:
    mov upordown,0
    mov CX , PaddleXMiddle
    Mov dx, PaddleYMiddle
    cmp dx,minY  ;check bounderies
    jz MoveDownMiddle 
    call DrawUp
    jmp end_drawing_the_middle 

    MoveDownMiddle:
    mov upordown,1
    mov CX , PaddleXMiddle
    Mov dx, PaddleYMiddle 
    call CheckDownBoundary_Paddle
    jz MoveUpMiddle ;; will go up if reached down
    call DrawDown

end_drawing_the_middle: 
    call DrawPaddleMiddle
    ret
ENDP UP_OR_DOWN_MIDDLE


DrawPaddleMiddle PROC ;;; set color and coordinates first before calling draw paddle for the left one
mov cx,PaddleXMiddle
Mov dx, PaddleYMiddle
mov al,ColorMiddle ; pixel Color
call DrawPaddle
ret 
ENDP DrawPaddleMiddle

  
InPaddleRangeforMiddle PROC   ;;;
        push ax ; for testing
        push bx



        cmp BallVelocity_X,0
        jge compareoftheleftsideofthepaddle ;;same of hit of right paddle
       
        jmp compareoftherightsideofthepaddle ;;same of hit of left paddle

        compareoftheleftsideofthepaddle:
        mov ax,CX
        add ax,Ball_Size
        cmp ax , 150
        jge youhitmyleftside
        jmp ExitInPaddleRangeofMiddle

        compareoftherightsideofthepaddle: cmp cx,153
        jle youhitmyrightside
        jmp ExitInPaddleRangeofMiddle
        
        
        youhitmyrightside: ;;if the ball hit the right side of the paddle
        cmp cx,150
        jl ExitInPaddleRangeofMiddle

        mov bx , PaddleYMiddle
        mov whocollides,bx ;; here we saved the ycoordinates of the paddle hitting
        sub bx , Ball_Size
        cmp dx , bx  ; Compares lower point of ball (dx) with top of paddle
        jl ExitInPaddleRangeofMiddle
        ;-----------------------------------------------------------

        mov BX , PaddleYMiddle
        add BX , PaddleSize  
        cmp dx , bx ;   Compares upper point of ball (dx) with bottom of paddle
        jg ExitInPaddleRangeofMiddle

        jmp HitPaddle2

        youhitmyleftside:   ;;if the ball hit the left side of the paddle
        cmp ax,153
        jg ExitInPaddleRangeofMiddle
        mov bx , PaddleYMiddle
        mov whocollides,bx  ;; here we saved the ycoordinates of the paddle hitting
        sub bx , Ball_Size
        cmp dx , bx  ; Compares lower point of ball (dx) with top of paddle
        jl ExitInPaddleRangeofMiddle
        ;-----------------------------------------------------------

        mov BX , PaddleYMiddle
        add BX , PaddleSize
        cmp dx , bx ;   Compares upper point of ball (dx) with bottom of paddle
        jg ExitInPaddleRangeofMiddle
 

        HitPaddle2:
        call PaddleCollision
        jmp ExitInPaddleRangeofMiddle
       
       
         
        ExitInPaddleRangeofMiddle:
                          pop bx
                          pop ax ; testing
                          RET
ENDP InPaddleRangeforMiddle




