;;chuyen chuoi thuong thanh in hoa

include irvine32.inc

.data
	msg1	byte	"Nhap chuoi : ",0
	msg2	byte	"Chuoi in hoa : ",0
	buf1	byte	100 DUP(0)
	cntBuf	dword	?
.code
main PROC
	mov		edx, offset msg1
	call	writestring
	mov		edx, offset	buf1
	mov		ecx, sizeof buf1
	call	readstring
	mov		cntBuf,	eax
	mov		edx , offset msg2
	call	writestring
	mov		ecx , cntbuf
	mov		edi , offset buf1
	L1:
		mov	eax , [edi]
		sub	eax , 32
		mov	[edi] , eax
		add edi , type buf1
		loop L1

	mov	edx , offset buf1
	call writestring
	call crlf
	exit
main endp
end main

//copy by shinxcrb