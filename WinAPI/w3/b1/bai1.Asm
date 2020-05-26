.386
.model flat, stdcall

include kernel32.inc
include user32.inc
include windows.inc
include gdi32.inc
includelib kernel32.lib
includelib user32.lib
includelib gdi32.lib

moving proto right: DWORD, bottom: DWORD

.const 
ID_TIMER EQU 200
speed	 EQU 10

.data?
hIns 	DWORD	?
hWnd1	DWORD 	?

.data
classname	db		"BouBall",0
appname		db		"BouncingBall",0

wc			WNDCLASSEX	<>
msg			MSG			<>

cons	dd	4

x1		dd	0
x2		dd	0
y1		dd	0
y2		dd	0
rad		dd	30

mx		dd	4
my		dd	4

.code
start:
	invoke GetModuleHandle,NULL
	mov hIns, eax
	mov wc.hInstance, eax
	
	mov wc.cbSize, sizeof WNDCLASSEX
	mov wc.style, CS_HREDRAW OR CS_VREDRAW
	
	mov wc.lpfnWndProc,offset WndProc
	mov wc.cbClsExtra,0
	mov wc.cbWndExtra,0
	
	invoke LoadIcon,NULL,IDI_APPLICATION
	mov wc.hIcon, eax
	mov wc.hIconSm, eax
	
	invoke LoadCursor,NULL,IDC_ARROW
	mov wc.hCursor,eax
	
	mov wc.hbrBackground, COLOR_WINDOW + 1
	mov wc.lpszMenuName, NULL
	mov wc.lpszClassName, offset classname
	
	invoke RegisterClassEx,addr wc
	.if eax == 0
		invoke MessageBox,NULL, NULL, addr classname,MB_OK
		jmp quit
	.endif
	
	invoke CreateWindowEx,WS_EX_WINDOWEDGE,addr classname, addr appname, WS_OVERLAPPEDWINDOW, 500,250,500,500,NULL,NULL,hIns,NULL
	mov hWnd1, eax
	
	.if eax == 0
		invoke MessageBox,NULL,NULL, addr appname,MB_OK
		jmp quit
	.endif
	
	invoke ShowWindow,hWnd1,SW_SHOW
	invoke UpdateWindow,hWnd1
	
	Message:
		invoke GetMessage,addr msg,NULL,NULL,NULL
		.if eax == 0
			jmp quit
		.endif
		invoke TranslateMessage,addr msg
		invoke DispatchMessage,addr msg
		loop Message
	quit:
	invoke ExitProcess,NULL
	
	WndProc proc hWnd:HWND, uMsg: UINT,wParam: WPARAM, lParam: LPARAM
	LOCAL ps: PAINTSTRUCT
	LOCAL hdc: DWORD
	LOCAL rect: RECT
	LOCAL hfont: HFONT
	LOCAL hNB : DWORD
	LOCAL hbr : DWORD
		
		mov eax, x1
		add eax, rad
		mov x2, eax
		
		mov eax, y1
		add eax, rad
		mov y2, eax
	 
		.if uMsg == WM_DESTROY
			invoke PostQuitMessage,NULL
			xor eax, eax
		.elseif uMsg == WM_CREATE
			invoke SetTimer,hWnd, ID_TIMER, speed,NULL
		.elseif uMsg == WM_TIMER
			invoke GetDC,hWnd
			mov hdc, eax
			
			invoke GetStockObject,BLACK_BRUSH
			mov hbr, eax
			
			invoke GetClientRect,hWnd, addr rect
			invoke FillRect,hdc,addr rect, hbr
			invoke Ellipse,hdc,x1,y1,x2,y2
			invoke moving, rect.right , rect.bottom
			invoke ReleaseDC,hWnd,hdc
		.else 
			invoke DefWindowProc,hWnd,uMsg,wParam,lParam
		.endif
		
		ret

	WndProc endp
	
moving proc uses eax ebx ecx edx right: DWORD, bottom: DWORD
	mov ecx, cons
	
		mov eax, my
		add y1, eax
		mov edx, bottom
		.if y1 > edx
			sub edx, rad
			mov y1, edx
		.endif
		;if y2 + rad cham. ddasy
		mov eax, y2
		add eax, my			
		; update toa do moi		
		mov ebx, mx
		add x1, ebx	
		mov edx, right
		.if x1 > edx
			sub edx, rad
			mov x1, edx
		.endif
		;if x2 + rad cham canhj phair 		
		mov ebx, x2
		add ebx, mx
		
		.if y1 < ecx
			.if my > ecx				
				neg my
			.endif
		.elseif eax > bottom
			neg my		
		.endif
		
		.if x1 < ecx
			.if mx > ecx				
				neg mx
			.endif
		.elseif ebx > right
			neg mx
		.endif
		
	ret

moving endp
end start
