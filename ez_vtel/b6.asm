include irvine32.inc 

str_reverse proto	, str1 : ptr byte , p : dword , p1 : dword

.data

msg1	byte "Nhap vao 1 chuoi : ",0
msg2	byte "Reverse String : ",0
buf1	byte	256 dup(0)
cnt		dword ?
cnt2	dword ?

.code
main proc
	mov edx , offset msg1
	call writestring

	mov edx , offset buf1 
	mov	ecx , sizeof buf1
	call readstring
	mov	cnt , eax
	mov edx , 0
	mov ecx , 2
	div	ecx
	mov	cnt2, eax
	; call by push
	push cnt
	push cnt2
	push offset buf1
	call str_reverse
	
	mov edx , offset msg2
	call writestring

	mov edx , offset buf1
	call writestring
	call crlf

	exit 
main endp

str_reverse proc	uses ecx eax ebx edx edi , str1 : ptr byte , p : dword , p1:dword
	mov	ecx , p
	mov edi,str1
	mov edx , 0
	mov	ebx , p1
	dec ebx
	L1:
		mov		al , [edi + edx]
		xchg	al , [edi + ebx]
		mov		[edi + edx] , al
		inc edx
		dec ebx
		loop l1

	ret
str_reverse endp

end main

//copy by shinxcrb