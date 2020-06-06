//Token KEYWORD_CONST:	const
//Token IDENTIFIER: 	message
//Token ASSIGN_OP:	=
//Token TOKEN_STRING: 	"Hello world!\n"
//Token COLON:	:
//Token KEYWORD_STRING:	string
//Token SEMICOLON:	;
//Token KEYWORD_FUNCTION:	function
//Token KEYWORD_START:	start
//Token LEFT_PARENTHESIS:	(
//Token RIGHT_PARENTHESIS:	)
//Token COLON:	:
//Token KEYWORD_VOID:	void
//Token LEFT_CURLY_BRACKET:	{
//Token IDENTIFIER: 	writeString
//Token LEFT_PARENTHESIS:	(
//Token IDENTIFIER: 	message
//Token RIGHT_PARENTHESIS:	)
//Token SEMICOLON:	;
//Token RIGHT_CURLY_BRACKET:	}

/* -======= Executing... =======*/
#include "mslib.h"


const char* message = "Hello world!\n";

void main(){
	writeString(message);

}

//===== Accepted =====
