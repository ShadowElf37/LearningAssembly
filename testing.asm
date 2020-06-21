extern print
extern input
extern exit

extern malloc
extern realloc
extern free

%define STOFF(x) 8*x

;DOCUMENTATION
; new ( )
; append (*array, byte) - returns new array ptr
; get (*array, index) - returns byte in al
; set (*array, index, byte)
; join_arrays (*array1, *array2)
; from_buffer (*buffer, size)
;first arguments are read off the stack first

section .data
	string db 'Hello world!', 0
	len equ $-string

section .text
global _main

_main:
	mov rcx, 1
	call array.new

	mov rdx, 'a'
	mov rcx, rax
	call array.append

	mov rdx, 0
	mov rcx, rax
	call array.append

	mov rcx, rax
	call print

	call exit


array:
.new:
	mov rdx, rcx
	; rdx will contain size of new elements
	; SHOULD ONLY BE 1,2,4,8

	mov rcx, 2
	sub rsp, 4
	call malloc
	add rsp, 4

	mov qword [rax], qword 0  ; we are going to store the length of the array in the first byte
	mov qword [rax+8], qword rdx

	ret

.append:
	push rbp
	mov rbp, rsp

	; rcx = ptr
	; rdx = item to push
	push rdx
	
	mov r9, [rcx+8] ; elem size
	mov r8, r9
	add r8, 8		; we need to malloc 8 for real len and [r9] for new item
	mov rax, [rcx] ;  length in items
	mul r9			; multiply by item size
	add r8, rax	; how long the array is in bytes		
	
	push rax
	push r9
	push r8
	push rdx
	mov rdx, r8
	; rcx is already ptr, rdx is new len
	sub rsp, 4
	call realloc
	add rsp, 4
	pop r8
	pop r9
	pop rcx

	pop rdx

	sub r8, 8
	; quick recap:
	;  rax = new array
	;  rcx = new array len in items
	;  rdx = new item
	;  r8 = new array size in bytes
	;  r9 = elem size

	mov [rax], rcx

	; now we get that new and shiny array item
	cmp r9, 1
	je .size1
	cmp r9, 2
	je .size2
	cmp r9, 4
	je .size4
	cmp r9, 8
	je .size8

	.size1:
		mov byte [rax + r8], byte dl
	.size2:
		mov word [rax + r8], word dx
	.size4:
		mov dword [rax + r8], dword edx
	.size8:
		mov qword [rax + r8], qword rdx

	mov rsp, rbp
	pop rbp
	ret
