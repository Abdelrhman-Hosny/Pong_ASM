.code

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

cmp cx,PaddleXMiddle
jz MiddlePaddleIncDown

inc PaddleYLeft
jmp EndDrawDownFunction

MiddlePaddleIncDown: inc PaddleYMiddle
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
    
    cmp cx,PaddleXMiddle
    jz MiddlePaddleIncUp
    ;otherwise
    dec PaddleYLeft
    jmp EndDrawDownFunction
 
    MiddlePaddleIncUp: dec PaddleYMiddle
    jmp EndDrawDownFunction

    RightPaddleIncUP: dec PaddleY

    EndDrawUpFunction: ret

ENDP DrawUp



DrawPaddle PROC

mov ah,0ch ; Draw Pixel Commad
mov DI, offset img
mov Bl, PaddleSize
Draw:
mov al,[DI]
int 10h
inc CX
inc DI
mov al,[DI]
int 10h
inc CX
inc DI
mov al,[DI]
int 10h
inc cx
inc DI
mov al,[DI]
int 10h
inc DI
inc dx ; draw next y point 
sub cx,3
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

drawChatline PROC 
mov cx,0
mov dx,MaxY
mov al,5
mov ah,0ch
back: 
    sub dx,149
    int 10h
    add dx,149
    int 10h
    add dx,11
    int 10h
    sub dx,11
    ; add dx,40
    ; int 10h
    ; sub dx,40
    inc CX
    cmp cx,320
    jnz back

call PrintEscapeMessage
ret 
ENDP drawChatline





PrintFirstPlayer PROC

mov  dl, 0  ;Column
mov  dh, 19   ;Row
mov  bh, 0    ;Display page
mov  ah, 02h  ;SetCursorPosition
int  10h





mov ah,9
mov dx,offset player1name
int 21h

mov  dl, 0 ;Column
add dl,actualsizep1
mov  dh, 19   ;Row
mov  bh, 0    ;Display page
mov  ah, 02h  ;SetCursorPosition
int  10h

mov ah,9
mov dx,offset comma
int 21h


mov dx,offset player1score
int 21h





ret 
ENDP PrintFirstPlayer 


PrintSecondPlayer PROC


mov  dl, 70  ;Column
mov  dh, 19   ;Row
mov  bh, 0    ;Display page
mov  ah, 02h  ;SetCursorPosition
int  10h



mov ah,9
mov dx,offset player2name
int 21h

mov  dl, 70 ;Column
add dl,7
mov  dh, 19   ;Row
mov  bh, 0    ;Display page
mov  ah, 02h  ;SetCursorPosition
int  10h

mov ah,9
mov dx,offset comma
int 21h 

mov dx,offset player2score
int 21h








ret 
ENDP PrintSecondPlayer



PrintEscapeMessage PROC

mov  dl, 11  ;Column
mov  dh, 24   ;Row
mov  bh, 0    ;Display page
mov  ah, 02h  ;SetCursorPosition
int  10h





mov ah,9
mov dx,offset ESCMSSG
int 21h

RET
ENDP PrintEscapeMessage

    Clear_Ball_Redraw PROC near
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



;--------------------  DrawPBall
;When joining files remove clear screen
DRAW_BALL_HORIZONTAL PROC near
push cx
push dx
label1:
			MOV AH,0Ch ;set the configuration to writing a pixel
			MOV AL,0Fh ;choose black as color
			MOV BH,00h 
			INT 10h    
			
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


        add cx , BallVelocity_X ; Increment X and Y
        add dx , BallVelocity_Y 
        
        ;----------------------------------------------------------------

        jmp CHECK_Y

        
CHECK_Y:
        call CheckYBoundary_Ball
    
       exitdraw_horizontal:     ret

DRAW_BALL_HORIZONTAL ENDP


;; Draw Ball FUnction

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
           
           Ending: 
           pop dx
           pop cx
        
       

        add cx , BallVelocity_X ; Increment X and Y
        add dx , BallVelocity_Y 
       

CHECK_Y2:
        call CheckYBoundary_Ball
    
       exitdraw_horizontal2:  ret
endp draw_ball_image


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







