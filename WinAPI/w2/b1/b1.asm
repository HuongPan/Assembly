.386
.model flat,stdcall

include kernel32.inc
include user32.inc
include windows.inc

includelib kernel32.lib
includelib user32.lib


.data
cName 		db 		"ezWinAPI",0
wName		db		"Win32 ASM",0
erMsg		db		"Failed !! ",0

Title1		db		"Success !!",0
Text1		db		"CreateWindow and UpdateWindow invoke success !!",0


MainWnd		WNDCLASS	<NULL,NULL,NULL,NULL,NULL,NULL,NULL,COLOR_WINDOW,NULL,cName>
hIns		DWORD 	?
hMainWnd	DWORD 	?
msg			MSG		<>
winReact	RECT	<>
.code
WinMain:
	; get a handle to the current process
	invoke GetModuleHandle,NULL
	mov hIns, eax
	mov MainWnd.hInstance, eax
; load the program's icon and cursor
	invoke LoadIcon,NULL,IDI_APPLICATION
	mov MainWnd.hIcon, eax
	invoke LoadCursor,NULL,IDC_ARROW
	mov MainWnd.hCursor, eax
	mov MainWnd.lpfnWndProc , offset WndProc
; register the windown class
	invoke RegisterClass,addr MainWnd
	.if eax == 0
		invoke MessageBox,NULL,addr erMsg,0,MB_OK
		jmp quit
	.endif
;create the app's main window
	invoke CreateWindowEx,NULL,addr cName,addr wName,WS_OVERLAPPEDWINDOW,50,50,500,500,NULL,NULL,hIns,NULL
;if Create failed
	.if eax == 0
		invoke MessageBox,NULL, addr erMsg,0,MB_OK
		jmp quit
	.endif
;save handle,show and draw window
		mov hMainWnd , eax
		invoke ShowWindow,hMainWnd,SW_SHOW
		invoke UpdateWindow,hMainWnd
		
		;invoke MessageBox,hMainWnd,addr Text1, addr Title1,MB_OK
		
;message loop
	MessageLoop:
		invoke GetMessage,addr msg , NULL , NULL , NULL
		.if eax == 0
			jmp quit
		.endif
		invoke TranslateMessage,addr msg
		invoke DispatchMessage,addr msg
		loop MessageLoop
	mov eax , msg.wParam
	quit:
	invoke ExitProcess,NULL
	
WndProc proc hWnd:HWND , uMsg:UINT, wParam: WPARAM, lParam: LPARAM
	mov eax , uMsg
	.if eax == WM_DESTROY
		invoke PostQuitMessage,NULL
		xor eax, eax
	.else 
		invoke DefWindowProc,hWnd,uMsg,wParam,lParam
	.endif	
	ret

WndProc endp
end WinMain