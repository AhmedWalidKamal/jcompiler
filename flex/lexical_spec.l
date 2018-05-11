%{
#include <iostream>
#include <fstream>
#include <iomanip> 
#include "parser_spec.tab.h"
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
#define INT_NUM_CLASS "int_num"
#define FLOAT_NUM_CLASS "float_num"

#define YY_DECL extern "C" int yylex()

extern "C++" std::ofstream token_file;
extern "C++" std::ofstream log_file;
int line_num = 1;

%} 
digit		[0-9]
digits 		{digit}+
letter		[a-zA-Z]
id   		{letter}({letter}|{digit})*
sign        [+-]
int_num		{digits}
float_num   (({digit}*\.{digit}+)|({digit}+\.{digit}*)){exp}?
exp         [eE]{sign}?{digit}+

%%
[ \t]		;
boolean {
            log_file << std::left << std::setw(20) << "[MATCHED]" <<
            	std::left << std::setw(40) << yytext << std::setw (30) << BOOLEAN_CLASS << endl;
			token_file << BOOLEAN_CLASS << endl;
            return TOK_BOOLEAN;
        }
int     {
            log_file << std::left << std::setw(20) << "[MATCHED]" <<
                    std::left << std::setw(40) << yytext << std::setw (30) << INT_CLASS << endl;
            token_file << INT_CLASS << endl;
            return TOK_INT;
        }
float   {
            log_file << std::left << std::setw(20) << "[MATCHED]" <<
                    std::left << std::setw(40) << yytext << std::setw (30) << FLOAT_CLASS << endl;
			token_file << FLOAT_CLASS << endl;
            return TOK_FLOAT;
        }
if      {
            log_file << std::left << std::setw(20) << "[MATCHED]" <<
                std::left << std::setw(40) << yytext << std::setw (30) << IF_CLASS << endl;
			token_file << IF_CLASS << endl;
			return TOK_IF;
		}
else    {
			log_file << std::left << std::setw(20) << "[MATCHED]" <<
                std::left << std::setw(40) << yytext << std::setw (30) << ELSE_CLASS << endl;
			token_file << ELSE_CLASS << endl;
			return TOK_ELSE;
		}
while   {
			log_file << std::left << std::setw(20) << "[MATCHED]" <<
                std::left << std::setw(40) << yytext << std::setw (30) << WHILE_CLASS << endl;
			token_file << WHILE_CLASS << endl;
			return TOK_WHILE;
		}
"=="|"!="|">"|">="|"<"|"<=" {
								log_file << std::left << std::setw(20) << "[MATCHED]" <<
                					std::left << std::setw(40) << yytext << std::setw (30) << RELOP_CLASS << endl;
							 	token_file << RELOP_CLASS << endl;
							 	return TOK_RELOP;
							}
"("     {
			log_file << std::left << std::setw(20) << "[MATCHED]" <<
                std::left << std::setw(40) << yytext << std::setw (30) << OPEN_PARENTHESES_CLASS << endl;
			token_file << OPEN_PARENTHESES_CLASS << endl;
			return '(';
		}
")"     {
            log_file << std::left << std::setw(20) << "[MATCHED]" <<
                std::left << std::setw(40) << yytext << std::setw (30) << CLOSE_PARENTHESES_CLASS << endl;
	        token_file << CLOSE_PARENTHESES_CLASS << endl;
			return ')';
        }
";"     {
			log_file << std::left << std::setw(20) << "[MATCHED]" <<
                std::left << std::setw(40) << yytext << std::setw (30) << SEMICOLON_CLASS << endl;
	   		token_file << SEMICOLON_CLASS << endl;
			return ';';
	    }
"{"  	{
			log_file << std::left << std::setw(20) << "[MATCHED]" <<
                std::left << std::setw(40) << yytext << std::setw (30) << OPEN_BRACES_CLASS << endl;
	   		token_file << OPEN_BRACES_CLASS << endl;
			return '{';
	    }
"}"     {
			log_file << std::left << std::setw(20) << "[MATCHED]" <<
                std::left << std::setw(40) << yytext << std::setw (30) << CLOSE_BRACES_CLASS << endl;
	   		token_file << CLOSE_BRACES_CLASS << endl;
			return '}';
	    }
"+"|"-" {
	   		log_file << std::left << std::setw(20) << "[MATCHED]" <<
                std::left << std::setw(40) << yytext << std::setw (30) << ADDOP_CLASS << endl;
		 	token_file << ADDOP_CLASS << endl;
			return TOK_ADDOP;
		}
"*"|"/" {
			log_file << std::left << std::setw(20) << "[MATCHED]" <<
                std::left << std::setw(40) << yytext << std::setw (30) << MULOP_CLASS << endl;
         	token_file << MULOP_CLASS << endl;
			return TOK_MULOP;
		}
"=" 	{
			log_file << std::left << std::setw(20) << "[MATCHED]" <<
                std::left << std::setw(40) << yytext << std::setw (30) << ASSIGN_CLASS << endl;;
	 		token_file << TOK_ASSIGN << endl;
			return TOK_ASSIGN;
	 	}
"," 	{
			log_file << std::left << std::setw(20) << "[MATCHED]" <<
                std::left << std::setw(40) << yytext << std::setw (30) << COMMA_CLASS << endl;
	 		token_file << COMMA_CLASS << endl;
			return ',';
	 	}
{id}  	{
			log_file << std::left << std::setw(20) << "[MATCHED]" <<
                std::left << std::setw(40) << yytext << std::setw (30) << ID_CLASS << endl;
 	   		token_file << ID_CLASS << endl;
			return TOK_ID;
		}
{int_num}	{
			log_file << std::left << std::setw(20) << "[MATCHED]" <<
                std::left << std::setw(40) << yytext << std::setw (30) << INT_NUM_CLASS << endl;
		 	token_file << INT_NUM_CLASS << endl;
			yylval.ival = atoi(yytext);
			return INT;
		}
{float_num}	{
			log_file << std::left << std::setw(20) << "[MATCHED]" <<
                std::left << std::setw(40) << yytext << std::setw (30) << FLOAT_NUM_CLASS << endl;
		 	token_file << FLOAT_NUM_CLASS << endl;
			yylval.fval = atof(yytext);
			return FLOAT;
		}
[\n]	{
			line_num++;	
		}
. 		{ 
			log_file << std::left << std::setw(20) << "[UNMATCHED]" <<
                std::left << std::setw(40) << yytext << std::setw (30) << "" << endl;
			return UNRECOGNIZED_TOKEN;
		}

%%
