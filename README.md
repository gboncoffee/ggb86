# GGB86 - Gabriel's Good Bootloader for x86

Simple bootloader for x86 machines. Loads kernels from the boot disk set by the
BIOS to the `0x1000` address, switches to 32 bit protected mode and transfers
control to the kernel.

A dumb kernel is included for testing.

## Quickstart

You'll need the Netwide Assembler (NASM) and the GNU C toolchain (GCC, LD and
Make) to build. Also, your system needs a `cat` implementation in the `$PATH`.

Use `make` to create everything: the bootloader and the dumb kernel, with both
linked in the `os_image32.img` or `os_image64.img` file. The `bios_x86` or
`bios_x86_64` file is just the MBR boot sector (i.e., the bootloader itself) and
the `kernel32` or `kernel64` is just the compiled kernel.

The script `boot.sh` launches the image in a QEMU-KVM virtual machine.

## TODO

- Change to a more portable/generic assembler syntax.  
- Support to x86_64 and UEFI.  
- Slightly more sofisticated kernel that does not overwrite the bootloader
  messages.
