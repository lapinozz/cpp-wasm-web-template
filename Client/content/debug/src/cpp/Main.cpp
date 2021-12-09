#include <vector>
#include <unordered_set>

#include <iostream>

#include <emscripten/bind.h>

using namespace emscripten;

#define EM_FUNC
#define EM_EXPORT

int EM_EXPORT main()
{
}

extern "C"
{
	bool EM_EXPORT getBool(bool b)
	{
		return b;
	}

	char* EM_EXPORT getString(char* c)
	{
		return c;
	}

	int EM_EXPORT getInt(int i)
	{
		return i;
	}
}

// This is your routine C++ code
std::string EM_FUNC getStr(std::string inStr) {
    return inStr;
}

EMSCRIPTEN_BINDINGS(my_module) {
    function("getStr", &getStr);
}