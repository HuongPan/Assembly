.386
.model flat, stdcall

include kernel32.inc
include user32.inc
include windows.inc

includelib	kernel32.lib
includelib	user32.lib

addCol	proto
addItem proto,row: DWORD, lpFind: DWORD
appendSTR proto , str2:ptr byte , str_t :ptr byte
str_len proto, str1: ptr byte
cut_str proto, str_1:ptr byte , str_c :ptr byte 
FindFile proto, temp: ptr byte
del_str proto, str_del : ptr byte
strcpy proto , cpy1:ptr byte , cpy2: ptr byte
remove_until proto , rm:ptr byte
checkFolder proto, str1: ptr byte
.const 
butS		equ 1
butP		equ 2
WM_FINISH 	equ WM_USER+100h
ID_Edit		equ 1000
ID_GenButS 	equ 200
ID_GenButP 	equ 201
ID_KillThr	equ 202
ID_CreateThr equ 203
ID_GenNewLV	equ 204
.data
classname	db			"Win32",0
wndname		db			"Scan",0
lvClass 	db 			"SysListView32",0
butClass	db			"Button",0
editClass	db			"Edit",0
staticClass	db			"Static",0
test1		db			"D:",0
butSt		db			"Start",0
butPa		db			"Stop",0
failed		db			"Failed",0
doneCap		db			"Done!!!",0
doneContent	db			"Find End !!",0
colHeading	db			"FilePath",0
	
cnt		DWORD		3 dup(0)
path	DB		10000 dup(0)
tail	DB		"\*",0
tail2	DB		"*",0

tmp 	DB		5000 dup(0)
tmp2	DB		5000 dup(0)
nul		DB		10,0,0
msg			MSG		<>
wc			WNDCLASSEX	<>

.data?
hWnd1		DWORD 	?
hIns		DWORD	?	
hEdit		DWORD	?
hRead		DWORD	?
find 		DWORD 	?
hFile 		DWORD 	?
hList		DWORD	?
 button1 	HWND	?
 button2 	HWND	?
 ThreadID 	DWORD 	?
