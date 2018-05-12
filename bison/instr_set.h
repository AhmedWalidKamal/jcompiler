#ifndef _____BYTE_CODE_INSTRUCTIONS
#define _____BYTE_CODE_INSTRUCTIONS

#include <map>
#include <string>

std::map<std::string, std::string> instr_list = {
		{"+", "add"},
		{"-", "sub"},
		{"*", "mul"},
		{"/", "div"},
		{">",  "if_icmple"},
		{"<",  "if_icmpge"},
		{"==", "if_icmpne"},
		{"!=", "if_icmpeq"},
		{">=", "if_icmplt"},
		{"<=", "if_icmpgt"}
};

#endif