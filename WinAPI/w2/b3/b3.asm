.386
.model flat, stdcall

include kernel32.inc
include user32.inc
include windows.inc

includelib	kernel32.lib
includelib	user32.lib

str_len proto, str1: ptr byte
str_rev	proto, str2:ptr byte

.data
classname	db			"Win32",0
wndname		db			"Reverse Text",0
class1		db			"Edit",0
class2		db			"Static",0
buf			db			1000 dup(0)
buf1		db			"Text Here",0
xxx			db			"Failed",0

hWnd1		DWORD 	?
wc			WNDCLASSEX	<>
hIns		DWORD	?	
hEdit		DWORD	?
hRead		DWORD	?
msg			MSG		<>

.const
Edit	equ		1000
Read	equ		2
Init	equ		0
GetText equ		3
SetText	equ		4

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
	
	invoke CreateWindowEx,NULL,addr classname, addr wndname, WS_OVERLAPPEDWINDOW, 500, 250 , 320 , 150 , NULL,NULL, hIns, NULL
	mov hWnd1, eax
	.if eax == 0
		invoke MessageBox,NULL,NULL,NULL,MB_OK
		jmp quit
	.endif
	
	invoke CreateWindowEx,WS_EX_CLIENTEDGE,addr class1,0,WS_CHILD OR WS_VISIBLE or WS_BORDER or ES_AUTOHSCROLL,10,10,280,30,hWnd1, Edit , hIns , NULL
	mov hEdit , eax
			
	invoke CreateWindowEx,WS_EX_CLIENTEDGE,addr class2,0,WS_CHILD OR WS_VISIBLE or WS_BORDER or ES_AUTOHSCROLL,10,50,280,30, hWnd1,Read,hIns,NULL
	mov hRead , eax	
	
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
		xor eax , eax
		mov eax , uMsg
		.if	uMsg == WM_DESTROY
			invoke PostQuitMessage,NULL
			xor eax, eax
		.elseif	uMsg == WM_COMMAND
			mov eax , wParam
			.if ax == Edit
				invoke GetWindowText,hEdit,addr buf,sizeof buf
				invoke str_rev,addr buf
				invoke SetWindowText,hRead,addr buf
			.endif		
		.else
			invoke DefWindowProc,hWnd,uMsg,wParam,lParam
		.endif
		outp:
		ret

	WndProc endp

	str_rev	proc uses eax ebx edi ecx edx, str2:ptr byte
		mov     esi, str2   ; load up start pointer.

	    mov     edi, str2  ; set end pointer by finding zero byte.
    	dec     edi
		find_end:
    		inc     edi                  ; advance end pointer.
    		mov     al, [edi]            ; look for end of string.
    		cmp     al, 0
    		jnz     find_end             ; no, keep looking.
    		dec     edi                  ; yes, adjust to last character.

		swap_loop:
    		cmp     esi, edi             ; if start >= end, then we are finished.
   			jge     finished

    		mov     bl, [esi]            ; swap over start and end characters.
    		mov     al, [edi]
    		mov     [esi], al
    		mov     [edi], bl

    		inc     esi                  ; move pointers toward each other and continue.
    		dec     edi
    		jmp     swap_loop

		finished:
		ret

	str_rev endp

end Start