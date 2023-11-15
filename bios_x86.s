bits 16
org 0x7c00

_start:
	mov [boot_drive], dl
	mov sp, 0x9000
	mov bp, sp

	; Enable a20.
	mov ax, 0x2401 
	int 0x15 
	mov ax, 0x2402 
	int 0x15 
	cmp al, 1
	jne a20_panic

	; Set video mode.
	mov ah, 0x0
	mov al, 0x3
	int 0x10

	; Clear the screen.
	mov ah, 0x6
	mov al, 0
	mov bh, 7
	mov ch, 0
	mov cl, 0
	mov dh, 24
	mov dl, 79
	int 10h

	; Move cursor to (0, 0).
	mov ah, 0x2
	mov dh, 0
	mov dl, 0
	mov bh, 0
	int 10h

	mov si, boot_entry_msg
	mov cx, BOOT_ENTRY_MSG_SIZE
	call print_string

	; Load the kernel from the disk.
	mov ah, 0x2
	mov al, 2
	mov cl, 0x2
	mov ch, 0x0
	mov dh, 0x0
	mov dl, [boot_drive]
	mov bx, KERNEL_ADDR
	int 13h
	jc disk_panic

	cmp al, 2
	jne sectors_panic

	call switch32

panic:
	jmp $

disk_panic:
	mov si, disk_panic_msg
	mov cx, DISK_PANIC_MSG_SIZE
	call print_string
	jmp panic

sectors_panic:
	mov si, sectors_panic_msg
	mov cx, SECTORS_PANIC_MSG_SIZE
	call print_string
	jmp panic

a20_panic:
	mov si, a20_panic_msg
	mov cx, A20_PANIC_MSG_SIZE
	call print_string
	jmp panic

; si = addr, cx = size
print_string:
	mov ah, 0xe
	mov al, [si]
	mov bl, 0
	int 10h

	inc si
	loop print_string
	ret

; Global Descriptor Table.
gdt_s:
	dq 0x0

gdt_c:
	dw 0xffff
	dw 0x0
	db 0x0
	db 10011010b
	db 11001111b
	db 0x0

gdt_d:
	dw 0xffff
	dw 0x0
	db 0x0
	db 10010010b
	db 11001111b
	db 0x0

gdt_e:

gdt_desc:
	dw gdt_e - gdt_s - 1
	dd gdt_s

CSEG equ gdt_c - gdt_s
DSEG equ gdt_d - gdt_s

switch32:
	cli
	lgdt [gdt_desc]
	mov eax, cr0
	or eax, 0x1
	mov cr0, eax
	jmp CSEG:init32

bits 32

init32:
	mov ax, DSEG
	mov ds, ax
	mov ss, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ebp, 0x90000
	mov esp, ebp
	call KERNEL_ADDR
	jmp $

bits 16

BOOT_ENTRY_MSG_SIZE equ 85
boot_entry_msg: db "GGB86 - Gabriel's Good Bootloader for x86", 13, 10, "Copyright (C) 2023 - Gabriel G. de Brito", 13, 10

DISK_PANIC_MSG_SIZE equ 57
disk_panic_msg: db "FATAL: could not read from the disk with BIOS services.", 13, 10

SECTORS_PANIC_MSG_SIZE equ 63
sectors_panic_msg: db "FATAL: could not read 2 sectors from disk with BIOS services.", 13, 10

A20_PANIC_MSG_SIZE equ 65
a20_panic_msg: db "FATAL: could not enable the a20 address port with BIOS services", 13, 10

KERNEL_ADDR equ 0x1000
boot_drive: db 0

; Padding and magic
times 510 - ($-$$) db 0
dw 0xaa55
