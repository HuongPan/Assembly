#include<Windows.h>
#include<iostream>
#include<iomanip>
using namespace std;

char buff[1000];
HANDLE hFile;
int numberSection;
char hexDump[20];

int char2int(int i = 0, int cnt = 4){
	/* 4 byte char =>> 1 int*/
	int a = 0;
	//a = int((unsigned char)(buff[3]) << 24 |
	//	(unsigned char)(buff[2]) << 16 |
	//	(unsigned char)(buff[1]) << 8 |
	//	(unsigned char)(buff[0]));

	for (int j = 3; j > 0; --j) {
		a |= (unsigned char)(buff[j]);
		a <<= 8;
	}
	a |= (unsigned char)(buff[0]);
	return a;
}

void int2char(int n = 175, int cnt = 4) {
//	unsigned char hexDump[4];
	memset(hexDump, 1, sizeof(hexDump));
	//hexDump[3] = (n >> 24) & 0xFF;
	//hexDump[2] = (n >> 16) & 0xFF;
	//hexDump[1] = (n >> 8) & 0xFF;
	//hexDump[0] = n & 0xFF;
	for (int i = cnt - 1; i > 0; --i) {
		hexDump[i] = (n >> 8) & 0xFF;
	}
	hexDump[0] = n & 0xFF;
}

void getBuf(int index, int byteRead = 4) {
	SetFilePointer(hFile, index, NULL, FILE_BEGIN);
	if (!ReadFile(hFile, buff, byteRead, NULL, NULL)) {
		cout << "Failed2" << endl;
		return ;
	}
}

int main()
{
	char shellcode[] = "\x31\xd2\xb2\x30\x64\x8b\x12\x8b\x52\x0c\x8b\x52\x1c\x8b\x42"
		"\x08\x8b\x72\x20\x8b\x12\x80\x7e\x0c\x33\x75\xf2\x89\xc7\x03"
		"\x78\x3c\x8b\x57\x78\x01\xc2\x8b\x7a\x20\x01\xc7\x31\xed\x8b"
		"\x34\xaf\x01\xc6\x45\x81\x3e\x46\x61\x74\x61\x75\xf2\x81\x7e"
		"\x08\x45\x78\x69\x74\x75\xe9\x8b\x7a\x24\x01\xc7\x66\x8b\x2c"
		"\x6f\x8b\x7a\x1c\x01\xc7\x8b\x7c\xaf\xfc\x01\xc7\x68\x79\x74"
		"\x65\x01\x68\x6b\x65\x6e\x42\x68\x20\x42\x72\x6f\x89\xe1\xfe"
		"\x49\x0b\x31\xc0\x51\x50\xff\xd7";
	DWORD imageBase, OEP;
//	char OEP_new[4];
	int lfanew1;
	char fileName[] = "C:\\Users\\Admin\\source\\repos\\HomeWork\\b00.exe";
//	cin >> fileName;
	hFile = CreateFileA(fileName, GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
	if (hFile == INVALID_HANDLE_VALUE) {
		cout << "Failed1" << endl;
		return 0;
	}
	getBuf(60);
	lfanew1 = char2int();
	getBuf(lfanew1 + 6);
	numberSection = char2int(0, 2);
	numberSection++;
	int2char(numberSection, 2);
//	cout << numberSection << endl;
	getBuf(lfanew1 + 40);
	OEP = char2int();
//	WriteFile(hFile, OEP_new, 4, NULL, NULL);
	getBuf(lfanew1 + 52);
	imageBase = char2int();
	int2char();
//	cout << imageBase;
	return 0;
}