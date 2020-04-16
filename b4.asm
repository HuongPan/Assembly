;;tinh tong 2 so

include irvine32.inc

.data

msg1	byte	"Nhap so nguyen 1 : ",0
msg2	byte	"Nhap so nguyen 2 : ",0
msg3	byte	"Tong 2 so la : ",0
int1	dword	?
int2	dword	?
sum		dword	?

.code
main proc

mov		edx , offset msg1
call	writestring 

call	readint
mov		int1 , eax

mov		edx , offset msg2
call	writestring 

call	readint
mov		int2 , eax

add		eax , int1
mov		sum , eax

mov		edx , offset msg3
call	writestring

call	writedec
call crlf

exit

main endp
end main

//copy by shinxcrb