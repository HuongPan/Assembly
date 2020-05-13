.386
.model flat, stdcall

include windows.inc
include user32.inc
include kernel32.inc

includelib kernel32.lib
includelib user32.lib

iniStr proto , fstr:ptr byte, len : dword

.data
find 	HANDLE 	?
hFile 	HANDLE 	?	
cnt		DW		3 dup(0)
path	DB		200 dup(0)

msgF	DB		"Failed !!!",0

nameF	DB		"in.txt",0
nameO	DB		"out.txt",0
nul		DB		10,0,0

res		WIN32_FIND_DATA <>
check 	BOOL	TRUE

tmp 	DWORD	0
.code

start:
	invoke CreateFile,addr nameF,GENERIC_READ,FILE_SHARE_READ,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL
	mov hFile, eax
	cmp eax, INVALID_HANDLE_VALUE
	jnz Continue
	invoke MessageBox,NULL,addr msgF, addr msgF,MB_OK
	jmp quit
Continue:
	invoke ReadFile,hFile,addr path,200,addr cnt,NULL
	
	invoke CreateFile,addr nameO,GENERIC_WRITE,FILE_SHARE_READ,NULL,CREATE_ALWAYS,FILE_ATTRIBUTE_NORMAL,NULL
	mov	hFile, eax
	cmp eax, INVALID_HANDLE_VALUE
	jnz Continue2
	invoke MessageBox,NULL,addr msgF,addr msgF, MB_OK
	jmp quit
Continue2:
	invoke FindFirstFile,addr path,addr res
	mov	find, eax
	cmp eax, INVALID_HANDLE_VALUE
	jnz Continue3
	invoke MessageBox,NULL,addr msgF,addr msgF,MB_OK
	jmp quit
Continue3:
	invoke FindNextFile,find,addr res
	mov	check , eax
	cmp eax, FALSE
	jz quit
L1:
	invoke FindNextFile,find,addr res
	cmp eax, FALSE
	jz quit
	;invoke MessageBox,NULL,addr res.cFileName, 0 , NULL
	invoke WriteFile,hFile,addr res.cFileName,50, addr cnt, NULL
	mov tmp , lengthof res.cFileName
	invoke iniStr, addr res.cFileName , tmp
	invoke WriteFile,hFile,addr nul,1,addr cnt,NULL
	loop L1
quit:
	invoke ExitProcess,NULL
	
iniStr proc uses edi eax ecx ebx , fstr: ptr byte , len:dword 
	mov ebx , 0
	mov edi , fstr
	mov ecx , len
L2:
	mov [edi],ebx
	inc edi
	loop L2
	ret

iniStr endp
end start