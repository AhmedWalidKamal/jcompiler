%{
#include <cstdio>
#include <iostream>
#include <fstream>
#include <iomanip> 
using namespace std;

// Stuff from flex that bison needs to know about
extern "C" int yylex();
extern "C" int yyparse();
extern "C" FILE *yyin;

// Function to handle parsing errors
void yyerror(const char *s);

std::ofstream token_file;
std::ofstream log_file;

%}

// Bison fundamentally works by asking flex to get the next token, which it
// returns as an object of type "yystype".  But tokens could be of any
// arbitrary data type!  So we deal with that in Bison by defining a C union
// holding each of the types of tokens that Flex could return, and have Bison
// use that union instead of "int" for the definition of "yystype"
%union {
	int int_val;
	float float_val;
    bool bool_val;
	char *string_val;
}

// Define the "terminal symbol" token types I'm going to use (in CAPS
// by convention), and associate each with a field of the union:
%token <ival> INT
%token <fval> FLOAT
%token <bool_val>
%token <sval> STRING
%token TOK_INT
%token TOK_FLOAT
%token TOK_BOOLEAN
%token TOK_IF
%token TOK_WHILE
%token TOK_ELSE
%token TOK_ASSIGN
%token TOK_ID
%token TOK_RELOP
%token TOK_ADDOP
%token TOK_MULOP
%token TOK_NUM

%%
// Grammar
method_body: statement_list;
statement_list: statement | statement_list statement;
statement: declaration | if | while | assignment;
declaration: primitive_type TOK_ID ';';
primitive_type: TOK_INT | TOK_FLOAT | TOK_BOOLEAN;
if: TOK_IF '(' expression ')' '{' statement '}' TOK_ELSE '{' statement '}';
while: TOK_WHILE '(' expression ')' '{' statement '}';
assignment: TOK_ID TOK_ASSIGN expression ';';
expression: simple_expression | simple_expression TOK_RELOP simple_expression;
simple_expression: term | sign term | simple_expression TOK_ADDOP term;
term: factor | term TOK_MULOP factor;
factor: TOK_ID | TOK_NUM | '(' expression ')';
sign: TOK_ADDOP;
%%

int main(int argc, char **argv) {

	token_file.open("token-file.txt");
	log_file.open("compiler.log");

	log_file << std::left << std::setw (20) << "Match State" <<
        std::left << std::setw (40) << "Lexeme" << std::left << std::setw (30)
            << "Token Class" << endl;
    log_file << std::left << std::setw (20) << "-----------" <<
        std::left << std::setw (40) << "------" << std::left << std::setw (30)
            << "-----------" << endl;

    // Make sure file name is specified in arguments
    if (argc != 2) {
        cout << "ERROR: wrong number of arguments!" << endl;
        return -1;
    }
	// Open a file handle to code file
	FILE *myfile = fopen(argv[1], "r");
	
    // Make sure it's valid
	if (!myfile) {
		cout << "Can't open code file!" << endl;
		return -1;
	}
	// Set lex to read from file instead of STDIN
	yyin = myfile;

	// Parse through the input until there is no more
	do {
		yyparse();
	} while (!feof(yyin));
	
}

void yyerror(const char *s) {
	cout << "EEK, parse error!  Message: " << s << endl;
	exit(-1); // Remove this to allow panic error recovery to keep execution
}
