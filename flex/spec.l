%{
#include <iostream>
using namespace std;
#define YY_DECL extern "C" int yylex()
%} 
id   [a-zA-Z]([a-zA-Z]|[0-9])*
%%
[ \t\n]         ;
boolean  {cout << "Matched boolean key word" << endl;}
int  {cout << "Matched int key word" << endl;}
float  {cout << "Matched float key word" << endl;}
if  {cout << "Matched if key word" << endl;}
else  {cout << "Matched else key word" << endl;}
while  {cout << "Matched while key word" << endl;}
"=="|"!="|">"|">="|"<"|"<=" {cout << "Matched relop: " << yytext << endl;}
"("   {cout << "Matched ( key word" << endl;}
")"   {cout << "Matched ) key word" << endl;}
";"   {cout << "Matched ; key word" << endl;}
"{"   {cout << "Matched '{' key word" << endl;}
"}"   {cout << "Matched '}' key word" << endl;}
"+"|"-" {cout << "Matched addop: " << yytext << endl;}
"*"|"/" {cout << "Matched mulop: " << yytext << endl;}
"=" {cout << "Matched assign symbol" << endl;}
{id}  {cout << "Matched identifier: " << yytext << endl;}
. { cout << "Unrecognized character: " << yytext << endl; }

%%
int main(int, char**) {
    // open a file handle to a particular file:
	FILE *myfile = fopen("rules.txt", "r");
	// make sure it's valid:
	if (!myfile) {
		cout << "Can't open file!" << endl;
		return -1;
	}
	// set lex to read from it instead of defaulting to STDIN:
	yyin = myfile;

	// lex through the input:
	yylex();
}
