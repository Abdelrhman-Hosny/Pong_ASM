.code

; Variables

;Size 25

; 1
; X : 120 - 122
; Y1 : 20

;2
; X : 200 - 202
; Y2 : 155


InPortalRange PROC
    push ax 
    push bx
    push si

; Check ball is in X range of first portal
mov si , cx
mov ax , PortalLeftX ; X boundaries of first portal
mov bx , ax
add bx , 2
call IsBetween
jz CheckYFirstPortal
jmp CheckXSecondPortal

CheckYFirstPortal:
mov si , dx ; ball_y
mov ax , PortalLeftY ; Upper of First Portal
mov bx , ax ; Lower of first portal
sub ax , Ball_Size
add bx ,  portalsize

call IsBetween
jz CheckVelocity
jmp ExitInPortalRange


CheckXSecondPortal:
;si still has cx
mov ax , portalrightX
mov bx , ax
add bx , 2
call IsBetween

jz CheckYSecondPortal
jmp ExitInPortalRange

CheckYSecondPortal:

mov si , dx ; ball_y
mov ax , portalrightY ; Upper of First Portal

mov bx , ax ; Lower of first portal
sub ax , Ball_Size
add bx , portalsize

call IsBetween
jz CheckVelocity
jmp ExitInPortalRange

CheckVelocity:      cmp BallVelocity_X , 0
                    jg GoToRightPortal
 

GoToLeftPortal:
call Clear_Ball_Redraw
call draw_portals

mov cx , PortalLeftX
sub cx , Ball_Size
mov dx , PortalLeftY
add dx , 12

call draw_ball_withNoCollision

call SetPlayingVelocity

cmp BallVelocity_X , 0
jl ExitInPortalRange
neg BallVelocity_X
jmp ExitInPortalRange


GoToRightPortal:
call Clear_Ball_Redraw

call draw_portals
mov cx , portalrightX
add cx , 2
mov dx , portalrightY
ADD DX, 12
; We need a function to generate random velocity
; we also need to redraw ball and portal

call draw_ball_withNoCollision 

call SetPlayingVelocity

cmp BallVelocity_X , 0
jg ExitInPortalRange
neg BallVelocity_X
 
ExitInPortalRange:call draw_portals
pop si 
pop bx
pop ax
RET
ENDP InPortalRange

draw_portals PROC
;---------------------------------------------------------------------------

push cx 
push dx

mov ah,0ch
mov al,Colorportalright ; Draw Pixel Commad
mov Bl, portalsize

Mov cx,PortalLeftX
mov dx,PortalLeftY 

Draw3:
int 10h
inc CX
int 10h
inc cx
int 10h


inc dx ; draw next y point 
sub cx,2
dec bl; draw till paddle size
jnz Draw3


mov ah,0ch
mov al,Colorportalleft ; Draw Pixel Commad
mov Bl, portalsize

Mov cx,portalrightx
mov dx,portalrightY

Draw2:
int 10h
inc CX
int 10h
inc cx
int 10h

inc dx ; draw next y point 
sub cx,2
dec bl; draw till paddle size

jnz Draw2

pop dx
pop cx

ret
ENDP draw_portals

IsBetween PROC

; Checks SI whether a number is between ax and bx
; if true jz will cause jump

    cmp SI , ax
    jge SecondCompare
    jmp EndIsBetween

SecondCompare:   cmp SI , bx
                 jle TriggerZeroFlagIsBetn
                 jmp EndIsBetween

TriggerZeroFlagIsBetn: xor ax , ax
EndIsBetween: ret
ENDP IsBetween