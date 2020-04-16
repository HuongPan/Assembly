; nhập mảng tính tổng chẵn lẻ

include irvine32.inc

arrInp  proto	, mang: ptr dword , n1: dword 
evenSum	proto	, mang: ptr dword , n1: dword 
oddSum	proto	, mang: ptr dword , n1: dword 

.data

N_msg	byte	"Enter N : ",0
Arr_msg	byte	"Enter Array : ",0
ES_msg	byte	"Even Sum Solution : ",0
OS_msg	byte	"Odd Sum Solution :	",0
arr1	dword	100 dup(0)
n		dword	?
sum		dword	0

.code
main proc
	mov	edx , offset N_msg
	call writestring
	call readdec
	mov	n, eax

	mov	edx , offset Arr_msg
	call writestring 
	
	push n
	push offset arr1
	call ArrInp

	push n
	push offset arr1
	call evenSum

	mov edx , offset ES_msg
	call writestring
	call WriteDec

	call crlf

	push n
	push offset arr1
	call oddSum

	mov	edx , offset OS_msg
	call writestring 
	call writedec
	exit 
main endp

arrInp	proc uses ecx eax edi edx , mang: ptr dword , n1: dword 
	local sz : dword 

	mov	eax , type mang
	mov	sz	, eax
	mov	edi , mang
	mov	ecx , n1
	L1:
		call ReadDec
		mov	 [edi] , eax
		add	 edi , sz
		loop L1	
	ret
arrInp	endp

evenSum proc uses ecx edi ebx edx, mang: ptr dword , n1: dword 
	local sz:dword , Esum : dword 

	mov edx , 0
	mov	Esum , edx

	mov	ecx , type mang
	mov	sz	, ecx

	mov ecx , n1
	mov	edi , mang
	mov	ebx , 2

	L1:
		mov	edx , 0
		mov	eax , [edi]
		div	ebx
		cmp edx , 0
		jnz	quit
		mov	eax , [edi]
		add	eSum , eax
		quit:
		add edi , sz
		loop L1

	mov eax , Esum
	ret
evenSum	endp

oddSum proc uses ecx edi ebx edx, mang: ptr dword , n1: dword 
	local sz:dword , Osum : dword 

	mov edx , 0
	mov	Osum , edx

	mov	ecx , type mang
	mov	sz	, ecx

	mov ecx , n1
	mov	edi , mang
	mov	ebx , 2

	L1:
		mov	edx , 0
		mov	eax , [edi]
		div	ebx
		cmp edx , 0
		jz	quit
		mov	eax , [edi]
		add	oSum , eax
		quit:
		add edi , sz
		loop L1

	mov eax , Osum
	ret
oddSum	endp
end main

//copy by shinxcrb