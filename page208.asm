assume cs:code

code segment
start:mov ax,4240h
mov dx,000fh
mov cx,0ah
call divdw

divdw:push ax
mov ax,dx
mov dx,0
div cx
mov bx,ax
pop ax
div cx
mov cx,dx
mov dx,bx
ret:
divdw ends

end start