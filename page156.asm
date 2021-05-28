mov ax,datasg
mov ds,ax
mov bx,0

s0:mov dx,cx
mov si,0
mov cx,3

s:mov al,[bx+si]
and al,11011111B
mov [bx+si],al
inc si
loop s

add bx,16
mov cx,dx

loop s0