hThread		DWORD	?
ExitCode	DWORD 	?
lvWid		DWORD	?
.code
Start:
	invoke GetModuleHandle,NULL
	mov hIns, eax
	mov wc.hInstance, eax
	
	mov	wc.cbClsExtra , 0
	mov	wc.cbSize , sizeof WNDCLASSEX
	mov wc.cbWndExtra , 0
	mov wc.hbrBackground, COLOR_WINDOW + 1
	invoke LoadIcon,NULL,IDI_APPLICATION
	mov wc.hIcon, eax
	mov wc.hIconSm, eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov	wc.hCursor,eax
	mov wc.lpfnWndProc,offset WndProc
	mov wc.lpszClassName, offset classname
	mov wc.lpszMenuName, NULL
	mov wc.style, CS_HREDRAW OR CS_VREDRAW
	
	invoke RegisterClassEx,addr wc
	.if eax == 0
		invoke MessageBox,NULL,NULL,NULL,MB_OK
		jmp quit
	.endif
	
	invoke CreateWindowEx,NULL,addr classname, addr wndname, WS_OVERLAPPEDWINDOW, 500, 250 , 590 , 500 , NULL,NULL, hIns, NULL
	mov hWnd1, eax
	.if eax == 0
		invoke MessageBox,NULL,NULL,NULL,MB_OK
		jmp quit
	.endif
	
	invoke CreateWindowEx,WS_EX_CLIENTEDGE, addr editClass,addr test1,WS_CHILD+ WS_VISIBLE+ ES_AUTOHSCROLL, 10,10,500,30,hWnd1,ID_Edit,hIns,NULL
	mov hEdit, eax
	invoke CreateWindowEx,WS_EX_CLIENTEDGE, addr butClass, addr butSt, WS_CHILD or WS_VISIBLE,510,10,50,30,hWnd1,butS,hIns,NULL
	mov button1 , eax
	
	invoke ShowWindow,hWnd1,SW_SHOW
	invoke UpdateWindow,hWnd1
	
	MessageLoop:
		invoke GetMessage,addr msg, NULL,NULL,NULL
		.if eax == 0
			jmp quit
		.endif
		invoke TranslateMessage,addr msg
		invoke DispatchMessage,addr msg	
		loop MessageLoop
	quit:
	invoke ExitProcess,NULL 
	
	WndProc proc hWnd : HWND , uMsg:UINT , wParam: WPARAM , lParam: LPARAM
	LOCAL hdc: DWORD
	LOCAL ps: PAINTSTRUCT
	LOCAL rect: RECT
	LOCAL Hei: DWORD
	LOCAL Wei: DWORD
	LOCAL lvi: LV_ITEM
	
	invoke GetClientRect,hWnd,addr rect
	mov eax, rect.bottom
	sub eax, 75
	mov Hei, eax
	mov eax, rect.right
	sub eax , 25
	mov Wei, eax
	
		mov eax , uMsg
		.if uMsg == WM_COMMAND
			mov eax,wParam
			.if lParam == 0
				.if ax == ID_GenButS
				
					mov eax, 70
   					sub Wei, 50
   					
					invoke DestroyWindow,hEdit
					invoke CreateWindowEx,WS_EX_CLIENTEDGE, addr editClass,addr path,WS_CHILD+ WS_VISIBLE+ ES_AUTOHSCROLL, 10,10,Wei,30,hWnd1,ID_Edit,hIns,NULL
					mov hEdit, eax
					
					mov eax , 10
   					add Wei, eax
					
					invoke DestroyWindow,button1
					invoke CreateWindowEx,WS_EX_CLIENTEDGE, addr butClass, addr butSt, WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON,Wei,10,50,30,hWnd,butS,hIns,NULL
					mov button1, eax
					
				.elseif ax == ID_GenButP
					mov eax, 70
   					sub Wei, 50
					
					invoke GetWindowText,hEdit,addr path,sizeof path	
					
					invoke DestroyWindow,hEdit				
					invoke CreateWindowEx,WS_EX_CLIENTEDGE,addr staticClass, addr path, WS_CHILD OR WS_VISIBLE OR ES_AUTOHSCROLL,10,10,Wei,30, hWnd1,ID_Edit,hIns,NULL
					mov hEdit, eax
					
					mov eax , 10
   					add Wei, eax
					
					invoke DestroyWindow,button1
					invoke CreateWindowEx,WS_EX_CLIENTEDGE, addr butClass, addr butPa, WS_CHILD or WS_VISIBLE or BS_DEFPUSHBUTTON, Wei,10,50,30,hWnd, butP, hIns,NULL
					mov button1, eax
					
				.elseif ax == ID_GenNewLV
					invoke DestroyWindow,hList
					invoke GetClientRect,hWnd,addr rect
			
					invoke CreateWindowEx,WS_EX_CLIENTEDGE, addr lvClass, NULL, LVS_REPORT+WS_CHILD+WS_VISIBLE, 10,60,550,390,hWnd, NULL, hIns, NULL
					mov hList, eax
					invoke SetFocus, hList
					invoke addCol
				.elseif ax == ID_CreateThr
					
					mov eax, offset ThreadProc
					invoke CreateThread,NULL,NULL,eax,0,NULL, addr ThreadID
					mov hThread, eax
					;invoke CloseHandle,eax
					
				.elseif ax == ID_KillThr
					invoke GetExitCodeThread,hThread,addr ExitCode
					.if ExitCode == STILL_ACTIVE
						invoke TerminateThread,hThread, 0
					.else 
						invoke CloseHandle,hThread
					.endif
				.endif
			.else
				.if ax == butS
					invoke SendMessage,hWnd,WM_COMMAND, ID_GenNewLV,0
					invoke SendMessage,hWnd,WM_COMMAND, ID_GenButP,0
					invoke SendMessage,hWnd,WM_COMMAND, ID_CreateThr,0
				.elseif ax == butP
					invoke SendMessage,hWnd,WM_COMMAND, ID_KillThr,0
					invoke SendMessage,hWnd,WM_COMMAND, ID_GenButS,0
				.endif
			.endif
		.elseif uMsg==WM_FINISH
        	
        	invoke SendMessage,hWnd,WM_COMMAND, ID_GenButS, 0
			
			invoke MessageBox,NULL,addr doneContent,addr doneCap,MB_OK	
			
		.elseif uMsg==WM_CREATE
			invoke SendMessage,hWnd,WM_COMMAND, ID_GenNewLV,0
			
		.elseif uMsg==WM_SIZE
    		invoke GetClientRect,hWnd,addr rect
			mov eax, rect.bottom
			sub eax, 75
			mov Hei, eax
			mov eax, rect.right
			sub eax , 25
			mov Wei, eax
   			invoke MoveWindow,hList,10,60,Wei,Hei,TRUE	
   			
   			mov eax, 70
   			sub Wei, 50
   			invoke MoveWindow,hEdit, 10,10,Wei,30,TRUE
   			
   			mov eax , 10
   			add Wei, eax
   			invoke MoveWindow,button1, Wei,10,50,30,TRUE
		.elseif	uMsg == WM_DESTROY
		
			invoke PostQuitMessage,NULL
			xor eax , eax
			.else 
				invoke DefWindowProc,hWnd,uMsg, wParam, lParam
				
		.endif
		outp:
		ret

	WndProc endp

	ThreadProc PROC USES ecx Param:DWORD
		;invoke GetWindowText,hEdit, addr path, sizeof path
		invoke FindFile,addr path
        invoke PostMessage,hWnd1,WM_FINISH,NULL,NULL
        ret
	ThreadProc ENDP

	addCol	proc uses ecx
		LOCAL lvc : LV_COLUMN
		LOCAL rect: RECT
				
		mov lvc.imask, LVCF_TEXT + LVCF_WIDTH + LVCF_FMT
		mov lvc.lx,600
		mov lvc.pszText, offset colHeading
		mov lvc.fmt,LVCFMT_FILL
		invoke SendMessage,hList,LVM_INSERTCOLUMN,0,addr lvc	
		ret

	addCol endp
	
	addItem proc uses edi eax ,row: DWORD, lpFind: DWORD
		LOCAL lvi: LV_ITEM
		LOCAL buffer[20]:byte
		LOCAL ind: dword
		invoke SetFocus,hList
		mov edi, lpFind
		assume edi: ptr WIN32_FIND_DATA
		mov lvi.imask, LVIF_TEXT + LVIF_PARAM 
		push row
		pop lvi.iItem
		mov lvi.iSubItem,0
		lea eax, tmp
		mov lvi.pszText,eax	
		push row
		pop lvi.lParam
		;mov lvi.		
		invoke SendMessage,hList,LVM_INSERTITEM, 0 ,addr lvi
		
		invoke SendMessage,hList,LVM_SCROLL,0,20
		invoke SendMessage,hList,LVM_ENSUREVISIBLE,row,FALSE
		
		;mov lvi.state, LVIS_SELECTED or LVIS_FOCUSED
		;mov lvi.stateMask, LVIS_SELECTED or LVIS_FOCUSED
		;invoke SendMessage, hList, LVM_SETITEMSTATE, 0, addr lvi

		invoke Sleep,100
		ret

	addItem endp


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
		xor edi,edi
		invoke cut_str,addr tail2,addr tmp
		.while eax != 0
			invoke checkFolder,addr finddata.cFileName
			.if eax == 0
				jmp xx
			.endif
			invoke appendSTR,addr finddata.cFileName , addr tmp
			;invoke MessageBox,NULL,addr tmp,0,MB_OK
			;invoke WriteFile,hFile,addr tmp,200,addr cnt,NULL
			;invoke WriteFile,hFile,addr nul,1,addr cnt,NULL
			invoke addItem,edi,addr tmp
			inc edi
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
	mov ecx , 5000
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

checkFolder proc uses ebx edi, str1: ptr byte
	
	mov bl, '.'
	mov edi, str1
	invoke str_len, str1
	cmp eax , 2
	jg CF1
	cmp eax , 1
	jz CF2
	cmp eax , 2
	jz CF3
CF1: ; if not equal '.' or '..' eax = 1 else eax = 0
	mov eax, 1
	jmp quitCF
CF2:
	cmp [edi], bl
	jnz CF1	
	jmp Falseee
CF3:
	cmp [edi], bl
	jnz CF1
	inc edi
	cmp [edi], bl
	jnz CF1
Falseee:
	mov eax , 0
	jmp quitCF

quitCF:
	ret

checkFolder endp
	
end Start

