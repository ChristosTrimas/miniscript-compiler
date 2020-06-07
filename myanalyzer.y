%{

#include <stdlib.h>
#include <stdarg.h>
#include <stdio.h>
#include <string.h>   
#include "cgen.h"
#include "mslib.h"

extern int yylex(void);

extern int lineNum;

%}

%union
{
  char* crepr;
   int num;
}

//tokens are terminals, types are non terminals

%token <crepr> TOKEN_IDENTIFIER
%token <crepr> TOKEN_NUM
%token <crepr> TOKEN_REAL
%token <crepr> TOKEN_STRING


//keywords

%token KEYWORD_NUMBER
%token KEYWORD_BOOLEAN
%token KEYWORD_STRING
%token KEYWORD_VOID
%token KEYWORD_TRUE
%token KEYWORD_FALSE
%token KEYWORD_VAR
%token KEYWORD_CONST
%token KEYWORD_IF
%token KEYWORD_ELSE
%token KEYWORD_FOR
%token KEYWORD_WHILE
%token KEYWORD_FUNCTION
%token KEYWORD_BREAK
%token KEYWORD_CONTINUE
%token KEYWORD_NOT
%token KEYWORD_AND
%token KEYWORD_OR
%token KEYWORD_RETURN
%token KEYWORD_NULL
%token KEYWORD_START

%token ASSIGN_OP
%token COLON
%token SEMICOLON
%token LEFT_PARENTHESIS
%token RIGHT_PARENTHESIS
%token LEFT_BRACKET
%token RIGHT_BRACKET
%token LEFT_CURLY_BRACKET
%token RIGHT_CURLY_BRACKET
%token COMMA

%token PLUS_OP
%token MINUS_OP
%token MULT_OP
%token DIV_OP
%token MOD_OP
%token SQUARE_OP

%token EQUAL
%token NOT_EQUAL
%token LESS
%token LESS_EQUAL

//priorities
%right KEYWORD_NOT
%right SQUARE_OP

%left MULT_OP
%left DIV_OP
%left MOD_OP
%left PLUS_OP
%left MINUS_OP
%left EQUAL
%left NOT_EQUAL
%left LESS
%left LESS_EQUAL
%left KEYWORD_AND
%left KEYWORD_OR
%left ASSIGN_OP

%type <crepr> main_body
%type <crepr> func_main
%type <crepr> func
%type <crepr> outside_decl
%type <crepr> function_list
%type <crepr> return_state
%type <crepr> parameters_list
%type <crepr> parameters
%type <crepr> pos_statements
%type <crepr> list_statements
%type <crepr> statement_declaration
%type <crepr> statements
%type <crepr> if_statement
%type <crepr> else_statement
%type <crepr> for_statement
%type <crepr> while_statement
%type <crepr> function
%type <crepr> return
%type <crepr> function_variable_list
%type <crepr> statement_cont
%type <crepr> expression
%type <crepr> table_exp
%type <crepr> profunc_call
%type <crepr> declaration
%type <crepr> var_body
%type <crepr> var_list
%type <crepr> var_initialize
%type <crepr> var_ident
%type <crepr> data_type
%type <crepr> type help

%type <crepr> input
%start input

%%

input: 
		main_body 
			{
				if(yyerror_count==0) {
					printf("\n");
					printf("/* -======= Executing... =======*/\n");
					puts(c_prologue);
					printf("%s", $1);
				}
				else {
					yyerror("\n", lineNum);
				}
			};

main_body : func_main	{$$ = template("%s\n",$1);}
		  | func func_main	{ $$ = template("%s\n%s\n",$1,$2); }
		  | func_main func  { $$ = template("%s\n%s\n",$1,$2); }
		  | func func_main func 	{ $$ = template("%s\n%s\n%s\n",$1,$2,$3); };

func : outside_decl 	{ $$ = template("%s\n",$1); }
	 | func outside_decl { $$ = template("%s\n%s\n",$1,$2); };

outside_decl : declaration { $$ = template("%s",$1); } 
			 | function_list  { $$ = template("%s",$1); };

function_list : KEYWORD_FUNCTION var_ident LEFT_PARENTHESIS parameters_list RIGHT_PARENTHESIS COLON return_state LEFT_CURLY_BRACKET pos_statements RIGHT_CURLY_BRACKET SEMICOLON { $$ = template("%s %s(%s) {\n%s\n};\n",$7, $2, $4, $9); };

return_state : type { $$ = template("%s", $1); }
			 | LEFT_BRACKET RIGHT_BRACKET type { $$ = template("%s*", $3); };

parameters_list   : %empty              { $$ = template("");}
				  | parameters COMMA parameters COLON type COMMA parameters_list     { $$ = template("%s %s ,%s %s, %s",$5,$1,$5,$3,$7); }
				  | parameters COMMA parameters COLON type    { $$ = template("%s %s, %s %s", $5,$1,$5,$3); }
				  | parameters COLON type COMMA parameters_list     { $$ = template("%s %s , %s", $3,$1,$5); }
				  | parameters COLON type     { $$ = template("%s %s", $3,$1); };

