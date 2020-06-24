extern print
extern input
extern exit

extern malloc
extern free
extern memcopy

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

	add rax, 16
	mov rcx, rax
	call print

	call exit


array:
.new:
	push rcx
	; rcx will contain size of new elements
	; SHOULD ONLY BE 1,2,4,8
	cmp rcx, 1
	je .good
	cmp rcx, 2
	je .good
	cmp rcx, 4
	je .good
	cmp rcx, 8
	je .good
	mov rax, 0
	ret
	.good:

	mov rcx, 16 ; 8+8 bytes for len and elem size
	sub rsp, 32
	call malloc
	add rsp, 32

	pop rcx

	mov qword [rax], qword 0  ; we are going to store the length of the array in the first byte
	mov qword [rax+8], qword rcx

	ret

.get:
	; rcx ptr
	; rdx index
	cmp rdx, [rcx]  ; not outside length bounds
	jl .good
	cmp rdx, 0
	jl .good
	mov rax, -1
	ret
	.good:
	mov r8, qword [rcx+8]
	mov rax, [rcx+16+r8*rdx]
	ret

.set:
	; rcx ptr
	; rdx index
	; r8 item
	cmp rdx, [rcx]  ; not outside length bounds
	jge .bad
	cmp rdx, 0
	jge .good
	.bad:
	mov rax, -1
	ret

	.good:
	mov r9, qword [rcx+8]

	cmp r9, 1
	je .size1
	cmp r9, 2
	je .size2
	cmp r9, 4
	je .size4
	cmp r9, 8
	je .size8

	mov rax, r8
	.size1:
		mov byte [rcx+16+1*rdx], byte al
	.size2:
		mov word [rcx+16+2*rdx], word ax
	.size4:
		mov dword [rcx+16+4*rdx], dword eax
	.size8:
		mov qword [rcx+16+8*rdx], qword rax

	ret

.append:
	push rbp
	mov rbp, rsp

	; rcx = ptr
	; rdx = item to push
	
	mov r9, qword [rcx+10q] ; elem size
	mov r8, r9		; +new elem
	mov rax, qword [rcx]  ; length in items
	push rdx
	mul r9			; multiply by item size
	pop rdx
	add r8, 16		; +we need to malloc 8+8 for real len
	add r8, rax		; +how long the array is in bytes without new elem		
	
	; RECAP
	; r9 = elem size
	; r8 = actual array size in bytes + new elem
	; rdx = new data to push
	; rcx = old array ptr

	push rcx
	mov rcx, r8
	sub r8, r9  ; r8 is actually ahead by one elem-size for the rest of our purposes, and now that it's in rcx for malloc, we can sub
	push r9
	push r8
	push rdx
	; rcx contains total bytes of new array, for malloc
	sub rsp, 32
	call malloc
	add rsp, 32

	; memcpy(*old, *new, size)
	; rcx needs old
	; rdx needs new
	; r8 needs size to copy, specifically of the old, which it should have?
	mov rcx, qword [rsp+30q]
	mov rdx, rax
	mov r8, qword [rsp+10q]
	push rax
	call memcopy
	pop rax
	pop rdx
	pop r8
	pop r9
	pop rcx

	; RECAP
	; r9 = elem size
	; r8 = actual array size in bytes + new elem size
	; rdx = new data to push
	; rcx = old array ptr
	; rax = new array ptr

	inc qword [rax]
	; increase recorded length by 1

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
		jmp .end
	.size2:
		mov word [rax + r8], word dx
		jmp .end
	.size4:
		mov dword [rax + r8], dword edx
		jmp .end
	.size8:
		mov qword [rax + r8], qword rdx
	.end:

	push rax
	sub rsp, 32
	call free
	add rsp, 32
	pop rax

	mov rsp, rbp
	pop rbp
	ret
