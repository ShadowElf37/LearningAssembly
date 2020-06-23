extern malloc
extern free

section .text
global memcopy
export memcopy


memcopy:
	; r8 copy size
	; rdx ptr new
	; rcx ptr old

	mov rdi, rdx
	mov rsi, rcx
	mov rcx, r8

	rep movsb
	ret

_realloc:
	; rdx size
	; rcx ptr

	push rbp
	mov rbp, rsp

	mov rsi, rcx
	mov rcx, rdx

	push rcx
	sub rsp, 32
	call malloc
	add rsp, 32
	pop rcx

	mov rdi, rax
	; rsi now has old loc ptr
	; rdi now has new loc ptr
	; rcx got the mem size in bytes from rdx

	; optimize the memcopy so it can copy in increments aligned with the memory boundary
	mov rdx, rcx
	test dl, 11111110b
	jz .mb
	test dl, 11111101b
	jz .mw
	test dl, 11111011b
	jz .md
	test dl, 11110111b
	jz .mq

	; it is guaranteed that no information is destroyed in the bitshifts
	.mb:
		rep movsb
		jmp .end
	.mw:
		shr rcx, 1
		rep movsw
		shl rcx, 1
		jmp .end
	.md:
		shr rcx, 2
		rep movsd
		shl rcx, 2
		jmp .end
	.mq:
		shr rcx, 4
		rep movsq
		shl rcx, 4
		jmp .end
	.end:

	push rax
	sub rsi, rdx  ; rsi gets offset by rdx as mov happens
	mov rcx, rsi
	sub rsp, 32
	call free
	add rsp, 32
	pop rax

	mov rsp, rbp
	pop rbp
	ret