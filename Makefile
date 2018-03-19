all:boot/boot.bin init/init.o image


boot/boot.bin:boot/boot.asm boot/loader.asm
	nasm boot/boot.asm -o boot/boot.bin
	nasm boot/loader.asm -o boot/loader.bin

init/init.o:
	make -C init

image:
	objcopy -O binary -R .note -R .comment  init/init.o system.bin
	dd if=boot/boot.bin of=a.img conv=notrunc
	dd if=boot/loader.bin of=a.img seek=1 count=4 conv=notrunc
	dd if=system.bin of=a.img seek=5 conv=notrunc
	
clear:
	rm -f boot/*.bin
	make clear -C init/
