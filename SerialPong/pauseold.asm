

; Pause proc

; ;;initialing cursor
; mov ourcursor,1500h

; mov othercursor,1500h 
; add othercursor,18

; ;get a key from the in waiting mode User and if it is not ESC don't exit the Loop
; pushf
; call clearinputbuffer

; ;Print Pasue Message
; mov  dl, 17  ;Column
; mov  dh, 9   ;Row
; mov  bh, 0    ;Display page
; mov  ah, 02h  ;SetCursorPosition
; int  10h


; mov ah,9
; mov dx,offset PauseMess1
; int 21h
; ;Move to the Next Row to print another message
; mov  dl, 10  ;Column
; mov  dh, 10   ;Row
; mov  bh, 0    ;Display page
; mov  ah, 02h  ;SetCursorPosition
; int  10h

; mov ah,9
; mov dx,offset PauseMess2
; int 21h




; ;Print Last Pause Message
; mov  dl, 2  ;Column
; mov  dh, 11  ;Row
; mov  bh, 0    ;Display page
; mov  ah, 02h  ;SetCursorPosition
; int  10h

; mov ah,9
; mov dx,offset PauseMess3
; int 21h



; GetKeyUser:

; mov ah,1
; int 16h
; jz nokeyjustrecieve

; mov al,ah
; call clearinputbuffer

; ; check if the key is esc
; CheckIfPause:
; cmp ah,01h ;Ascii of esc
; jz exitPause
; cmp ah,3eh
; jz ResetApp


; mov chatbyte,al
; call sendingpause
; call receivingpause
; jmp GetKeyUser

; nokeyjustrecieve:push ax
; 				call receivingpause
; 				pop ax
; 				;  call RecieveGame
; 				CheckIfPause2:
; 				cmp chatbyte,01h ;Ascii of esc
; 				jz exitPausewithnosending
; 				cmp chatbyte,3eh
; 				jz resetappwithnosending
; ;the key is not esc return to the loop
; jmp GetKeyUser

; ResetApp:
; call SendingGame
; resetappwithnosending:
; mov ResetApplication , 1
; jmp exitPausewithnosending

; exitPause:
; call SendingGame
; exitPausewithnosending:
;   ;the user pressed Esc if true Exit the pause
; mov ax,0600h
; mov bh,00
; mov cx,0
; mov dx,184FH
; int 10h 



; call drawChatline
; call DrawPaddleLeft
; call DrawPaddleRight
; call PrintFirstPlayer
; call PrintSecondPlayer
; ;Draw the ball with no motion
; call draw_ball_withNoCollision
; ; ;Waiting for key Pressed

; popf
; ret
; endp Pause 
