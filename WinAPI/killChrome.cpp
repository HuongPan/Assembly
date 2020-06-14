#include <windows.h>

#define ID_TIMER    1

LRESULT CALLBACK WndProc(HWND, UINT, WPARAM, LPARAM); VOID    CALLBACK TimerProc(HWND, UINT, UINT, DWORD);

BOOL CALLBACK enumWindowCallback(HWND hWnd, LPARAM lparam)
{

	unsigned long process_id = 0;
	GetWindowThreadProcessId(hWnd, &process_id);
	char class_namea[80];
	GetClassNameA(hWnd, class_namea, sizeof(class_namea));
	if (IsWindowVisible(hWnd))
	{
		if (strcmp(class_namea, "Chrome_WidgetWin_1") == 0)
		{
			DWORD dwDesiredAccess = PROCESS_TERMINATE;
			BOOL bInheritHandle = FALSE;
			HANDLE hProcess = OpenProcess(dwDesiredAccess, bInheritHandle, process_id);
			if (hProcess == NULL)
				return FALSE;
			BOOL result = TerminateProcess(hProcess, 1);
			CloseHandle(hProcess);
		}
	}
	return TRUE;
}
int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, PSTR szCmdLine, int iCmdShow)
{
	const WCHAR szAppName[] = L"AntiChrome";
	HWND        hwnd;
	MSG         msg;
	WNDCLASS    wndclass;
	wndclass.style = CS_HREDRAW | CS_VREDRAW;
	wndclass.lpfnWndProc = WndProc;
	wndclass.cbClsExtra = 0;
	wndclass.cbWndExtra = 0;
	wndclass.hInstance = hInstance;
	wndclass.hIcon = LoadIcon(NULL, IDI_APPLICATION);
	wndclass.hCursor = LoadCursor(NULL, IDC_ARROW);
	wndclass.hbrBackground = (HBRUSH)GetStockObject(WHITE_BRUSH);
	wndclass.lpszMenuName = NULL;
	wndclass.lpszClassName = szAppName;
	if (!RegisterClass(&wndclass))
	{
		MessageBox(NULL, TEXT("Program requires Windows NT!"), szAppName, MB_ICONERROR);
		return 0;
	}
	hwnd = CreateWindowExW(NULL,szAppName, L"AntiChrome", WS_OVERLAPPEDWINDOW, CW_USEDEFAULT, CW_USEDEFAULT, 200, 50, NULL, NULL, hInstance, NULL);

	ShowWindow(hwnd, iCmdShow);
	UpdateWindow(hwnd);
	while (GetMessage(&msg, NULL, 0, 0))
	{
		TranslateMessage(&msg);
		DispatchMessage(&msg);
	}
	return msg.wParam;
}
LRESULT CALLBACK WndProc(HWND hwnd, UINT message, WPARAM wParam, LPARAM lParam)
{
	switch (message)
	{
	case WM_CREATE:
		SetTimer(hwnd, ID_TIMER, 5000, NULL);
		return 0;
	case WM_TIMER:
		EnumWindows(enumWindowCallback, NULL);
		return 0;
	case WM_DESTROY:
		KillTimer(hwnd, ID_TIMER);
		PostQuitMessage(0);
		return 0;
	}
	return DefWindowProc(hwnd, message, wParam, lParam);
}

