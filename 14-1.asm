assume cs:code

code segment
start:mov al,2
out 70h,al
in al,71h

mov ah,00000111b
add al,30h
mov cx,0b800h
mov es,cx
mov di,12*160
mov es:[di],ax

mov ax,4c00h
int 21h

code ends

end start