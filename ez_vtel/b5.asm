;tim vi tri chuoi 1 xuat hien trong chuoi 2

include irvine32.inc

.data

msg1	byte	"Nhap chuoi 1 : ",0
msg2	byte	"Nhap chuoi 2 : ",0
msg3	byte	"Solution : "	,0
buf1	byte	100 dup(0)
cnt1	dword	?
buf2	byte	50	dup(0)
cnt2	dword	?
res		dword	?
tmp1	dword	0
.code
main proc

mov	edx, offset msg1
call writestring

mov	edx, offset buf1
mov	ecx, sizeof	buf1
call readstring
mov	cnt1, eax

mov	edx, offset msg2
call writestring

mov	edx, offset buf2
mov	ecx, sizeof	buf2
call readstring
mov	cnt2, eax

mov	edx, offset msg3
call writestring

mov edx , cnt2
dec edx

mov	ecx,cnt1
mov	edi , 0
mov	ebx , edi
mov	eax , esi
L1:
	mov	esi , 0
	mov	al , buf1[edi]
	cmp buf2[esi] , al
	jnz quit2
	mov	tmp1 , ecx
	mov ebx , edi
	mov ecx , cnt2
	L2:
		mov	al , buf1[ebx]
		cmp al , buf2[esi]
		jnz	quit2
		cmp esi , edx
		jnz	quit
		mov	eax , edi
		call writeint
		quit:
        inc esi
        inc ebx
		loop L2
	mov ecx , tmp1
	quit2:
    inc edi
	loop L1
	
exit
main endp

end main

//copy by shinxcrb