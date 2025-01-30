#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#define MAX_TOKENS 100
#define MAX_TOKEN_SIZE 100

typedef enum {
    KEYWORD,
    IDENTIFIER,
    INTEGER,
    OPERATOR,
    UNKNOWN
} TokenType;

typedef struct {
    TokenType type;
    char value[MAX_TOKEN_SIZE];
} Token;

// Parsear el c�digo (en este caso, solo funciones simples)
void parse(Token *tokens, int token_count) {
    for (int i = 0; i < token_count; i++) {
        if (tokens[i].type == KEYWORD && strcmp(tokens[i].value, "def") == 0) {
            printf("Encontrada definici�n de funci�n: %s\n", tokens[i + 1].value);
        }
    }
}

int main() {
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
    
    parse(tokens, 8);
    
    return 0;
}
