extern print
extern input
extern exit

extern malloc
extern free

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
	push len
	push string
	call array.from_buffer

	push eax
	call print

	call exit


array:
.new:
	push ebp
	mov ebp, esp

	push dword 1
	call malloc
	add esp, 4


	mov byte [eax], byte 0  ; we are going to store the length of the array in the first byte

	;push eax
	;call print


	mov esp, ebp
	pop ebp
	ret

.append:
	push ebp
	mov ebp, esp

	push ebx  ; we're gonna need ebx and it's non-volatile so we have to store it

	mov edx, [esp+12]		; pointer to array
	mov ebx, [esp+16]		; BYTE to push
	
	xor ecx, ecx
	mov cl, byte [edx]		; how long the array is so we can malloc 2 more - 1 for real len and 1 for new array
	add ecx, 2

	push edx
	push ecx			; new array len
	call malloc
	pop ecx
	pop edx
	; quick recap:
	;  eax = new array
	;  ebx = new byte
	;  ecx = new array len
	;  edx = old array
	

	dec ecx
	push ecx

	;debug
	mov esi, edx
	mov edi, eax
	rep movsb
	;debug
	; shreds through ecx, the old array len, to copy it over
	; note that ecx is technically correct even though it's one larger because of the initial len element

	push eax
	push edx
	call free
	pop edx
	pop eax

	pop ecx


	mov byte [eax], byte cl

	mov byte [eax + ecx], bl  ; that new and shiny array item, but ONLY ONE BYTE

	pop ebx  ; restore

	mov esp, ebp
	pop ebp
	ret

.get:
	push ebp
	mov ebp, esp

	xor eax, eax

	mov ecx, [esp+8] ; array ptr
	mov edx, [esp+12] ; pos
	mov al, byte [ecx+edx+1]

	mov esp, ebp
	pop ebp
	ret

.set:
	push ebp
	mov ebp, esp

	xor eax, eax

	mov ecx, [esp+8] ; array ptr
	mov edx, [esp+12] ; pos
	mov eax, [esp+16] ; byte to set
	mov [ecx+edx+1], byte al

	mov esp, ebp
	pop ebp
	ret

.join_arrays:
	push ebp
	mov ebp, esp

	push ebx  ; need it, ensure non-volatile

	mov ecx, [esp+12] ; a1 ptr
	mov edx, [esp+16] ; a2 ptr

	xor ebx, ebx
	mov bl, byte [ecx] ; size 1
	add bl, byte [edx] ; size 2
	; al now has total size

	push edx
	push ecx
	push ebx
	call malloc
	pop ebx
	pop ecx
	pop edx

	; RECAP
	; eax = new array
	; ebx = size
	; ecx = a1
	; edx = a2

	mov byte [eax], bl
	; new array has proper size recorded - ebx is free
	mov ebx, ecx		 ; now ebx has a1 ptr
	xor ecx, ecx
	mov cl, byte [ebx]  ; now ecx has len of array 1

	; copy a1
	inc ebx ; don't copy len
	inc eax ; don't copy len
	mov esi, ebx  
	mov edi, eax
	rep movsb  ; copy a1 to newa
	dec ebx

	mov cl, byte [edx] ; ecx has len(a2)
	; copy a2
	inc edx ; don't copy len of a2; eax already inc'd
	add al, byte [ebx] ; but we need to offset it by len(a1) because we already copied a1
	mov esi, edx
	mov edi, eax
	rep movsb

	; get back to byte 1 of new array
	sub al, byte [ebx]
	dec eax

	push eax
	push ebx
	push edx
	call free
	add esp, 4
	call free
	add esp, 4
	pop eax

	pop ebx ; restore non-volatile
	mov esp, ebp
	pop ebp
	ret

.from_buffer:
	push ebp
	mov ebp, esp
	
	mov edx, [esp+8]; ptr
	mov ecx, [esp+12] ; size

	push edx
	push ecx
	inc ecx
	call malloc
	pop ecx
	pop edx

	mov byte [eax], cl

	inc eax
	mov esi, edx
	mov edi, eax
	rep movsb

	mov esp, ebp
	pop ebp
	ret
