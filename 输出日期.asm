assume cs:code

data segment
db 9,8,7,4,2,0
data ends

code segment
start:mov cx,6
mov si,0
mov di,0
mov ax,data
mov ds,ax

s:push cx
mov al,byte ptr ds:[si]
out 70h,al
in al,71h

mov ah,al
mov cl,4
shr ah,cl
and al,00001111b

add ah,30h
add al,30h

mov bx,0b800h
mov es,bx
mov byte ptr es:[160*12+40*2+di],ah
mov byte ptr es:[160*12+40*2+2+di],al
inc si
add di,4
pop cx
cmp cx,5;判断是否需要输出'/'
jnb print
cmp cx,4;判断是否需要输出空格
je prints
cmp cx,2;判断是否需要输出':'
jnb printt
loop s

mov ax,4c00h
int 21h

print:mov byte ptr es:[160*12+40*2+di],'/'
add di,2
dec cx
jmp s

prints:mov byte ptr es:[160*12+40*2+di],' '
add di,2
dec cx
jmp s

printt:mov byte ptr es:[160*12+40*2+di],':'
add di,2
dec cx
jmp s

code ends

end start