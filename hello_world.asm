extern GetStdHandle
extern ExitProcess
extern WriteFile
extern ReadFile

section .data
	msg db "Hello World!", 10, 13, 0
	input_size equ 100
	input_buffer times input_size db 0

section .bss
	bytes_in resd 1

section .text
global _main, print, input, bytes_in

;DOCUMENTATION
; print (string_terminating_in_0)
; input (buffer_in, buffer_size) - NOTE buffer actually needs to be 1 bigger to allow for terminating 0, and it must be an array of 0 bytes
;
;arguments are taken from last to first off the stack
_main:
	;push msg
	;call print

	push input_size
	push input_buffer
	call input

	push input_buffer
	call print

exit:
	push 0
	call ExitProcess

print:
	push ebp
	mov ebp, esp  ; where we're starting

	; we know the msg is in memory, and the address is passed in the call stack
	mov edx, [esp+8]		; start address of msg, 8 bytes past ebp which we do not want to touch until the end
	mov ecx, -1  ; counter for length

	loop:
		inc ecx
		cmp [edx + ecx], dword 0  ; compare char to 0
		jne loop

	; get stdout
	push -11
	call GetStdHandle  ; now it's in eax
	add esp, 4

	; write
	push dword 0 ; reserved??
	push dword 0 ; optional :)
	push ecx	; len
	push edx	; str
	push eax	; stdout
	call WriteFile

	mov esp, ebp
	pop ebp
	ret

input:
	push ebp
	mov ebp, esp

	mov ecx, [esp+8]		; max bytes - should be size of buffer
	mov edx, [esp+12]		; buffer in
	dec edx		; max bytes actually needs to be 1 less so we can ensure a terminating 0

	; get stdin
	push -10
	call GetStdHandle  ; now it's in eax
	add esp, 4

	push 0 ; you don't want this one
	push bytes_in; bytes read - send to bytes_in
	push edx	; max bytes
	push ecx	; buffer
	push eax	; stdin
	call ReadFile
	add esp, 20

	mov esp, ebp
	pop ebp
	ret
