os_image.img: bios_x86 kernel
	cat $^ > $@

bios_x86: bios_x86.s
	nasm -f bin $^ -o $@

kernel: kernel_entry.o dumb_kernel.o
	ld -m elf_i386 -o $@ -Ttext 0x1000 $^ --oformat binary

kernel_entry.o: kernel_entry.s
	nasm -f elf32 $^ -o $@

dumb_kernel.o: dumb_kernel.c
	gcc -m32 -fno-pic -ffreestanding -c $^ -o $@

clean:
	-rm *.o os_image.img bios_x86 kernel
