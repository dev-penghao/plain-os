;	loader:1.将kernel加载到0x1080:0处
;	2.跳入保护模式
;	2.开启内存分页
;	4.跳入内核
start:
	mov ax,cs
	mov ds,ax	;ds=ax=0x1000
	;此时栈还是boot中用到的栈，seg=0x07c0,lim=1kb

;1.加载内核入内存
load_kernel:
	mov ax,0xb800
	mov ds,ax
	mov byte [ds:(80*1+0)*2],'G'
	mov byte [ds:(80*1+1)*2],'o'
	mov byte [ds:(80*1+2)*2],'!'
	mov dx,0x0000
	mov cx,0x0006
	mov ax,KERSEG
	mov es,ax	  ;es = ax = 0x1080
	xor bx,bx
	mov ax,0x200 + KERLEN	  ;AH - read, AL = sectors
	int 0x13
	jnc into_pro_mode
die:
	mov ax,0xb800
	mov ds,ax
	mov byte [ds:0x00],'D'
	mov byte [ds:0x02],'i'
	mov byte [ds:0x04],'e'
	mov byte [ds:0x06],'!'
	cli
	hlt	;中断已关，将不会再醒来

;2.完成加载内核入内存，我们开始进入保护模式
into_pro_mode:
	mov ax,0xb800
	mov ds,ax
	mov byte [ds:(80*2+0)*2],'O'
	mov byte [ds:(80*2+1)*2],'K'
	mov byte [ds:(80*2+2)*2],'!'

	mov ax,0x1000
	mov ds,ax
	lgdt [ds:gdt_48]

	;关中断
	cli

	;打开地址线A20
	in al, 92h
	or al, 00000010b
	out 92h, al

	;准备切换到保护模式
	mov eax, cr0
	or eax, 1
	mov cr0, eax

	;进入保护模式
	jmp dword 08h:setup_page_table

;从此开始系统将在保护模式下运行
;3.设置页目录表，开启内存分页模式
setup_page_table:
	mov ax,10h
	mov gs,ax
	mov ah,0ch ; 0000: 黑底 1100: 红字
	mov al,'A'
	mov [gs:((80 * 0 + 39) * 2)],ax ;屏幕第0行, 第39列。
	jmp $

gdt:
	dd 0,0	;NULL!
	dd 0x0000ffff,0x00009a01 ;code seg=0x10000,lim=0xffff
	dd 0x8000ffff,0x0000920b ;date seg=0xb800,lim=0xffff

gdt_48: dw $-gdt-1	;gdt表描述符个数-1
	dd gdt+0x10000	;32位gdt基地址

KERSEG equ 0x1080
KERLEN equ 16
