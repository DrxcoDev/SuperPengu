#include <stdio.h>
#include <string.h>
#include "parser.h"  // Incluir el archivo de encabezado

void parse(Token *tokens, int token_count) {
    for (int i = 0; i < token_count; i++) {
        if (tokens[i].type == KEYWORD && strcmp(tokens[i].value, "def") == 0) {
            printf("Encontrada definici�n de funci�n: %s\n", tokens[i + 1].value);
        }
    }
}
