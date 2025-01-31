#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "lexer.h"  // Incluir el archivo de encabezado

int is_keyword(const char *word) {
    return strcmp(word, "def") == 0 || strcmp(word, "if") == 0 || strcmp(word, "else") == 0;
}

void tokenize(const char *source_code) {
    char current[MAX_TOKEN_SIZE];
    int current_length = 0;
    int i = 0;
    
    while (source_code[i] != '\0') {
        char c = source_code[i];
        
        if (isspace(c)) {
            if (current_length > 0) {
                current[current_length] = '\0';
                printf("Token: %s\n", current);
                current_length = 0;
            }
        } else if (isalnum(c) || c == '_') {
            current[current_length++] = c;
        } else if (c == '+' || c == '-' || c == '*' || c == '/' || c == '=' || c == '(' || c == ')') {
            if (current_length > 0) {
                current[current_length] = '\0';
                printf("Token: %s\n", current);
                current_length = 0;
            }
            printf("Token: %c\n", c);
        } else {
            current[current_length++] = c;
        }
        
        i++;
    }
    
    if (current_length > 0) {
        current[current_length] = '\0';
        printf("Token: %s\n", current);
    }
}
