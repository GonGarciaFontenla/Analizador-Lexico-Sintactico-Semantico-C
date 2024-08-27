%{  
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <general.h>

extern int yylex(void);

void yyerror(const char*);
void menu(void); 

%}

%define parse.error verbose

%locations

%union {
    char* string_type;
    int int_type;
    double double_type;
}

%token <string_type> IDENTIFICADOR
%token <int_type> CONSTANTE
%token <string_type> LITERAL_CADENA
%token CHAR INT FLOAT DOUBLE
%token "=" "+=" "-=" "*=" "/="
%token "?" ":"
%token "+" "-" "*" "/" "&&" "||" "==" "!=" "<" ">" "<=" ">="
%token "(" ")" "[" "]" "++" "--" "&" "!" SIZEOF

%type <int_type> expresion expAsignacion expCondicional expOr expAnd expIgualdad expRelacional expAditiva expMultiplicativa expUnaria expPostfijo listaArgumentos nombreTipo

%start expresion

%right "=" "+=" "-=" "*=" "/="
%right "?" ":"
%left "||"
%left "&&"
%left "==" "!="  
%left "<" ">" ">=" "<="  
%left "+" "-"  
%left "*" "/" "%"
%right "!" "&"
%nonassoc "[" "]"
%nonassoc "(" ")" 
%nonassoc IDENTIFICADOR CONSTANTE LITERAL_CADENA "(" expresion ")"
%nonassoc CHAR INT FLOAT DOUBLE


%%

expresion
    :expAsignacion
    ;

expAsignacion
    :expCondicional
    |expUnaria operAsignacion expAsignacion
    ;

operAsignacion
    :"="
    | "+="
    | "-="
    | "*="
    | "/="
    ;

expCondicional
    :expOr
    | expOr "?" expresion ":" expCondicional
    ;

expOr
    :expAnd
    | expOr "||" expAnd
    ;

expAnd
    :expIgualdad
    | expAnd "&&" expIgualdad
    ;

expIgualdad
    :expRelacional
    | expIgualdad "==" expRelacional
    | expIgualdad "!=" expRelacional
    ;

expRelacional
    :expAditiva
    | expRelacional "<" expAditiva
    | expRelacional ">" expAditiva
    | expRelacional "<=" expAditiva
    | expRelacional ">=" expAditiva
    ;

expAditiva
    :expMultiplicativa
    | expAditiva "+" expMultiplicativa
    | expAditiva "-" expMultiplicativa
    ;

expMultiplicativa
    :expUnaria
    | expMultiplicativa "*" expUnaria
    | expMultiplicativa "/" expUnaria
    ;

expUnaria
    :expPostfijo
    | "++" expUnaria
    | "--" expUnaria
    | expUnaria "++"
    | expUnaria "--"
    | operUnario expUnaria
    | SIZEOF "(" nombreTipo ")"
    ;

operUnario
    :"&"
    | "*"
    | "-"
    | "!"
    ;

expPostfijo
    :expPrimaria
    | expPostfijo "[" expresion "]"
    | expPostfijo "(" listaArgumentos ")"
    ;

listaArgumentos
    :expAsignacion
    | listaArgumentos "," expAsignac
    ;

expPrimaria
    :IDENTIFICADOR
    | CONSTANTE
    | LITERAL_CADENA
    | "(" expresion ")"
    ;

nombreTipo
    :CHAR
    | INT
    | FLOAT
    | DOUBLE
    ;

%%

int main(void)
{
    inicializarUbicacion();

    #if YYDEBUG
        yydebug = 1;
    #endif

    while(1)
    {
        printf("Ingrese una expresion:\n");
        printf("(La función yyparse ha retornado con valor: %d)\n\n", yyparse());
    }

    pausa();
    return 0;
}

/* Definición de la función yyerror para reportar errores */
void yyerror(const char* literalCadena)
{
    fprintf(stderr, "Bison: %d:%d: %s\n", yylloc.first_line, yylloc.first_column, literalCadena);
}