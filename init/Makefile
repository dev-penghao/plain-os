all:header.asm main.c
	nasm -f elf header.asm -o header.o
	gcc -c -m32 main.c -o main.o
	ld -s -Ttext 0x10800 -m elf_i386 header.o main.o -o init.o

clear:
	rm -f *.o
