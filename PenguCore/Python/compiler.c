#include <stdio.h>
#include <string.h>
#include "lexer.h"  // Incluir el encabezado de lexer
#include "parser.h"  // Incluir el encabezado de parser

int main() {
    const char *source_code = "def func(x, y):\n    if x > y:\n        return x";
    
    printf("Tokenizando el c�digo...\n");
    tokenize(source_code);  // Tokenizaci�n
    
    Token tokens[MAX_TOKENS] = {
        {KEYWORD, "def"},
        {IDENTIFIER, "func"},
        {OPERATOR, "("},
        {IDENTIFIER, "x"},
        {OPERATOR, ","},
        {IDENTIFIER, "y"},
        {OPERATOR, ")"},
        {OPERATOR, ":"}
    };
    
    printf("\nParseando los tokens...\n");
    parse(tokens, 8);  // Parseo
    
    return 0;
}
