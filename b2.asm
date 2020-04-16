include irvine32.inc 

.data
	buf		byte	100 DUP(?),0
	cntBuf	byte	?
	msg		byte	"so ki tu da nhap: "
.code
main PROC
	mov 	edx , OFFSET buf
	mov		ecx , sizeof buf
	call 	READSTRING
	mov		edx , offset msg
	call 	writestring
	call 	writedec
	call 	crlf
	mov 	edx , offset buf
	call 	WRITESTRING
	call crlf
	exit
main endp
end main

//copy by shinxcrb