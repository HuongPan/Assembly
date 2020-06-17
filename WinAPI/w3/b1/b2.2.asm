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
reDrawBr proto

.const 
ID_TIMER EQU 200
speed	 EQU 10
ID		equ		105
.data?
hIns 	DWORD	?
hWnd1	DWORD 	?

.data
classname	db		"BouBall",0
appname		db		"BouncingBall",0

wc			WNDCLASSEX	<>
msg			MSG			<>

;cons	dd	4

rad		DWORD	30

;mx		dd	4
;my		dd	4

mx1		dd	-4
my1		dd	-4


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
	
	invoke CreateWindowEx,NULL,addr classname, addr appname, WS_OVERLAPPEDWINDOW, 100,100,750,750,NULL,NULL,hIns,NULL
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
	
	balldraw proc uses eax ebx ecx edx, x1:DWORD, y1:DWORD , cons: DWORD , relocaX: DWORD , relocaY: DWORD , mx: DWORD , my: DWORD
	LOCAL hdc: DWORD 
	LOCAL hbr: dword
	LOCAL bhbr:dword
	LOCAL pen: DWORD
	LOCAL rect: RECT
	LOCAL tmp: RECT
	LOCAL x2:DWORD
	LOCAL y2:DWORD
	
	.while TRUE
		mov eax, x1
		mov tmp.left,eax
		add eax, rad
		mov x2, eax
		mov tmp.right,eax
		
		mov eax, y1
		mov tmp.top,eax
		add eax, rad
		mov y2, eax
		mov tmp.bottom,eax
		
		invoke GetDC,hWnd1
		mov hdc, eax
		
		invoke GetStockObject,WHITE_BRUSH
		mov hbr, eax
			
		invoke GetClientRect,hWnd1, addr rect
	
		invoke CreateSolidBrush,000000ffh
		mov bhbr,eax
		invoke SelectObject,hdc,bhbr
		invoke Ellipse,hdc,x1,y1,x2,y2
		
		invoke Sleep,speed
		
		;mov eax , rad	
		;sub tmp.left,eax
		;sub tmp.top,eax
		;add tmp.right,eax
		;add tmp.bottom,eax
		invoke CreatePen,PS_SOLID,2,0ffffffh
		mov pen,eax
		invoke SelectObject,hdc,pen
		invoke SelectObject,hdc,hbr
		invoke Ellipse,hdc,x1,y1,x2,y2
		invoke DeleteObject,hbr
		invoke DeleteObject,bhbr
		invoke DeleteObject,pen
		;invoke Sleep,10
		mov ecx, cons
	
		mov eax, my
		add y1, eax
		mov edx, rect.bottom
		.if y1 > edx
			mov edx, relocaY
			mov y1, edx
		.endif
		;if y2 + rad cham. ddasy
		mov eax, y2
		add eax, my			
		; update toa do moi		
		mov ebx, mx
		add x1, ebx	
		mov edx, rect.right
		.if x1 > edx
			mov edx, relocaX
			mov x1, edx
		.endif
		;if x2 + rad cham canhj phair 		
		mov ebx, x2
		add ebx, mx
		
		.if y1 < ecx
			.if my > ecx				
				neg my
			.endif
		.elseif eax > rect.bottom
			neg my		
		.endif
		
		.if x1 < ecx
			.if mx > ecx				
				neg mx
			.endif
		.elseif ebx > rect.right
			neg mx
		.endif
		
		
		invoke ReleaseDC,hWnd1,hdc
	.endw	
		ret

	balldraw endp
	
	WndProc proc hWnd:HWND, uMsg: UINT,wParam: WPARAM, lParam: LPARAM
	LOCAL ps: PAINTSTRUCT
	LOCAL hdc: DWORD
	LOCAL rect: RECT
	LOCAL hfont: HFONT
	LOCAL hNB : DWORD
	LOCAL hbr : DWORD
	 
		.if uMsg == WM_DESTROY
			invoke PostQuitMessage,NULL
			xor eax, eax
		.elseif uMsg == WM_CREATE
			invoke SetTimer,hWnd, ID_TIMER, 10,NULL

			mov eax, offset ballThread
			invoke CreateThread,NULL,NULL,eax,0,NULL,NULL
			
			mov eax, offset ballThread1
			invoke CreateThread,NULL,NULL,eax,0,NULL,NULL
			
			mov eax, offset ballThread2
			invoke CreateThread,NULL,NULL,eax,0,NULL,NULL
			
			mov eax, offset ballThread3
			invoke CreateThread,NULL,NULL,eax,0,NULL,NULL
			
			mov eax, offset ballThread4
			invoke CreateThread,NULL,NULL,eax,0,NULL,NULL
			
			mov eax, offset ballThread5
			invoke CreateThread,NULL,NULL,eax,0,NULL,NULL
			
			mov eax, offset ballThread6
			invoke CreateThread,NULL,NULL,eax,0,NULL,NULL
			
			mov eax, offset ballThread7
			invoke CreateThread,NULL,NULL,eax,0,NULL,NULL
			
			mov eax, offset ballThread8
			invoke CreateThread,NULL,NULL,eax,0,NULL,NULL
			
			mov eax, offset ballThread9
			invoke CreateThread,NULL,NULL,eax,0,NULL,NULL
			
			mov eax, offset ballThread10
			invoke CreateThread,NULL,NULL,eax,0,NULL,NULL
			
			mov eax, offset ballThread11
			invoke CreateThread,NULL,NULL,eax,0,NULL,NULL
		.else 
			invoke DefWindowProc,hWnd,uMsg,wParam,lParam
		.endif
		
		ret

	WndProc endp
	
	ballThread proc  , wParam: WPARAM
		;.while TRUE
			invoke balldraw,0,0, 15 , 0,0,4,15
		;.endw
		ret

	ballThread endp
	
	ballThread1 proc  , wParam: WPARAM
		
		;.while TRUE
			invoke balldraw,100,99, 4 , 0,0,-4,4
		;.endw
		ret

	ballThread1 endp
	
	ballThread2 proc  , wParam: WPARAM
		;.while TRUE
			invoke balldraw,45,200, 9 , 0,0,4,-9
		;.endw
		ret

	ballThread2 endp
	
	ballThread3 proc  , wParam: WPARAM
		
		;.while TRUE
			invoke balldraw,70,50, 7 , 0,0,-3,-6
		;.endw
		ret

	ballThread3 endp
	
	ballThread4 proc  , wParam: WPARAM
		;.while TRUE
			invoke balldraw,0,0, 4 , 0,0,15,2
		;.endw
		ret

	ballThread4 endp
	
	ballThread5 proc  , wParam: WPARAM
		
		;.while TRUE
			invoke balldraw,100,99, 8 , 0,0,-8,7
		;.endw
		ret

	ballThread5 endp
	
	ballThread6 proc  , wParam: WPARAM
		;.while TRUE
			invoke balldraw,45,200, 9 , 0,0,-3,5
		;.endw
		ret

	ballThread6 endp
	
	ballThread7 proc  , wParam: WPARAM
		
		;.while TRUE
			invoke balldraw,70,500, 15 , 0,0,-7,-15
		;.endw
		ret

	ballThread7 endp
	
	ballThread11 proc  , wParam: WPARAM
		;.while TRUE
			invoke balldraw,0,0, 15 , 0,0,15,10
		;.endw
		ret

	ballThread11 endp
	
	ballThread10 proc  , wParam: WPARAM
		
		;.while TRUE
			invoke balldraw,100,99, 20 , 0,0,-8,-15
		;.endw
		ret

	ballThread10 endp
	
	ballThread9 proc  , wParam: WPARAM
		;.while TRUE
			invoke balldraw,45,200, 17 , 0,0,-15,9
		;.endw
		ret

	ballThread9 endp
	
	ballThread8 proc  , wParam: WPARAM
		
		;.while TRUE
			invoke balldraw,70,50, 10 , 0,0,-8,-1
		;.endw
		ret

	ballThread8 endp
	
	reDrawBr proc
	LOCAL hdc: DWORD
	LOCAL hbr: DWORD	
	LOCAL rect: RECT
	invoke GetDC,hWnd1
	mov hdc, eax
	invoke GetStockObject,BLACK_BRUSH
	mov hbr, eax
	invoke GetClientRect,hWnd1 , addr rect
	invoke FillRect,hdc,addr rect,hbr
	
	invoke ReleaseDC,hWnd1,hdc
	invoke SetTimer,hWnd1, ID_TIMER, 1000000000,NULL
	ret

	reDrawBr endp
	
end start
