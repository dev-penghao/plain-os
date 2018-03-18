;	loader:1.将kernel加载到0x1080:0处
;	2.跳入保护模式
;	3.开启内存分页
;	4.跳入内核。因为将内核编译成了纯二进制的，所以不用做一个elf加载器而可以直接跳入执行
	;此时栈还是boot中用到的栈，seg=0x07c0,lim=1kb
;1.加载内核入内存
load_kernel:
	mov ax,0xb800
	mov gs,ax
	mov byte [gs:(80*1+0)*2],'G'
	mov byte [gs:(80*1+1)*2],'o'
	mov byte [gs:(80*1+2)*2],'!'
	mov dx,0x0000
	mov cx,0x0006
	mov ax,KERSEG
	mov es,ax	  ;es = ax = 0x1080
	xor bx,bx
	mov ax,0x200 + KERLEN	  ;AH - read, AL = sectors
	int 0x13
	jnc into_pro_mode
die:
	mov byte [gs:0x00],'D'
	mov byte [gs:0x02],'i'
	mov byte [gs:0x04],'e'
	mov byte [gs:0x06],'!'
	cli
	hlt	;中断已关，将不会再醒来

;2.完成加载内核入内存，我们开始进入保护模式
into_pro_mode:
	mov byte [gs:(80*2+0)*2],'O'
	mov byte [gs:(80*2+1)*2],'K'
	mov byte [gs:(80*2+2)*2],'!'

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
	jmp dword 0x0008:into_page_mode

;从此开始系统将在保护模式下运行
;页目录表位置:0x20000~0x21000
;页表位置:0x21000~0x22000
;3.设置页目录表，开启内存分页模式
into_page_mode:
	mov ax,10h
	mov gs,ax
	mov ah,0ch ; 0000: 黑底 1100: 红字
	mov al,'A'
	mov [gs:((80 * 0 + 39) * 2)],ax ;屏幕第0行, 第39列。
	;先清零要用到的内存区域
	mov ax,0x0018
	mov ds,ax
	mov ebx,0x20000
	mov ecx,0x800	;0x800*4=0x2000
clear_mem:
	mov dword [ds:ebx],0
	add bx,4
	loop clear_mem
	;清零完毕后只向页目录写第一个页目录项，因为之后的都用不到就不用设置
	mov ebx,0x20000
	mov dword [ds:ebx],0x00021003	;指向第一个页表地址0x21000
	;写页表，1024个页表项，每个页表项4个字节
	mov ebx,0x21000
	mov eax,0x3
	mov ecx,0x400
set_page_table:
	mov dword [ds:ebx],eax
	add eax,0x00001000
	add ebx,4
	loop set_page_table
	;页目录表和页表都已创建，下面先将页目录表的地址送给cr3，再将cr0的最高位置1真正开启分页模式
	mov eax,0x00020000
	mov cr3,eax
	mov eax,cr0
	or eax,1000_0000_0000_0000_0000_0000_0000_0000b
	mov cr0,eax
	mov ax,0x0010
	mov ds,ax
	mov bx,0
	mov ah,0x0c
	mov al,'K'
	jmp 0x0020:0

gdt:
	dd 0,0	;NULL!
	dd 0x0000ffff,0x00009a01 ;code seg=0x10000,lim=0xffff sel=0x0008 loader代码段
	dd 0x8000ffff,0x0000920b ;date seg=0xb800,lim=0xffff sel=0x0010 显存段
	dd 0x0000ffff,0x00cf9200 ;date seg=0,lim=4GB sel=0x0018 全局数据段
	dd 0x0800ffff,0x00cf9a01 ;code seg=0x10800,lim=1MB sel=0x0020 内核代码段
	dd 0x00007a00,0x00409600 ;task seg=0,lim=7a00 sel=0x0028 栈段

gdt_48: dw $-gdt-1	;gdt表描述符个数-1
	dd gdt+0x10000	;32位gdt基地址

BaseOfKernelFilePhyAddr equ 0x10800
KERSEG equ 0x1080
KERLEN equ 16
