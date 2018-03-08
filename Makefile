

boot:boot.asm loader.asm kernel.asm
	nasm boot.asm -o boot.bin
	nasm loader.asm -o loader.bin
	nasm -f elf kernel.asm -o kernel.o
	ld -s -m elf_i386 kernel.o -o kernel.bin
	dd if=boot.bin of=a.img conv=notrunc
	dd if=loader.bin of=a.img seek=1 count=4 conv=notrunc
	dd if=kernel.bin of=a.img seek=5 conv=notrunc
