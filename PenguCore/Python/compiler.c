#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include "lexer.c"
#include "parser.c"

int main() {
    const char *source_code = "def func(x, y):\n    if x > y:\n        return x";
    
    printf("Tokenizando el c�digo...\n");
    tokenize(source_code);  
    
    printf("\nParseando los tokens...\n");
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
    
    parse(tokens, 8);  // Parseo
    
    return 0;
}
