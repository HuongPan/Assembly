// cong hai so nguyen lon

include irvine32.inc

str_reverse proto	, str1 : ptr byte , strlenn :dword

.data

int1	byte	21 dup(0)
int2	byte	21 dup(0)
cnt1	dword   ?
cnt2	dword   ?
sum		byte	23 dup(0)
extra	byte	0
msg1	byte	"Nhap 1 so nguyen : ",0
msg2    byte    "Solution : ",0

.code
main proc
; nhap so thu 1
	mov	edx , offset msg1
	call writestring 

	mov	edx , offset int1
	mov ecx , sizeof int1
	call readstring
	mov	 cnt1 , eax

;reverse int1
	push cnt1
	push offset int1
	call str_reverse

	mov	edx, offset int1
	call writestring 
	call crlf

;nhap so thu 2
	mov	edx , offset msg1
	call writestring 

	mov	edx , offset int2
	mov ecx , sizeof int2
	call readstring
	mov	 cnt2 , eax

;reverse int2
	push cnt2
	push offset int2
	call str_reverse

	mov	edx, offset int2
	call writestring 
	call crlf

;bat dau cong : set ecx = độ dài chuỗi lớn hơn , xóa enter ở chuỗi ngắn hơn
	mov ebx , 0
	mov eax , cnt1
	cmp eax , cnt2
	ja  c1
		mov	ecx , cnt2
		mov edi , offset int1
		add edi , cnt1
		add edi , 1
		mov [edi], ebx
		jmp continue
	c1:
		mov	ecx , cnt1
		mov edi , offset int2
		add edi , cnt2
		add edi , 1
		mov [edi], ebx
	continue:

	mov edi , 0
	mov esi , 0
	mov	bl  , 10
	L1:								; loop cộng 
		mov eax , 0					
		mov al , int1[edi]
		cmp al , '0'
		jb  con1
		sub al , '0'
		con1:
		mov dl , int2[edi]
		cmp	dl , 0
		jz	con2
		sub dl , '0'
		con2:
		add al , dl
		add al , extra
		div bl
		mov extra , al
		add ah , '0'
		mov	sum[edi] , ah
		inc edi
		loop L1
; cộng số dư cuối cùng
	mov al, extra
	cmp al , 0
	jz	Continuee
	add al , '0'
	mov sum[edi] , al
	inc edi

	Continuee:
	push edi
	push offset sum
	call str_reverse

    mov edx , offset msg2
    call writestring

	mov edx , offset sum
	call writestring 
	call crlf

	exit
main endp


str_reverse proc	uses ecx eax ebx edx edi , str1 : ptr byte , strlenn :dword

	mov	eax , strlenn
	cmp eax , 1
	jz  quit
	mov edx , 0
	mov	ecx , 2
	div ecx
	mov	ecx , eax

	mov	edi , str1
	mov	edx , 0
	mov	ebx , strlenn
	dec ebx
	L1:
		mov		al , [edi + edx]
		xchg	al , [edi + ebx]
		mov		[edi + edx] , al
		inc edx
		dec ebx
		loop l1
	quit:
	ret
str_reverse endp

end main
