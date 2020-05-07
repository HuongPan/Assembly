include irvine32.inc

.data

msg byte "Hello World!!!"

.code
main proc
	mov 	edx, offset msg
	call 	writestring
	exit
main endp
end main

//copy by shinxcrb