%include "pm.inc"

extern main

[section .text]	; 代码在此

global _start	; 导出 _start
global hlt, put_string, clean_screen
_start:	; 跳到这里来的时候，我们假设 gs 指向显存
	lgdt [ds:gdt_48]
	jmp dword 0x10:entry-0x10800
entry:
	mov ax,0x0008
	mov ds,ax
	mov es,ax
	mov fs,ax
	mov ax,0x0020
	mov gs,ax
	mov ax,0x18
	mov ss,ax
	mov esp,0x7c00

	call set_idt

	call main

	;push dword text1
	;call put_string

	int 0x80

	jmp $

set_idt:
	cli
	lidt [ds:idt_48]
	call init8259A
	sti
	ret

init8259A:
	mov al,0x11
	out 0x20,al
	call io_delay

	out 0xa0,al
	call io_delay

	mov al,0x20
	out 0x21,al
	call io_delay

	mov al,0x28
	out 0xa1,al
	call io_delay

	mov al,0x04
	out 0x21,al
	call io_delay

	mov al,0x02
	out 0xa1,al
	call io_delay

	mov al,0x01
	out 0x21,al
	call io_delay

	out 0xa1,al
	call io_delay

	mov al,1111_1110b
	out 0x21,al
	call io_delay

	mov al,1111_1111b
	out 0xa1,al
	call io_delay

	ret

io_delay:
	nop
	nop
	nop
	nop
	ret

clean_screen:
	mov ah,0x07
	mov al,0x0
	mov bx,0
	mov ecx,80*24
.clean_char:
	mov [gs:bx],ax
	add bx,2
	loop .clean_char
	ret

put_string:                              ;显示串(0结尾)。
	mov ebx,[esp+4]
put_entry:                                        ;输入：DS:BX=串地址
         mov cl,[ds:ebx]
         or cl,cl                        ;cl=0 ?
         jz .exit                        ;是的，返回主程序 
         call put_char
         inc bx                          ;下一个字符 
         jmp put_entry

   .exit:
         ret

;-------------------------------------------------------------------------------
put_char:                                ;显示一个字符
                                         ;输入：cl=字符ascii
         push ax
         push bx
         push cx
         push dx
         push ds
         push es

         ;以下取当前光标位置
         mov dx,0x3d4
         mov al,0x0e
         out dx,al
         mov dx,0x3d5
         in al,dx                        ;高8位 
         mov ah,al

         mov dx,0x3d4
         mov al,0x0f
         out dx,al
         mov dx,0x3d5
         in al,dx                        ;低8位 
         mov bx,ax                       ;BX=代表光标位置的16位数

         cmp cl,0x0d                     ;回车符？
         jnz .put_0a                     ;不是。看看是不是换行等字符 
         mov ax,bx                       ;此句略显多余，但去掉后还得改书，麻烦 
         mov bl,80                       
         div bl
         mul bl
         mov bx,ax
         jmp .set_cursor

 .put_0a:
         cmp cl,0x0a                     ;换行符？
         jnz .put_other                  ;不是，那就正常显示字符 
         add ebx,80
         jmp .roll_screen

 .put_other:                             ;正常显示字符
         shl bx,1
         mov [gs:bx],cl

         ;以下将光标位置推进一个字符
         shr bx,1
         add bx,1

 .roll_screen:
         cmp bx,2000                     ;光标超出屏幕？滚屏
         jl .set_cursor

         mov ax,0xb800
         mov ds,ax
         mov es,ax
         cld
         mov si,0xa0
         mov di,0x00
         mov cx,1920
         rep movsw
         mov bx,3840                     ;清除屏幕最底一行
         mov cx,80
 .cls:
         mov word[es:bx],0x0720
         add bx,2
         loop .cls

         mov bx,1920

 .set_cursor:
         mov dx,0x3d4
         mov al,0x0e
         out dx,al
         mov dx,0x3d5
         mov al,bh
         out dx,al
         mov dx,0x3d4
         mov al,0x0f
         out dx,al
         mov dx,0x3d5
         mov al,bl
         out dx,al

         pop es
         pop ds
         pop dx
         pop cx
         pop bx
         pop ax

         ret


hlt:
	hlt
	ret

_intruppt:
intruppt equ _intruppt-$$
	mov ah,0x0c
	mov al,'!'
	mov [gs:0],ax
	iretd

_time:
time equ _time-$$
	inc byte [gs:0]
	mov al,0x20
	out 0x20,al
	iretd

gdt:
	dd 0,0	;NULL!
	Descriptor 0x00000, 0xfffff,DA_DRW|DA_32	;全局数据段,0x08
	Descriptor 0x10800, 0x0ffff, DA_CR|DA_32	;内核代码段,0x10
	Descriptor 0x00000, 0x07a00, DA_DRWL|DA_32	;内核栈段,0x18
	Descriptor 0B8000h, 0x0ffff, DA_DRW|DA_DPL0	; 显存首地址,0x20

gdt_48:
	dw $-gdt-1	;gdt表描述符个数-1
	dd gdt	;32位gdt基地址

idt:
	%rep 32
		Gate 0x0010,intruppt,0,DA_386IGate
	%endrep
	.0x20:	Gate 0x0010,time,0,DA_386IGate
	%rep 223
		Gate 0x0010,intruppt,0,DA_386IGate
	%endrep

idt_48:
	dw $-idt-1
	dd idt

text1: db "Eello world!",0
