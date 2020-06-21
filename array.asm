
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
