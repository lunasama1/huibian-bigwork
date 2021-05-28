assume cs:codesg

codesg segment
start:mov ax,cs
mov ds,ax
mov si,offset jpk
mov ax,0
mov es,ax
mov di,200h
mov cx,offset jpkend-offset jpk
cld
rep movsb

mov word ptr es:[7ch*4],200h
mov word ptr es:[7ch*4+2],0

mov ax,0b800h
mov es,ax
mov di,160*12
mov bx,offset s-offset ok
mov cx,80
s:mov byte ptr es:[di],'!'
add di,2
dec cx
jcxz ok
int 7ch
ok:mov ax,4c00h
int 21h

jpk:push bp
mov bp,sp
add [bp+2],bx
pop bp
iret

jpkend:nop

mov ax,4c00h
int 21h

codesg ends

end start
