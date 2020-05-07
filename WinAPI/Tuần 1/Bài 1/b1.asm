.386
.model flat,stdcall

include windows.inc
include kernel32.inc
include user32.inc

includelib	kernel32.lib
includelib	user32.lib

str_reverse proto	, str1 : ptr byte , strlenn :dword
splitSTR proto , target: ptr byte

.data
hFile	HANDLE		?
msgF	db			"Failed !!!",0
n1msg	db			"num1",0
cnt		dw			0,0,0
buf		db			1000 dup(0)
num1	db			100 dup(0)
len1	dw			0,0
num2	db			100 dup(0)
sum		db			110 dup(0)
lenS	dw			0,0
len2	dw 			0,0
nameI	db			"in.txt",0
nameO	db			"out.txt",0
tmp 	db			0,0
.code
start:
	invoke CreateFile,addr nameI,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
	mov	hFile , eax
	cmp eax, INVALID_HANDLE_VALUE
	jnz Continue
	invoke MessageBox,NULL,addr msgF,addr msgF,MB_OK
	jmp quit
	
Continue:
	invoke ReadFile,hFile,addr buf,200,addr cnt,NULL
	invoke MessageBox,NULL, addr buf,0,MB_OK

	mov edi, offset buf
	invoke splitSTR,addr num1
	mov len1, ax
	invoke MessageBox,NULL,addr num1, addr n1msg,MB_OK
	invoke str_reverse,addr num1, len1
	invoke MessageBox,NULL,addr num1, addr n1msg,MB_OK
	
	inc edi ; bo qua dau cac
	invoke splitSTR,addr num2
	mov len2, ax
	invoke MessageBox,NULL,addr num2, addr n1msg,MB_OK
	invoke str_reverse,addr num2, len2
	invoke MessageBox,NULL,addr num2, addr n1msg,MB_OK
	
	;resize,xoa dau enter
	mov ecx,0
	mov ebx , 0
	mov ax , len1
	cmp ax , len2
	ja c1
		mov cx, len2
		mov edi, offset num1
		add di, len1
		add di, 1
		mov [edi], bl
		jmp Continue2
	c1:
		mov cx, len1
		mov edi, offset num2
		add di, len2
		add di, 1
		mov [edi], bl
	; cong 2 so
Continue2:
	mov edi,0
	mov esi,0
	mov bl,10
	Lxx:
		mov eax , 0
		mov al, num1[edi]
		cmp al,'0'
		jb con1
		sub al,'0'
	con1:
		mov dl, num2[edi]
		cmp dl,0
		jz con2
		sub dl,'0'
	con2:
		add al,dl
		add al,tmp
		div bl
		mov tmp,al
		add ah,'0'
		mov sum[edi], ah
		inc edi
		loop Lxx
	;so du cuoi	
	mov al,tmp
	cmp al, 0
	jz Continue3
	add al,'0'
	mov sum[edi],al
	inc edi
Continue3:
	mov lenS,di
	invoke str_reverse,addr sum, lenS
	invoke MessageBox,NULL,addr sum,0,MB_OK
	;ghi file
	invoke CreateFile,addr nameO,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
	mov hFile , eax
	cmp eax,INVALID_HANDLE_VALUE
	jnz Continue4
	invoke MessageBox,NULL,addr msgF,addr msgF,MB_OK
	jmp quit
Continue4:
	invoke WriteFile,hFile,addr sum,99,addr cnt,NULL
quit:
	invoke ExitProcess,NULL
	
	splitSTR proc uses ebx ecx edx esi , target: ptr byte
	; input: edi = dia chi buf
	; return eax = length target
		mov bl,20h
		mov bh,0
		mov eax,0
		mov ecx,1000
		mov esi,target
	Lx:
		mov dl, [edi]
		mov [esi],dl
		inc ax
		inc edi
		inc esi
		cmp [edi], bl
		jz outt
		cmp [edi], bh
		jz outt
		loop Lx
	outt:
		ret

	splitSTR endp
	str_reverse proc	uses ecx eax ebx edx edi , str1 : ptr byte , strlenn :dword

	mov	eax , strlenn
	cmp eax , 1
	jz  outproc
	mov edx , 0
	mov	ecx , 2
	div ecx
	mov	ecx , eax

	mov	edi , str1
	mov	edx , 0
	mov	ebx , strlenn
	dec ebx
L1:
	mov al , [edi + edx]
	xchg al, [edi + ebx]
	mov [edi + edx], al
	inc edx
	dec ebx
	loop L1
	outproc:
	ret
str_reverse endp

end start