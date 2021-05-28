assume cs:code

code segment
start:mov ax,10h
mov bx,ax
mov cl,3
shl bx,cl
shl ax,1
add ax,bx
mov ax,4c00h
int 21h

code ends

end start