#ifndef LEXER_H
#define LEXER_H

#include "token.h"


int is_keyword(const char *word);
void tokenize(const char *source_code);

#endif 
