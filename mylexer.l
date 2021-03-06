%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "cgen.h"
	#include "myanalyzer.tab.h"
	int lineNum = 1;
%}

ID [a-zA-Z_][0-9a-zA-Z_]*
DIGIT  [0-9]
NUMBER  {DIGIT}{DIGIT}*
DECIMAL ("."{NUMBER})|({NUMBER}("."{NUMBER}?)?)
REAL    {DECIMAL}([eE][+-]?{NUMBER})?
STRING   ('[^'\n]*')|(\"(\\.|[^"\\])*\")    

%x comment

%%

number       { printf("//Token KEYWORD_NUMBER:\t%s\n", yytext); return KEYWORD_NUMBER;};
boolean		 { printf("//Token KEYWORD_BOOLEAN:\t%s\n", yytext); return KEYWORD_BOOLEAN;};
string		 { printf("//Token KEYWORD_STRING:\t%s\n", yytext); return KEYWORD_STRING;};
void		 { printf("//Token KEYWORD_VOID:\t%s\n", yytext); return KEYWORD_VOID;};
true		 { printf("//Token KEYWORD_TRUE:\t%s\n", yytext); return KEYWORD_TRUE;};
false		 { printf("//Token KEYWORD_FALSE:\t%s\n", yytext); return KEYWORD_FALSE;};
var		 { printf("//Token KEYWORD_VAR:\t%s\n", yytext); return KEYWORD_VAR;};
const		 { printf("//Token KEYWORD_CONST:\t%s\n", yytext); return KEYWORD_CONST;};
if		 { printf("//Token KEYWORD_IF:\t%s\n", yytext); return KEYWORD_IF;};
else		 { printf("//Token KEYWORD_ELSE:\t%s\n", yytext); return KEYWORD_ELSE;};
for		 { printf("//Token KEYWORD_FOR:\t%s\n", yytext); return KEYWORD_FOR;};
while		 { printf("//Token KEYWORD_WHILE:\t%s\n", yytext); return KEYWORD_WHILE;};
function		 { printf("//Token KEYWORD_FUNCTION:\t%s\n", yytext); return KEYWORD_FUNCTION;};
break		 { printf("//Token KEYWORD_BREAK:\t%s\n", yytext); return KEYWORD_BREAK;};
continue		 { printf("//Token KEYWORD_CONTINUE:\t%s\n", yytext); return KEYWORD_CONTINUE;};
not		 { printf("//Token KEYWORD_NOT:\t%s\n", yytext); return KEYWORD_NOT;};
and		 { printf("//Token KEYWORD_AND:\t%s\n", yytext); return KEYWORD_AND;};
or		 { printf("//Token KEYWORD_OR:\t%s\n", yytext); return KEYWORD_OR;};
return		 { printf("//Token KEYWORD_RETURN:\t%s\n", yytext); return KEYWORD_RETURN;};
null		 { printf("//Token KEYWORD_NULL:\t%s\n", yytext); return KEYWORD_NULL;};
start		 { printf("//Token KEYWORD_START:\t%s\n", yytext); return KEYWORD_START;};


{ID}        { yylval.crepr = strdup(yytext); printf("//Token IDENTIFIER: \t%s\n", yytext);return TOKEN_IDENTIFIER; }
{NUMBER}    { yylval.crepr = strdup(yytext); printf("//Token NUMBER: \t%s\n", yytext); return TOKEN_NUM; }
{REAL}      { yylval.crepr = strdup(yytext); printf("//Token REAL: \t%s\n", yytext); return TOKEN_REAL; }
{STRING}    { yylval.crepr = strdup(yytext); printf("//Token TOKEN_STRING: \t%s\n", yytext); return TOKEN_STRING; }

"="        { printf("//Token ASSIGN_OP:\t%s\n", yytext); return ASSIGN_OP;};

":"        { printf("//Token COLON:\t%s\n", yytext); return COLON;};
";"        { printf("//Token SEMICOLON:\t%s\n", yytext); return SEMICOLON;};
"("        { printf("//Token LEFT_PARENTHESIS:\t%s\n", yytext); return LEFT_PARENTHESIS;};
")"        { printf("//Token RIGHT_PARENTHESIS:\t%s\n", yytext); return RIGHT_PARENTHESIS;};
"["        { printf("//Token LEFT_BRACKET:\t%s\n", yytext); return LEFT_BRACKET;};
"]"        { printf("//Token RIGHT_BRACKET:\t%s\n", yytext); return RIGHT_BRACKET;};
"{"        { printf("//Token LEFT_CURLY_BRACKET:\t%s\n", yytext); return LEFT_CURLY_BRACKET;};
"}"        { printf("//Token RIGHT_CURLY_BRACKET:\t%s\n", yytext); return RIGHT_CURLY_BRACKET;};
","        { printf("//Token COMMA:\t%s\n", yytext); return COMMA;};


"+"        { printf("//Token PLUS_OP:\t%s\n", yytext); return PLUS_OP;};
"-"        { printf("//Token MINUS_OP:\t%s\n", yytext); return MINUS_OP;};
"*"        { printf("//Token MULT_OP:\t%s\n", yytext); return MULT_OP;};
"/"        { printf("//Token DIV_OP:\t%s\n", yytext); return DIV_OP;};
"%"        { printf("//Token MOD_OP:\t%s\n", yytext); return MOD_OP;};
"**"        { printf("//Token SQUARE_OP:\t%s\n", yytext); return SQUARE_OP;};

"=="        { printf("//Token EQUAL:\t%s\n", yytext); return EQUAL;};
"!="        { printf("//Token NOT_EQUAL:\t%s\n", yytext); return NOT_EQUAL;};
"<"        { printf("//Token LESS:\t%s\n", yytext); return LESS;};
"<="        { printf("//Token LESS_EQUAL:\t%s\n", yytext); return LESS_EQUAL;};



"//"[^\n]*  	/* eat line comments */

"/*"					BEGIN(comment);
<comment>[^*\n]*        /* eat anything that's not a '*' */
<comment>"*"+[^*/\n]*   /* eat up '*'s not followed by ')'s */
<comment>\n             ++lineNum;
<comment>"*"+"/"        BEGIN(INITIAL);


[ \r\t]				/* skip whitespace */
\n 						++lineNum;
<<EOF>> 			return EOF;

.        { printf("\n\n/** Lexical error in line %d **/\n", lineNum); 
		   yyerror("Unrecognised literal : '%s' \n", yytext); }

%%
