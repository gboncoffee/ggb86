; Extremelly sofisticated C runtime.
global _start
bits 32
extern main
_start: call main
jmp $