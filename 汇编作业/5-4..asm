assume cs:codesg

codesg segment

mov ax,0h
mov ds,ax
mov bx,200h
mov cx,40h

s:mov [bx],bl
inc bx
loop s

mov ax,4c00H
int 21H

codesg ends

end