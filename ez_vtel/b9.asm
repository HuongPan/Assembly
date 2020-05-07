; nhập mảng tìm min max


include irvine32.inc

arrInp	proto , mang: ptr dword , n1: dword
min_max	proto , mang: ptr dword , n1: dword 

.data

Arr_msg	byte	"Enter array : ",0
arr1	dword	100 dup(0)
N_msg	byte	"Enter N :	",0
n		dword	?
mini	byte	"Min Solution : ",0
maxi	byte	"Max Solution : ",0

.code
main proc
	mov	edx , offset N_msg
	call writestring
	call ReadDec
	mov	 n , eax

	call crlf

	mov edx , offset Arr_msg
	call writestring
	call crlf

	push n
	push offset arr1
	call arrInp

	push n
	push offset arr1
	call min_max

	mov	edx , offset maxi
	call writestring 
	call WriteDec
	call crlf

	mov	edx , offset mini
	call writestring
	mov eax , ebx
	call writedec 
	call crlf

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

min_max	proc uses ecx edi edx, mang: ptr dword , n1: dword 
	local min:dword , max:dword , sz : dword 

	mov	ecx , type mang
	mov	sz	, ecx

	mov ecx , 0FFFFFFFh
	mov	min , ecx

	mov	ecx , 0
	mov	max , ecx

	mov	edi , mang
	mov	ecx , n1

	L1:
		mov	eax , [edi]
		cmp eax , min
		jae	C1
		mov	min	, eax
		jmp quit
		C1:
			cmp eax , max
			jbe	quit
			mov	max , eax
			jmp quit
		quit:
			add edi , sz
		loop L1
	
	mov	eax , max
	mov	ebx , min
	ret
min_max endp

end main

//copy by shinxcrb