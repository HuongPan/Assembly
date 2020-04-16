include irvine32.inc

fibo proto	, num1: dword , buf : ptr dword

.data

fib		dword 100	dup(0)
n		dword	?
msg1	byte	"Nhap vao so n : ",0
msg2	byte	"   " , 0
msg3	byte	"Solution : " , 0

.code
main proc
	mov	edx, offset msg1
	call writestring

	call readdec
	mov	 n , eax

	call crlf

	push offset fib
	push n
	call fibo

	mov edx , offset msg3
	call writestring

	mov	edi , offset fib
	mov	ecx , n
	mov	eax , 0
	mov	ebx , 0
	L2:
		mov	eax , [edi + ebx]
		call writedec

		mov edx , offset msg2
		call writestring

		add ebx , type fib
		loop L2

	exit
main endp

fibo proc	uses edi ebx ecx edx, num1: dword , buf : ptr dword
	local sz:dword
	mov	ebx , 1

	mov	edx , type buf
	mov	sz	, edx

	mov	edi , buf
	mov	[edi], ebx
	add edi , sz
	mov [edi], ebx
	add edi , sz


	mov	ecx , num1
	sub	ecx , 2

	L1:
		mov	ebx , edi
		sub ebx , sz
		mov	edx , [ebx]
		sub	ebx , sz
		add edx , [ebx]
		mov	[edi], edx
		add edi , sz
		loop L1
	ret
fibo endp

end main

//copy by shinxcrb