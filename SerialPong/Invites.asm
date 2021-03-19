.data 

f1message db 'press f1 to send an invite game                    $'
notification db 'You Got an invitation                           $'
joinmessage db '                                  $'
waitmessage db 'Waiting for the other user                       $'


.code


invitationMessages proc
pushf

;Get Player name
mov ax,0600h
mov bh,07
mov cx,0
mov dx,184fh
int 10h

mov ah,0 ;Change into Text mode
mov al,01h
int 10h

mov ah,2 ;Move Cursor To half screen
mov dl,3
mov dh,10
mov bh,00
int 10h

mov ah,9 ;PRINT enter name 1 at x=1 y=10
mov bl, 0bh ; color, eg bright blue in this case
mov cx, 35; number of chars
int 10h
mov dx,offset f1message
int 21h

popf
ret
endp invitationMessages

notificationMess proc
pushf

mov ah,0 ;Change into Text mode
mov al,01h
int 10h

mov ah,2 ;Move Cursor To half screen
mov dl,3
mov dh,13
mov bh,00
int 10h

mov ah,9 ;PRINT enter name 1 at x=1 y=10
mov bl, 0bh ; color, eg bright blue in this case
mov cx, 35; number of chars
int 10h
mov dx,offset notification
int 21h
mov ah,2 ;Move Cursor To X=26 Y=10
mov dl,3
mov dh,11
mov bh,00
int 10h
  
  mov ah,9 ;PRINT enter name 1 at x=1 y=10
mov bl, 0bh ; color, eg bright blue in this case
mov cx, 35; number of chars
int 10h
mov dx,offset joinmessage
int 21h

popf
ret
endp notificationMess 

WaitingMess proc
pushf

;Get Player name
mov ax,0600h
mov bh,07
mov cx,0
mov dx,184fh
int 10h

mov ah,0 ;Change into Text mode
mov al,01h
int 10h

mov ah,2 ;Move Cursor To half screen
mov dl,3
mov dh,10
mov bh,00
int 10h

mov ah,9 ;PRINT enter name 1 at x=1 y=10
mov bl, 0bh ; color, eg bright blue in this case
mov cx, 35; number of chars
int 10h
mov dx,offset waitmessage
int 21h

popf
ret
endp WaitingMess


