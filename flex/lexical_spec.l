%{
#include <iostream>
#include <fstream>
#include <iomanip> 

using namespace std;

#define YY_DECL extern "C" int yylex()
#define BOOLEAN_CLASS "boolean"
#define INT_CLASS "int"
#define FLOAT_CLASS "float"
#define IF_CLASS "if"
#define ELSE_CLASS "else"
#define WHILE_CLASS "while"
#define RELOP_CLASS "relop"
#define OPEN_BRACES_CLASS "{"
#define CLOSE_BRACES_CLASS "}"
#define OPEN_PARENTHESES_CLASS "("
#define CLOSE_PARENTHESES_CLASS ")"
#define SEMICOLON_CLASS ";"
#define ADDOP_CLASS "addop"
#define MULOP_CLASS "mulop"
#define RELOP_CLASS "relop"
#define ASSIGN_CLASS "assign"
#define COMMA_CLASS ","
#define ID_CLASS "id"
#define NUM_CLASS "num"


std::ofstream token_file;
std::ofstream log_file;
%} 
digit	[0-9]
digits 	({digit}+)
letter	[a-zA-Z]
id   	({letter}({letter}|{digit})*)
num		({digits}|{digits}"."({digits}|{digits}"E"{digits}))
%%
[ \t\n]         ;
boolean  {log_file << std::left << std::setw(20) << "[MATCHED]" <<
                std::left << std::setw(40) << yytext << std::setw (30)
                << BOOLEAN_CLASS << endl;
		  token_file << BOOLEAN_CLASS << endl;}
int  {log_file << std::left << std::setw(20) << "[MATCHED]" <<
                std::left << std::setw(40) << yytext << std::setw (30)
                << INT_CLASS << endl;
	  token_file << INT_CLASS << endl;}
float  {log_file << std::left << std::setw(20) << "[MATCHED]" <<
                std::left << std::setw(40) << yytext << std::setw (30)
                << FLOAT_CLASS << endl;
		token_file << FLOAT_CLASS << endl;}
if  {log_file << std::left << std::setw(20) << "[MATCHED]" <<
                std::left << std::setw(40) << yytext << std::setw (30)
                << IF_CLASS << endl;
	 token_file << IF_CLASS << endl;}
else  {log_file << std::left << std::setw(20) << "[MATCHED]" <<
                std::left << std::setw(40) << yytext << std::setw (30)
                << ELSE_CLASS << endl;
	   token_file << ELSE_CLASS << endl;}
while  {log_file << std::left << std::setw(20) << "[MATCHED]" <<
                std::left << std::setw(40) << yytext << std::setw (30)
                << WHILE_CLASS << endl;
		token_file << WHILE_CLASS << endl;}
"=="|"!="|">"|">="|"<"|"<=" {log_file << std::left << std::setw(20) << "[MATCHED]" <<
                std::left << std::setw(40) << yytext << std::setw (30)
                << RELOP_CLASS << endl;
							 token_file << RELOP_CLASS << endl;}
"("   {log_file << std::left << std::setw(20) << "[MATCHED]" <<
                std::left << std::setw(40) << yytext << std::setw (30)
                << OPEN_PARENTHESES_CLASS << endl;
	   token_file << OPEN_PARENTHESES_CLASS << endl;}
")"   {log_file << std::left << std::setw(20) << "[MATCHED]" <<
                std::left << std::setw(40) << yytext << std::setw (30)
                << CLOSE_PARENTHESES_CLASS << endl;
	   token_file << CLOSE_PARENTHESES_CLASS << endl;}
";"   {log_file << std::left << std::setw(20) << "[MATCHED]" <<
                std::left << std::setw(40) << yytext << std::setw (30)
                << SEMICOLON_CLASS << endl;
	   token_file << SEMICOLON_CLASS << endl;}
"{"   {log_file << std::left << std::setw(20) << "[MATCHED]" <<
                std::left << std::setw(40) << yytext << std::setw (30)
                << OPEN_BRACES_CLASS << endl;
	   token_file << OPEN_BRACES_CLASS << endl;}
"}"   {log_file << std::left << std::setw(20) << "[MATCHED]" <<
                std::left << std::setw(40) << yytext << std::setw (30)
                << CLOSE_BRACES_CLASS << endl;
	   token_file << CLOSE_BRACES_CLASS << endl;}
"+"|"-" {log_file << std::left << std::setw(20) << "[MATCHED]" <<
                std::left << std::setw(40) << yytext << std::setw (30)
                << ADDOP_CLASS << endl;
		 token_file << ADDOP_CLASS << endl;}
"*"|"/" {log_file << std::left << std::setw(20) << "[MATCHED]" <<
                std::left << std::setw(40) << yytext << std::setw (30)
                << MULOP_CLASS << endl;
         token_file << MULOP_CLASS << endl;}
"=" {log_file << std::left << std::setw(20) << "[MATCHED]" <<
                std::left << std::setw(40) << yytext << std::setw (30)
                << ASSIGN_CLASS << endl;;
	 token_file << ASSIGN_CLASS << endl;}
"," {log_file << std::left << std::setw(20) << "[MATCHED]" <<
                std::left << std::setw(40) << yytext << std::setw (30)
                << COMMA_CLASS << endl;
	 token_file << COMMA_CLASS << endl;}
{id}  {log_file << std::left << std::setw(20) << "[MATCHED]" <<
                std::left << std::setw(40) << yytext << std::setw (30)
                << ID_CLASS << endl;
 	   token_file << ID_CLASS << endl;}
{num}	{log_file << std::left << std::setw(20) << "[MATCHED]" <<
                std::left << std::setw(40) << yytext << std::setw (30)
                << NUM_CLASS << endl;
		 token_file << NUM_CLASS << endl;}
. { log_file << std::left << std::setw(20) << "[UNMATCHED]" <<
                std::left << std::setw(40) << yytext << std::setw (30)
                << "" << endl;}

%%
int main(int, char**) {

	token_file.open("token-file.txt");
	log_file.open("compiler.log");

	log_file << std::left << std::setw (20) << "Match State" <<
        std::left << std::setw (40) << "Lexeme" << std::left << std::setw (30)
            << "Token Class" << endl;
    log_file << std::left << std::setw (20) << "-----------" <<
        std::left << std::setw (40) << "------" << std::left << std::setw (30)
            << "-----------" << endl;

	// open a file handle to a particular file:
	FILE *myfile = fopen("code.txt", "r");
	// make sure it's valid:
	if (!myfile) {
		cout << "Can't open code file!" << endl;
		return -1;
	}
	// set lex to read from it instead of defaulting to STDIN:
	yyin = myfile;

	// lex through the input:
	yylex();
}
