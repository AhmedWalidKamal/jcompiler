parser: lex.yy.c parser_spec.tab.c parser_spec.tab.h
	g++ parser_spec.tab.c lex.yy.c -lfl -o parser
parser_spec.tab.c parser_spec.tab.h: bison/parser_spec.y
	bison -d bison/parser_spec.y
lex.yy.c: flex/lexical_spec.l parser_spec.tab.h
	flex flex/lexical_spec.l

clean:
	rm parser parser_spec.tab.c parser_spec.tab.h lex.yy.c

