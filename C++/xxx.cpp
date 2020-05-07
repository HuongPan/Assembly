#include<bits/stdc++.h>
#include<windows.h>
using namespace std;

int main(){
    char buf[200] = {0};
    DWORD cnt = 0;
    HANDLE hfile = CreateFileA("inpPath",GENERIC_READ,0,NULL,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,NULL);
    if(hfile == INVALID_HANDLE_VALUE){
        cout << "Failed !!" << endl;
    }

    ReadFile(hfile, buf, 199 , &cnt, NULL);
    printf("%s\n",buf);
    WIN32_FIND_DATAA res;
    char path[200] = "D:\\CTF\\REA\\Assembly\\Excercise\\exxx\\*";       // bat buoc phai co * o path
    HANDLE hFind = INVALID_HANDLE_VALUE;
    
    hFind = FindFirstFileA(buf,&res);


    if(hFind == INVALID_HANDLE_VALUE){
        cout << "Failed again !!" << endl;
    }
    
    do {
        printf("  %s\t\n", res.cFileName);
    }while(FindNextFileA(hFind,&res) != 0);

    FindClose(hFind);

}