parameters   : TOKEN_IDENTIFIER { $$ = template("%s", $1); }
  			 | TOKEN_IDENTIFIER LEFT_BRACKET RIGHT_BRACKET { $$ = template("%s[]", $1); };

func_main : KEYWORD_FUNCTION KEYWORD_START LEFT_PARENTHESIS RIGHT_PARENTHESIS COLON KEYWORD_VOID LEFT_CURLY_BRACKET pos_statements RIGHT_CURLY_BRACKET{ $$ = template("void main(){\n%s}",$8); } ;

pos_statements : %empty	{$$ = template("");}
				|list_statements {$$ = template("%s",$1);};

list_statements : statement_declaration	{$$ = template("\t%s\n", $1); }
				| list_statements statement_declaration { $$ = template("%s\n\t%s\n", $1, $2); };

statement_declaration : declaration   { $$ = template("%s",$1); }
					  | statements 	  { $$ = template("%s",$1); }
					  | statements SEMICOLON;

statements  : var_ident ASSIGN_OP expression   { $$ = template("%s = %s;",$1, $3); }
			| var_ident ASSIGN_OP function   { $$ = template("%s = %s",$1, $3); }
			| if_statement  					{ $$ = template("%s",$1); }
			| for_statement SEMICOLON					{ $$ = template("%s",$1); }
			| while_statement SEMICOLON					{ $$ = template("%s",$1); }
			| function SEMICOLON						{ $$ = template("%s",$1); }
			| return SEMICOLON							{ $$ = template("%s",$1); };

if_statement : KEYWORD_IF LEFT_PARENTHESIS expression RIGHT_PARENTHESIS statement_cont SEMICOLON{ $$ = template("if (%s)  {\n%s\n} ", $3, $5); }
			 | KEYWORD_IF LEFT_PARENTHESIS expression RIGHT_PARENTHESIS LEFT_CURLY_BRACKET statements pos_statements RIGHT_CURLY_BRACKET SEMICOLON{ $$ = template("if (%s)  {\n%s\n%s\n} ", $3, $6,$7); }
			 | if_statement else_statement { $$ = template("%s %s", $1, $2); };	

else_statement : KEYWORD_ELSE LEFT_CURLY_BRACKET statements pos_statements RIGHT_CURLY_BRACKET SEMICOLON{ $$ = template("else {\n%s\n%s\n}", $3,$4); }
			   | KEYWORD_ELSE KEYWORD_IF LEFT_PARENTHESIS expression RIGHT_PARENTHESIS statement_cont SEMICOLON{ $$ = template("else if (%s)  {\n%s\n}", $4, $6); };

for_statement : KEYWORD_FOR LEFT_PARENTHESIS statements SEMICOLON expression SEMICOLON statement_cont RIGHT_PARENTHESIS statements pos_statements { $$ = template("for (%s; %s;%s++){\n%s\n%s\n}", $3, $5, $7, $9,$10);};

while_statement : KEYWORD_WHILE LEFT_PARENTHESIS expression RIGHT_PARENTHESIS LEFT_CURLY_BRACKET statements pos_statements RIGHT_CURLY_BRACKET {$$ = template("while(%s) {\n%s\n%s\n}", $3, $6,$7);};

function : TOKEN_IDENTIFIER LEFT_PARENTHESIS function_variable_list RIGHT_PARENTHESIS  {$$ = template("%s(%s);\n",$1,$3);};

return  : KEYWORD_RETURN				{ $$ = template("return;"); }
		| KEYWORD_RETURN expression	{ $$ = template("return %s;", $2); };  

function_variable_list    : %empty                         { $$ = template("");}
						  | function_variable_list COMMA expression     { $$ = template("%s , %s", $1,$3); }
						  | expression                            { $$ = template("%s", $1);};

statement_cont: //I created only for if,  else , while, for 
				KEYWORD_RETURN				{ $$ = template("return;"); }
		 	  | KEYWORD_RETURN expression	{ $$ = template("return %s;", $2); }  
			  | var_ident ASSIGN_OP expression	 			{ $$ = template("%s = %s;", $1, $3); }
			  | var_ident ASSIGN_OP LEFT_PARENTHESIS type RIGHT_PARENTHESIS  expression	 			{ $$ = template("%s = (%s)%s;", $1, $4,$6); }
	     	  | var_ident table_exp ASSIGN_OP expression	{ $$ = template("%s%s = %s;", $1, $2, $4); }  
	     	  | var_ident PLUS_OP ASSIGN_OP expression	 		{ $$ = template("%s += %s;", $1, $4); }
			  | var_ident MINUS_OP ASSIGN_OP expression	 	{ $$ = template("%s -= %s;", $1, $4); }
	     	  | var_ident table_exp PLUS_OP ASSIGN_OP expression  	{ $$ = template("%s%s += %s;", $1, $2, $5); }
			  | var_ident table_exp MINUS_OP ASSIGN_OP expression 	{ $$ = template("%s%s -= %s;", $1, $2, $5); }			  
			  | KEYWORD_BREAK	{ $$ = template("break;"); }
          	  | KEYWORD_CONTINUE {$$ = template("continue;"); }
			  | profunc_call  							{ $$ = template("%s;", $1); };


