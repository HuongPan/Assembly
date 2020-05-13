.386
.model flat,stdcall

include windows.inc
include	user32.inc
include kernel32.inc

includelib	kernel32.lib
includelib	user32.lib
appendSTR proto , str2:ptr byte , str_t :ptr byte
str_len proto, str1: ptr byte
cut_str proto, str_1:ptr byte , str_c :ptr byte 
FindFile proto, temp: ptr byte
del_str proto, str_del : ptr byte
strcpy proto , cpy1:ptr byte , cpy2: ptr byte
remove_until proto , rm:ptr byte
.data

find 	HANDLE 	?
hFile 	HANDLE 	?	
cnt		DWORD		3 dup(0)
path	DB		5000 dup(0)
tail	DB		"\*",0
tail2	DB		"*",0
msgF	DB		"Failed !!!",0

nameF	DB		"in.txt",0
nameO	DB		"out.txt",0
nul		DB		10,0,0

res		WIN32_FIND_DATA <>
check 	BOOL	TRUE

tmp 	DB		5000 dup(0)
tmp2	DB		5000 dup(0)
.code

start:
	invoke CreateFile,addr nameF,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
	mov hFile, eax
	cmp eax, INVALID_HANDLE_VALUE
	jnz Continue
	invoke MessageBox,NULL,addr msgF, addr msgF,MB_OK
	jmp quit
Continue:
	xor eax , eax
	invoke ReadFile,hFile,addr path,200,addr cnt,NULL
	
	invoke CreateFile,addr nameO, GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
	mov hFile , eax
	cmp eax, INVALID_HANDLE_VALUE
	jnz Continue2
	invoke MessageBox, NULL, addr msgF,addr msgF ,MB_OK
	jmp quit
Continue2:
	invoke FindFile, addr path
quit:
	invoke ExitProcess,NULL

FindFile proc dir : ptr byte
LOCAL finddata: WIN32_FIND_DATA
LOCAL FHandle : DWORD 
	invoke del_str,addr tmp
	invoke appendSTR,dir, addr tmp
	invoke appendSTR,addr tail, addr tmp
	;invoke MessageBox,NULL, addr tmp, 0,MB_OK
	
	invoke FindFirstFile, addr tmp, addr finddata
	.if eax != INVALID_HANDLE_VALUE
		mov FHandle , eax
		invoke cut_str,addr tail2,addr tmp
		.while eax != 0
			.if finddata.cFileName == "."
				jmp xx
			.endif
			invoke appendSTR,addr finddata.cFileName , addr tmp
			;invoke MessageBox,NULL,addr tmp,0,MB_OK
			invoke WriteFile,hFile,addr tmp,200,addr cnt,NULL
			invoke WriteFile,hFile,addr nul,1,addr cnt,NULL
			invoke del_str,addr tmp2
			invoke strcpy,addr tmp, addr tmp2
			invoke FindFile,addr tmp2
			invoke cut_str,addr tail , addr tmp
			invoke remove_until,addr tmp
			xx:
			invoke FindNextFile,FHandle,addr finddata
		.endw
		;invoke MessageBox,NULL, addr tail, addr tail, MB_OK
		invoke FindClose,FHandle
	.endif
	outF:
	ret

FindFile endp

strcpy proc uses eax ecx esi edi , cpy1:ptr byte , cpy2: ptr byte
	; copy cpy1 => cpy2
	mov edi, cpy1
	mov esi, cpy2
	invoke str_len,cpy1
	mov ecx , eax
	LC:
		mov al,[edi]
		mov [esi],al
		inc edi
		inc esi
		loop LC
	ret

strcpy endp

del_str proc uses ecx edi ebx, str_del : ptr byte
	mov ecx , 200
	xor ebx, ebx
	mov edi,str_del
	LD:
		mov [edi], bl
		inc edi
		loop LD
	ret

del_str endp
	
appendSTR proc uses eax ebx ecx esi , str2:ptr byte , str_t :ptr byte
	mov edi , str_t
	invoke str_len,str_t
	add edi , eax
	invoke str_len,str2
	mov ecx, eax
	mov esi , str2
	L1:
		mov al, [esi]
		mov [edi] , al
		inc edi
		inc esi
		loop L1
	ret

appendSTR endp

cut_str proc uses eax ebx ecx esi , str_1:ptr byte , str_c :ptr byte
	mov edi , str_c
	invoke str_len,str_c
	add edi , eax
	invoke str_len,str_1
	mov ecx , eax
	inc ecx
	xor ebx , ebx
	L3:
		mov [edi], bl
		dec edi
		loop L3
	ret

cut_str endp

str_len proc uses edi ebx, str1: ptr byte
	xor eax , eax
	mov edi, str1
	L2:
		mov bl, [edi]
		cmp bl, 0
		jz outt
		inc eax
		inc edi
		loop L2
	outt:
	ret

str_len endp

remove_until proc uses eax ebx ecx edi , rm:ptr byte
	mov edi , rm
	invoke str_len,rm
	mov ecx , eax
	add edi,eax
	xor eax, eax
	LR:
		mov ah,[edi]
		cmp ah,'\'
		jz outR
		mov [edi],al
		dec edi
		loop LR
	outR:
	ret

remove_until endp
end start
