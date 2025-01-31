#ifndef TOKEN_H
#define TOKEN_H

#define MAX_TOKEN_SIZE 100
#define MAX_TOKENS 100

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

#endif 
