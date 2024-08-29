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

%error-verbose

%locations

%union {
    char* string_type;
    int int_type;
    double double_type;
}

%token <string_type> IDENTIFICADOR
%token <int_type> ENTERO
%token <double_type> NUM
%token <string_type> LITERAL_CADENA
%token <string_type> PALABRA_RESERVADA
%token <int_type> CONSTANTE
%token CHAR INT FLOAT DOUBLE SIZEOF

%type <int_type> expresion expAsignacion expCondicional expOr expAnd expIgualdad expRelacional expAditiva expMultiplicativa expUnaria expPostfijo
%type <int_type> operAsignacion operUnario nombreTipo
%type <int_type> listaArgumentos expPrimaria

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

%%

expresion
    : expAsignacion
    ;

expAsignacion
    : expCondicional
    | expUnaria operAsignacion expAsignacion { $$ = $3; }
    ;

operAsignacion
    : "="  { $$ = '='; }
    | "+=" { $$ = '+'; }
    | "-=" { $$ = '-'; }
    | "*=" { $$ = '*'; }
    | "/=" { $$ = '/'; }
    ;

expCondicional
    : expOr
    | expOr "?" expresion ":" expCondicional { $$ = $3; }
    ;

expOr
    : expAnd
    | expOr "||" expAnd { $$ = $1 || $3; }
    ;

expAnd
    : expIgualdad
    | expAnd "&&" expIgualdad { $$ = $1 && $3; }
    ;

expIgualdad
    : expRelacional
    | expIgualdad "==" expRelacional { $$ = $1 == $3; }
    | expIgualdad "!=" expRelacional { $$ = $1 != $3; }
    ;

expRelacional
    : expAditiva
    | expRelacional "<" expAditiva { $$ = $1 < $3; }
    | expRelacional ">" expAditiva { $$ = $1 > $3; }
    | expRelacional "<=" expAditiva { $$ = $1 <= $3; }
    | expRelacional ">=" expAditiva { $$ = $1 >= $3; }
    ;

expAditiva
    : expMultiplicativa
    | expAditiva "+" expMultiplicativa { $$ = $1 + $3; }
    | expAditiva "-" expMultiplicativa { $$ = $1 - $3; }
    ;

expMultiplicativa
    : expUnaria
    | expMultiplicativa "*" expUnaria { $$ = $1 * $3; }
    | expMultiplicativa "/" expUnaria { $$ = $1 / $3; }
    ;

expUnaria
    : expPostfijo
    | "++" expUnaria { $$ = ++$2; }
    | "--" expUnaria { $$ = --$2; }
    | expUnaria "++" { $$ = $1++; }
    | expUnaria "--" { $$ = $1--; }
    | operUnario expUnaria { $$ = -$2; }
    | SIZEOF "(" nombreTipo ")" { $$ = sizeof($3); }
    ;

operUnario
    : "&" { $$ = '&'; }
    | "*" { $$ = '*'; }
    | "-" { $$ = '-'; }
    | "!" { $$ = '!'; }
    ;

expPostfijo
    : expPrimaria
    | expPostfijo "[" expresion "]"
    | expPostfijo "(" listaArgumentos ")" 
    ;

listaArgumentos
    : expAsignacion { $$ = $1; }
    | listaArgumentos "," expAsignacion { $$ = $1 + $3; }
    ;

expPrimaria
    : IDENTIFICADOR
    | CONSTANTE
    | LITERAL_CADENA
    | "(" expresion ")" { $$ = $2; }
    ;

nombreTipo
    : CHAR
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