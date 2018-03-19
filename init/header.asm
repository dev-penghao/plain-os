extern main

[section .text]	; 代码在此

global _start	; 导出 _start
global myprint

_start:	; 跳到这里来的时候，我们假设 gs 指向显存
	call main
	jmp	$	;main应该永远都不会退出，如果真的退出那就无限循环

myprint:
	mov	ah, 0Fh				; 0000: 黑底    1111: 白字
	mov	al, 'P'
	mov	[gs:0x08], ax	; 屏幕第 1 行, 第 39 列
	ret
