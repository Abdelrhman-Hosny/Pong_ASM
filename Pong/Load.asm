.Data

LoadW EQU 320
LoadH EQU 200


Filehandle DW ?

Data DB LoadW*LoadH dup(0)

.code
OpenFile PROC 

    ; Open file

    MOV AH, 3Dh
    MOV AL, 0 ; read only
    ;LEA DX, FileName ; comment as it will be taken from user as this control which file to reads
    INT 21h
    
    ; you should check carry flag to make sure it worked correctly
    ; carry = 0 -> successful , file handle -> AX
    ; carry = 1 -> failed , AX -> error code
     
    MOV [Filehandle], AX
    
    RET

OpenFile ENDP

ReadData PROC

    MOV AH,3Fh
    MOV BX, [Filehandle]
    MOV CX,LoadW*LoadH ; number of bytes to read
    LEA DX, Data
    INT 21h
    RET
ReadData ENDP 


CloseFile PROC
	MOV AH, 3Eh
	MOV BX, [Filehandle]

	INT 21h
	RET
CloseFile ENDP

DrawL PROC 
    MOV AH, 0
    MOV AL, 13h
    INT 10h
	
    CALL OpenFile
    CALL ReadData
	
    LEA BX , Data ; BL contains index at the current drawn pixel
    MOV CX,0
    MOV DX,0
    MOV AH,0ch
	
; Drawing loop
drawLoop:
    MOV AL,[BX]
    INT 10h 
    INC CX
    INC BX
    CMP CX,LoadW
JNE drawLoop 
	
    MOV CX , 0
    INC DX
    CMP DX , LoadH
JNE drawLoop


	mov ah,86h
    mov dx,7FFFh
    mov cx,10h
    int 15h

    
    call CloseFile
    
    ret
DrawL ENDP

