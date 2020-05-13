#include <Windows.h>
#include <iostream>
#include <string>
#include <vector>    
std::wstring tmp1 = L"";
void FindFile(const std::wstring &directory)
{
    std::wstring tmp = directory + L"\\*";
    WIN32_FIND_DATAW file;
    HANDLE search_handle = FindFirstFileW(tmp.c_str(), &file);
    if (search_handle != INVALID_HANDLE_VALUE)
    {
        do
        {
            if (file.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY)
            {
                if ((!lstrcmpW(file.cFileName, L".")) || (!lstrcmpW(file.cFileName, L"..")))
                    continue;
            }

            tmp = directory + L"\\" + std::wstring(file.cFileName);
            std::wcout << tmp << std::endl;

            FindFile(tmp);
        }
        while (FindNextFileW(search_handle, &file));

        FindClose(search_handle);
    }
}

int main()
{
    FindFile(L"D:\\CTF\\REA\\Assembly\\Excercise");
    return 0;
}