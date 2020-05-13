.386
.model flat, stdcall

include kernel32.inc
include user32.inc
include windows.inc

includelib	user32.lib
includelib	kernel32.lib

.data
clname		db		"WinASM",0
wndname		db		"Show Message !!",0

tit1		db		"Edit",0
text1		db		"Text Here...",0

tit2		db		"Button",0
text2		db		"OK",0

buf			db		1000 dup(0)
errors		db		"Failed",0

msg			MSG		<>
hWM			DWORD	?
hEdit		DWORD 	?
hIns		DWORD	?
hWnd1		DWORD	?
wc			WNDCLASSEX	<>

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
	mov wc.lpszClassName, offset clname
	mov wc.lpszMenuName, NULL
	mov wc.style, CS_HREDRAW OR CS_VREDRAW
	
	invoke RegisterClassEx,addr wc
	.if eax == 0
		invoke MessageBox,NULL, addr errors , 0,MB_OK
		jmp quit
	.endif
	
	invoke CreateWindowEx,WS_EX_ACCEPTFILES,addr clname, addr wndname, WS_OVERLAPPEDWINDOW, 500,250,250,120,NULL,NULL,hIns,NULL
	.if eax == 0
		invoke MessageBox,NULL, addr errors , 0,MB_OK
		jmp quit
	.endif
	mov hWnd1 , eax
	
	invoke CreateWindowEx,WS_EX_CLIENTEDGE, addr tit1, addr text1,WS_BORDER OR WS_CHILD OR WS_VISIBLE OR ES_AUTOHSCROLL,15,5,200,20,hWnd1,1000,NULL,NULL
	mov hEdit	, eax
	invoke CreateWindowEx,WS_EX_CLIENTEDGE, addr tit2, addr text2, BS_DEFPUSHBUTTON OR WS_TABSTOP OR WS_CHILD OR WS_VISIBLE OR BS_NOTIFY,90,40,50,20,hWnd1,1001,NULL,NULL
	
	invoke ShowWindow, hWnd1,SW_SHOW
	invoke UpdateWindow, hWnd1
	
	MessageLoop:
		invoke GetMessage,addr msg , NULL , NULL , NULL
		.if eax == 0
			jmp quit
		.endif
		invoke TranslateMessage,addr msg
		invoke DispatchMessage,addr msg
		loop MessageLoop
	quit:
	invoke ExitProcess,NULL
	
WndProc	proc , hWnd:HWND , uMsg:UINT , wParam: WPARAM, lParam: LPARAM
	mov eax , uMsg
	.if uMsg == WM_COMMAND
		mov eax , wParam
		.if eax == 1001
			invoke GetWindowText,hEdit, addr buf ,sizeof buf
			invoke MessageBox,hWnd, addr buf, addr wndname , MB_OK
		.endif
	.endif
	
	.if	eax == WM_DESTROY
		invoke PostQuitMessage,NULL
		xor eax, eax
		.else
			invoke DefWindowProc,hWnd,uMsg,wParam,lParam
	.endif
	
	ret

WndProc endp
end Start