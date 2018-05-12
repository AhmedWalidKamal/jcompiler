%{
#include <cstdio>
#include <iostream>
#include <fstream>
#include <iomanip>
#include "bison/instr_set.h"
using namespace std;

// Stuff from flex that bison needs to know about
extern "C" int yylex();
extern "C" int yyparse();
extern "C" FILE *yyin;
extern int line_num;

// Output files declarations
std::ofstream token_file;
std::ofstream log_file;
std::ofstream bytecode_file;

int vars_cnt = 1;
int constants_cnt = 1;
int program_counter = 0;
typedef enum {I_TYPE, F_TYPE, B_TYPE} type;
map<string, pair<type, int>> symbol_table;
map<string, int> constant_table;

// Function to handle parsing errors
void yyerror(const char *s);

// Functions prototypes
void add_to_symb_table(string sym_name, type sym_type);
void add_to_const_table(string const_name);
bool same_type(int type_1, int type_2);
%}

// Bison fundamentally works by asking flex to get the next token, which it
// returns as an object of type "yystype".  But tokens could be of any
// arbitrary data type!  So we deal with that in Bison by defining a C union
// holding each of the types of tokens that Flex could return, and have Bison
// use that union instead of "int" for the definition of "yystype"
%union {
	int ival;
	float fval;
    bool bval;
  	char *int_literal;
  	char *float_literal;
  	char *id_name;
  	char *oper_name;
    int declaration_type;
}

// Define the "terminal symbol" token types I'm going to use (in CAPS
// by convention), and associate each with a field of the union:
%token <int_literal> INT
%token <float_literal> FLOAT
%token TOK_INT
%token TOK_FLOAT
%token TOK_BOOLEAN
%token TOK_IF
%token TOK_WHILE
%token TOK_ELSE
%token TOK_ASSIGN
%token <id_name> TOK_ID
%token <oper_name> TOK_RELOP
%token <oper_name> TOK_ADDOP
%token <oper_name> TOK_MULOP
%token UNRECOGNIZED_TOKEN

%type <declaration_type> primitive_type;
%type <declaration_type> expression;
%type <declaration_type> simple_expression;
%type <declaration_type> term;
%type <declaration_type> factor;

%start method_body

%%
// Grammar
method_body: statement_list;

statement_list: statement | statement_list statement;

statement: declaration | if | while | assignment;

declaration: primitive_type TOK_ID ';'
    {
        // Declaring a variable named "TOK_ID" with type primitive_type.
  		string name($2);
        add_to_symb_table(name, (type)$1);
        bytecode_file << "ldc\t#" << constant_table["0"] << endl;
        bytecode_file << "istore\t" << symbol_table[name].second << endl;
    };

primitive_type: TOK_INT
                {
                    $$ = type::I_TYPE;
                } 
                | TOK_FLOAT 
                {
                    $$ = type::F_TYPE;
                }    
                | TOK_BOOLEAN
                {
					$$ = type::B_TYPE;
                };

if: TOK_IF '(' boolean_expression
                {
                    // Here I've just wrote the relop bytecode
                    
                } 
                ')' '{' statement '}' TOK_ELSE '{' statement '}';

while: TOK_WHILE '(' boolean_expression ')' '{' statement '}';

assignment: TOK_ID TOK_ASSIGN expression ';'
            {
                // istore/fstore id.index
				string id_name($1);
  				if (symbol_table.find(id_name) != symbol_table.end()) {
                   if (symbol_table[id_name].first == $3) {
                     if ($3 == type::I_TYPE) {
                       bytecode_file << "istore\t" << symbol_table[id_name].second << endl;
                     } else if ($3 == type::F_TYPE) {
                       bytecode_file << "fstore\t" << symbol_table[id_name].second << endl;
                     }
                   } else {
                     string err_msg = "Type mismatch!";
                     yyerror(err_msg.c_str());
                   }
                } else {
                  string err_msg = "Variable: " + id_name + " has not been declared!";
                  yyerror(err_msg.c_str());
                }
            };