help : TOKEN_NUM
	 | TOKEN_NUM SEMICOLON
	 | TOKEN_STRING		{ $$ = template("%s", $1); }; ;

expression: help 				
          | TOKEN_REAL
          | var_ident
          | var_ident table_exp					{ $$ = template("%s%s", $1, $2); }
          | profunc_call			
          | expression KEYWORD_NOT expression 	{ $$ = template("%s not %s", $1, $3); }
          | LEFT_PARENTHESIS expression RIGHT_PARENTHESIS 	{ $$ = template("(%s)", $2); }
          | expression SQUARE_OP expression { $$ = template("%s ** %s", $1, $3); }
          | expression MULT_OP expression 	{ $$ = template("%s * %s", $1, $3); }
		  | expression DIV_OP expression 	{ $$ = template("%s / %s", $1, $3); }
		  | expression MOD_OP expression 	{ $$ = template("%s %% %s", $1, $3); }		  
          | PLUS_OP expression 				{ $$ = template("+ %s", $2); }
		  | MINUS_OP expression 			{ $$ = template("- %s", $2); }
		  | expression PLUS_OP expression 	{ $$ = template("%s + %s", $1, $3); }
		  | expression MINUS_OP expression 	{ $$ = template("%s - %s", $1, $3); }
		  | expression EQUAL expression 			{ $$ = template("%s == %s", $1, $3); }
		  | expression NOT_EQUAL expression 	{ $$ = template("%s != %s", $1, $3); }
		  | expression LESS expression 	{ $$ = template("%s < %s", $1, $3); }
		  | expression LESS_EQUAL expression 	{ $$ = template("%s <= %s", $1, $3); }
		  | expression KEYWORD_AND expression 	{ $$ = template("%s && %s", $1, $3); }
		  | expression KEYWORD_OR expression 	{ $$ = template("%s || %s", $1, $3); }
          | KEYWORD_FALSE	{ $$ = template("0"); }
          | KEYWORD_TRUE 	{ $$ = template("1"); };

table_exp: LEFT_BRACKET expression RIGHT_BRACKET { $$ = template("[%s]",  $2); }
		 | table_exp LEFT_BRACKET expression RIGHT_BRACKET {  $$ = template("%s [%s]", $1, $3); };

profunc_call: TOKEN_IDENTIFIER LEFT_PARENTHESIS expression RIGHT_PARENTHESIS 	{ $$ = template("%s(%s)", $1, $3); };

declaration : KEYWORD_VAR var_body		{ $$ = template("%s", $2); }
			| KEYWORD_CONST var_body	{ $$ = template("const %s", $2); };

var_body : var_list COLON type SEMICOLON {$$ = template("%s %s;", $3,$1);};

var_list : var_list COMMA var_initialize { $$ = template("%s, %s", $1, $3 );}
		 | var_initialize ;

var_initialize : var_ident
			   | var_ident ASSIGN_OP data_type	{ $$ = template("%s = %s", $1, $3); };

var_ident : TOKEN_IDENTIFIER { $$ = template("%s", $1); }
	      | TOKEN_IDENTIFIER LEFT_BRACKET TOKEN_NUM RIGHT_BRACKET { $$ = template("%s[%s]", $1, $3); };

data_type : TOKEN_IDENTIFIER			{ $$ = template("%s", $1); }
		  | TOKEN_NUM					{ $$ = template("%s", $1); }
		  | TOKEN_REAL					{ $$ = template("%s", $1); }
		  | TOKEN_STRING				{ $$ = template("%s", $1); }
		  | MINUS_OP TOKEN_IDENTIFIER 	{ $$ = template("-%s", $2); }
		  | MINUS_OP TOKEN_NUM		  	{ $$ = template("-%s", $2); }
		  | MINUS_OP TOKEN_REAL 		{ $$ = template("-%s", $2); }; 
		  //check for boolean later

type : KEYWORD_NUMBER			{ $$ = template("%s", "double"); }
	 | KEYWORD_BOOLEAN			{ $$ = template("%s", "int"); }
	 | KEYWORD_STRING			{ $$ = template("%s", "char*"); };

%%

int main ()
{

 if (yyparse()==0) {
 	if (yyerror_count==0)
 		printf("\n//===== Accepted =====\n");
 	else {
 		printf("\n\n===== Rejected =====\n\n"); // due to lexical error
  	}
 }
 else {
 	printf("\n\n===== Syntax error in line %d =====", lineNum);
 	printf("\n\n===== Rejected ======\n\n"); 	  // due to syntax error
 } 
}
