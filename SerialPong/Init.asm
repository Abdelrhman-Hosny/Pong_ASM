.code


SetPlayingVelocity PROC  ;New Proc added

;Has to be modified for when we adjust the serve to be from the losers side

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



SetInitialVelocities PROC  ; New Proc Added
    ; Sets the variables V45X , V30X  in order to use them at collision

    ;Possible Note : If this is only called before the program
    ; we can ignore pushing and popping of registers
    
    push ax


; Set the Y Velocity (will be constant and all the changes will happen in X)
;--------------------------------------------------------------------------
    mov ax , SpeedMode

    mov BallVelocity_Y , ax


; Set the Y Velocity in case of angle 45
;-----------------------------------------

    mov V45X , ax   ; Y = X 


;Set the X Velocity in case of angle 30
;--------------------------------------


    ; if Vy = 1  ,then Vx = 2
    ;since Vy is always = SpeedMode , then Vx = SpeedMode *2

    push bx 

                ;ax has speed mode
    mov bx , 2  ; so we multiply ax by 2 and put the result in V30X
    
    mul bl
    
    mov V30X , AX
    
    
    pop bx 
    pop ax

RET
ENDP SetInitialVelocities



IncrementPlayer1Score PROC
push ax
mov ax,1
mov LastScored,ax
inc player1score
call PrintFirstPlayer
pop ax
ret 
ENDP IncrementPlayer1Score



IncrementPlayer2Score PROC
push ax
mov ax,2
mov LastScored, ax
inc player2score
call PrintSecondPlayer
pop ax
ret 
ENDP IncrementPlayer2Score