expression: simple_expression
			{
            	$$ = $1;
            };

boolean_expression: simple_expression TOK_RELOP simple_expression
                    {
            	        $$ = type::B_TYPE;
                        // TODO: write bytecode for relops
                        // Here top 2 of the stack are the 2 values to operate on
                
                    };


simple_expression: term
					{
                    	$$ = $1;
                    }
                    | simple_expression TOK_ADDOP term
                    {
                    	// ASSUMING THAT SIMPLE_EXPRESSION AND TERM CAN'T BE BOOLEANS FOR NOW
                        if (same_type($1, $3)) {
                        	if ($1 == type::F_TYPE) {
                            	$$ = type::F_TYPE;
                            	bytecode_file << "f" + instr_list[string($2)] << endl;
                            } else if ($1 == type::I_TYPE) {
                            	$$ = type::I_TYPE;
                            	bytecode_file << "i" + instr_list[string($2)] << endl;
                            }
                        } else {
                        	string err_msg = "Arithmetic operation on two operands with different types!";
                  			yyerror(err_msg.c_str());
                        }  
                    };

term: factor 
		{
        	$$ = $1;
        }
      	| term TOK_MULOP factor 
      	{
        	if (same_type($1, $3)) {
            	if ($1 == type::F_TYPE) {
                	$$ = type::F_TYPE;
                    bytecode_file << "f" + instr_list[string($2)] << endl;
                } else if ($1 == type::I_TYPE) {
                    $$ = type::I_TYPE;
                    bytecode_file << "i" + instr_list[string($2)] << endl;
                }
            } else {
            	string err_msg = "Multiplication operation on two operands with different types!";
                yyerror(err_msg.c_str());
            }
        }
      	;

factor: TOK_ID 
        {
        	string id_name($1);      
        	if (symbol_table.find(id_name) != symbol_table.end()) {
            	$$ = symbol_table[$1].first;
                if (symbol_table[id_name].first == type::I_TYPE) {
                    bytecode_file << "iload\t" << symbol_table[id_name].second << endl;
                } else if (symbol_table[id_name].first == type::F_TYPE) {
                    bytecode_file << "fload\t" << symbol_table[id_name].second << endl;
                }
            } else {
                string err_msg = "Variable: " + id_name + " has not been declared!";
                yyerror(err_msg.c_str());
            }
        }
        | INT
        {   
        	string const_str($1);
            $$ = type::I_TYPE;
        	if (constant_table.find(const_str) == constant_table.end()) {
            	add_to_const_table(const_str);
            }
            bytecode_file << "ldc\t#" << constant_table[const_str] << endl;
        }
        | FLOAT 
        {
            string const_str($1);
            $$ = type::F_TYPE;
        	if (constant_table.find(const_str) == constant_table.end()) {
            	add_to_const_table(const_str);
            }
            bytecode_file << "ldc\t#" << constant_table[const_str] << endl;
        }
        | '(' expression ')' 
        {
          	$$ = $2;
        };
%%

int main(int argc, char **argv) {
    
    add_to_const_table (string("0"));

	token_file.open("token-file.txt");
	log_file.open("compiler.log");
    bytecode_file.open("bytecode.j");


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
	cout << "EEK, parse error on line " << line_num << "!  Message: " << s << endl;
	exit(-1); // Remove this to allow panic error recovery to keep execution
}

void add_to_symb_table(string sym_name, type sym_type) {
    if (symbol_table.find(sym_name) != symbol_table.end()) {
      	string err_msg = "Variable: " + sym_name + " has been declared!";
        yyerror(err_msg.c_str());
    } else {
        symbol_table[sym_name] = make_pair(sym_type, vars_cnt++);
    }
}

void add_to_const_table(string const_str) {
    if (constant_table.find(const_str) == constant_table.end()) {
        constant_table[const_str] = constants_cnt++;
    }
}

bool same_type(int type_1, int type_2) {
  return type_1 == type_2;
}