# GGB86 - Gabriel's Good Bootloader for x86

Simple bootloader for x86 machines and the FAT 32 filesystem. Loads kernels from
the boot disk, from reserved FAT 32 sectors to the `0x1000` address, switches to
32 bit protected mode and transfers control to the kernel.

A dumb kernel is included for testing.

## Quickstart

You'll need the Netwide Assembler (NASM) and the GNU C toolchain (GCC, LD and
Make) to build. Also, your system needs a `cat` implementation in the `$PATH`.

Use `make` to create everything: the bootloader and the dumb kernel, with both
linked in the `os_image32.img` or `os_image64.img` file. The `bios_x86` or
`bios_x86_64` file is just the MBR boot sector (i.e., the bootloader itself) and
FAT boilerplate and the `kernel32` or `kernel64` is just the compiled kernel.

The script `boot.sh` launches the image in a QEMU-KVM virtual machine.

## How it works

The FAT filesystem itself has as header a `jmp` instruction so bootloaders keep
working (I don't know if they would be very useful otherwise...). So the first
sector of the disk image has the FAT stuff and the bootloader. In the FAT
metadata, 32 sectors are reserved, being the first three:

- First: FAT metadata and the bootloader;  
- Second: FSInfo struct of FAT 32;  
- Third: Reserved for the root directory.

The remaining 29 are reserved for the kernel, which could also be a second stage
bootloader. The entry of the kernel should of course be at the start of the
fourth sector, as the bootloader loads those 8 sectors to the address `0x1000`
and simply jumps there.

## TODO

- Change from NASM to GNU AS.
