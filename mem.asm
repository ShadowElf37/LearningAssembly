extern GetProcessHeap
extern HeapAlloc
extern HeapFree

section .text
global malloc, calloc, free
export malloc
export calloc
export free

malloc:
	push ebp
	mov ebp, esp

	call GetProcessHeap

	mov ecx, [esp+8]  ; bytes to alloc

	push ecx
	push dword 0	; no flags
	push eax
	call HeapAlloc

	mov esp, ebp
	pop ebp
	ret

calloc:
	push ebp
	mov ebp, esp

	call GetProcessHeap

	mov ecx, [esp+8]  ; bytes to alloc

	push ecx
	push dword 8	; zero mem
	push eax
	call HeapAlloc

	mov esp, ebp
	pop ebp
	ret

free:
	push ebp
	mov ebp, esp

	call GetProcessHeap

	mov ecx, [esp+8]  ; addr to free

	push ecx
	push dword 0	; crash if there's a problem
	push eax
	call HeapFree

	mov esp, ebp
	pop ebp
	ret