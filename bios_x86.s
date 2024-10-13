bits 16
org 0x7c00

_start:
	jmp after_fat
	nop
	db "ggb86fat"
bytes_per_sector:
	dw 512
sectors_per_cluster:
	db 1
reserved_sectors:
	; We use 2 sectors for the FAT 32 signature + boot loader itself, and
	; another one for the root directory. So the kernel has 29 sectors for
	; it's code. The "kernel" may be a second stage bootloader of course.
	dw 32
fats:
	db 1
root_entries:
	dw 0
sectors:
	dw 32
media_descriptor_type:
	db 0xff
sectors_per_fat:
	; This is not used as we're FAT 32.
	dw 0
sectors_per_track:
	dw 0
heads:
	dw 0
hidden_sectors:
	dw 0
large_sectors:
	dd 0
; Fun game: guess how much of the numbers above are actually true. Me when I
; design a filesystem that describes the physical media layout and
; intrinsic characteristics of the underlying device.

; Here begins FAT-32 specific info.
sectors_per_fat_32:
	dd 1
fat_flags:
	dw 0
fat_version_number:
	db 0	; Minor
	db 0	; Major
root_cluster:
	dd 2
fsinfo_sector:
	dw 1
backup_sector:
	; Yeah we got no backup. Actually I don't know if somethings breaks with
	; this.
	dw 0
fat_reserved:
	times 12 db 0
drive_number:
	db 0x80
windows_nt_flags:
	db 0
fat_signature:
	db 0x29
volume_id_serial_number:
	dd 0
volume_label:
	db "GGB86 Bootl"
system_identifier:
	db "FAT32   "

after_fat:
	mov [boot_drive], dl
	mov sp, 0x9000
	mov bp, sp

	; Enable a20.
	mov ax, 0x2401
	int 0x15
	mov ax, 0x2402
	int 0x15
	cmp al, 1
	jne panic

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

	; Load the kernel from the disk. We load all the 8 kernel sectors.
	;
	; We're going to use LBA extensions because I'm without patience and
	; everyone since the 90s supports that. Yeah we don't support floppys.
	mov ah, 0x42
	mov si, disk_address_packet
	mov dl, [boot_drive]
	int 13h

	jc panic

	call switch32

panic:
	mov si, panic_msg
	mov cx, PANIC_MSG_SIZE
	call print_string
	jmp $

; si = addr, cx = size
print_string:
	mov ah, 0xe
	mov al, [si]
	mov bl, 0
	int 10h

	inc si
	loop print_string
	ret

align 4
; Disk address packet for loading the kernel.
disk_address_packet:
	db 0x10
	db 0
	dw 29
	dw KERNEL_ADDR
	dw 0
	dd 3
	dd 0

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
PANIC_MSG_SIZE equ 26
panic_msg: db "Fatal boot error, halting."
KERNEL_ADDR equ 0x1000
boot_drive: db 0

; Padding and magic
times 510 - ($-$$) db 0
dw 0xaa55

; Here ended the first sector. Now we got to make the FSInfo for FAT 32.

; Magic.
lead_signature:
	dd 0x41615252

; Tfk? Wasted space?
fsinfo_reserved:
	times 480 db 0

; Also magic.
fsinfo_signature:
	dd 0x61417272

; This means "we don't know". Hint for the driver.
last_known_free_cluster:
	dd -1

; Also a hint for the driver meaning "we don't know".
available_clusters:
	dd -1

; ???
fsinfo_reserved_again:
	times 12 db 0

; Magic again.
trail_signature:
	dd 0xAA550000

; To keep the kernel after the root directory, we add a zeroed sector for it.

times 512 db 0
