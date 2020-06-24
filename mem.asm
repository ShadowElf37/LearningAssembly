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

	cmp r8, 8
	jl .just_resolve_odd_bound

	xor rdx, rdx
	mov rax, r8
	mov r9, 8
	div r9

	; rdx has remainder
	; movsq until we hit the odd bound, so for all rax

	mov rcx, rax
	rep movsq

	jmp .resolve_odd_bound
	.just_resolve_odd_bound:
		mov rcx, r8
		jmp .copy_odd_bound
	.resolve_odd_bound:
		mov rcx, rdx
	.copy_odd_bound:
		; now we'll just movsb the rest of it
		rep movsb
	ret