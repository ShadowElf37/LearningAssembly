BITS 64

extern GetStdHandle
extern ExitProcess
extern WriteFile
extern ReadFile

section .data
	msg db "Hello World!", 10, 13, 0
	input_size equ 100
	input_buffer times input_size db 0

section .bss
	_bytes_in resd 1
	_bytes_out resd 1

section .text

global print, input, exit, bytes_in
export print
export input
export exit

;DOCUMENTATION
; print (string_terminating_in_0)
; input (buffer_in, buffer_size) - NOTE buffer actually needs to be 1 bigger to allow for terminating 0, and it must be an array of 0 bytes
; exit  ( )
;arguments are taken from last to first off the stack

_main:
	and sp, 11110000b
	;mov rcx, msg
	;call print

	mov rdx, input_size
	mov rcx, input_buffer
	call input

	mov rcx, input_buffer
	call print

exit:
	mov rcx, 0
	call ExitProcess

print:
	; rcx is message ptr
	mov rdx, rcx
	; use r8 as counter for finding len of buffer
	or r8, -1

	_loop:
		inc r8
		cmp byte [rdx + r8], byte 0  ; compare char to 0
		jne _loop

	; get stdout
	mov rcx, -11  ; stdout
	sub rsp, 32 ; shadow space?
	call GetStdHandle  ; now it's in eax
	add rsp, 32

	; write
	mov r9, _bytes_out ; bytes written
	; r8 already holds len
	; rdx already holds ptr
	mov rcx, rax ; stdout
	sub rsp, 32
	call WriteFile
	add rsp, 32

	ret


input:
	; rcx buffer in
	; rdx max bytes - should be size of buffer
	dec rdx		; max bytes actually needs to be 1 less so we can ensure a terminating 0
	mov r8, rcx

	; get stdin
	mov rcx, -10
	sub rsp, 32
	call GetStdHandle  ; now it's in rax
	add rsp, 32

	; rdx has max bytes
	; r8 has buffer pointer
	; rax has stdin
	mov rcx, rax ; give rcx stdin
	mov r9, r8 ; give r9 the buffer temporarily
	mov r8, rdx ; give r8 the max bytes
	mov rdx, r9 ; give rdx the buffer

	mov r9, _bytes_in ; n bytes read
	; r8 has max bytes
	; rdx has buffer
	; rcx has stdin
	sub rsp, 32
	call ReadFile
	add rsp, 32

	ret