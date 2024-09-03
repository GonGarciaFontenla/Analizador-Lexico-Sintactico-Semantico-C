%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include "general.h"

#include "parser.tab.h"

extern int yylex(void);
void yyerror(const char*);
%}

%error-verbose
%locations

%union {
    char* string_type;
    int int_type;
    double double_type;
    char char_type;
}

%token <string_type> IDENTIFICADOR
%token <int_type> ENTERO
%token <double_type> NUM
%token <string_type> LITERAL_CADENA
%token <string_type> PALABRA_RESERVADA
%token <char_type> CONSTANTE
%token <string_type> TIPO
%token SIZEOF

%token ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN
%token EQ NEQ LE GE AND OR
%token LEFT_SHIFT RIGHT_SHIFT
%token PTR_OP INC_OP DEC_OP

%type <int_type> expresion expAsignacion expCondicional expOr expAnd expIgualdad expRelacional expAditiva expMultiplicativa expUnaria expPostfijo
%type <int_type> operAsignacion operUnario nombreTipo
%type <int_type> listaArgumentos expPrimaria

%start programa

%right '=' ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN
%right '?' ':'
%left OR
%left AND
%left EQ NEQ  
%left '<' '>' LE GE  
%left '+' '-'  
%left '*' '/' '%'
%right '!' '&'

%%programa:
    |expresion { printf("Expresion reconocida\n"); }
    ;

expresion
    : expAsignacion { /*printf("Expresion asignacion reconocida\n");*/ }
    ;

expAsignacion
    : expCondicional { }
    | expUnaria operAsignacion expAsignacion {}
    ;

operAsignacion
    : '=' {}
    | ADD_ASSIGN {}
    | SUB_ASSIGN {}
    | MUL_ASSIGN {}
    | DIV_ASSIGN {}
    ;

expCondicional
    : expOr {}
    | expOr '?' expresion ':' expCondicional { }
    ;

expOr
    : expAnd {  }
    | expOr OR expAnd { }
    ;

expAnd
    : expIgualdad { }
    | expAnd AND expIgualdad { }
    ;

expIgualdad
    : expRelacional { }
    | expIgualdad EQ expRelacional { }
    | expIgualdad NEQ expRelacional {}
    ;

expRelacional
    : expAditiva { }
    | expRelacional '<' expAditiva {}
    | expRelacional '>' expAditiva {  }
    | expRelacional LE expAditiva {  }
    | expRelacional GE expAditiva {  }
    ;

expAditiva
    : expMultiplicativa {}
    | expAditiva '+' expMultiplicativa {  }
    | expAditiva '-' expMultiplicativa {  }
    ;

expMultiplicativa
    : expUnaria { }
    | expMultiplicativa '*' expUnaria {}
    | expMultiplicativa '/' expUnaria { }
    | expMultiplicativa '%' expUnaria {  }
    ;

expUnaria
    : expPostfijo { }
    | INC_OP expUnaria {  }
    | DEC_OP expUnaria { }
    | operUnario expUnaria {  }
    | SIZEOF '(' nombreTipo ')' { ; }
    ;

operUnario
    : '&' {}
    | '*' {}
    | '-' {}
    | '!' {}
    ;

expPostfijo
    : expPrimaria { }
    | expPostfijo '[' expresion ']' { }
    | expPostfijo '(' listaArgumentos ')' {  }
    ;

listaArgumentos
    : expAsignacion {}
    | listaArgumentos ',' expAsignacion { }
    ;

expPrimaria
    : IDENTIFICADOR {}
    | ENTERO
    | CONSTANTE {}
    | LITERAL_CADENA {}
    | '(' expresion ')' {}
    ;

nombreTipo
    : TIPO {}
    ;

%%

int main(int argc, char *argv[]) {
    if (argc > 1) {
        FILE *file = fopen(argv[1], "r");
        if (!file) {
            perror("Error abriendo el archivo de entrada");
            return 1;
        }
        yyin = file;
    }

    if (yyparse() != 0) {
        fprintf(stderr, "Error durante el análisis sintáctico\n");
    }

    if (yyin && yyin != stdin) {
        fclose(yyin);
    }

    return 0;
}

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}


/*
programa:
    expresion { printf("Expresion reconocida\n"); }
    ;

expresion
    : expAsignacion { printf("Expresion asignacion reconocida\n"); }
    ;

expAsignacion
    : expCondicional { printf("Expresion condicional reconocida\n"); }
    | expUnaria operAsignacion expAsignacion { printf("Asignacion con operador reconocida\n"); }
    ;

operAsignacion
    : '=' {}
    | ADD_ASSIGN {}
    | SUB_ASSIGN {}
    | MUL_ASSIGN {}
    | DIV_ASSIGN {}
    ;

expCondicional
    : expOr { printf("Expresion OR reconocida\n"); }
    | expOr '?' expresion ':' expCondicional { printf("Expresion condicional ternaria reconocida\n"); }
    ;

expOr
    : expAnd { printf("Expresion AND reconocida\n"); }
    | expOr OR expAnd { printf("Operacion OR reconocida\n"); }
    ;

expAnd
    : expIgualdad { printf("Expresion de igualdad reconocida\n"); }
    | expAnd AND expIgualdad { printf("Operacion AND reconocida\n"); }
    ;

expIgualdad
    : expRelacional { printf("Expresion relacional reconocida\n"); }
    | expIgualdad EQ expRelacional { printf("Operacion de igualdad reconocida\n"); }
    | expIgualdad NEQ expRelacional { printf("Operacion de desigualdad reconocida\n"); }
    ;

expRelacional
    : expAditiva { printf("Expresion aditiva reconocida\n"); }
    | expRelacional '<' expAditiva { printf("Operacion menor que reconocida\n"); }
    | expRelacional '>' expAditiva { printf("Operacion mayor que reconocida\n"); }
    | expRelacional LE expAditiva { printf("Operacion menor o igual reconocida\n"); }
    | expRelacional GE expAditiva { printf("Operacion mayor o igual reconocida\n"); }
    ;

expAditiva
    : expMultiplicativa { printf("Expresion multiplicativa reconocida\n"); }
    | expAditiva '+' expMultiplicativa { printf("Operacion suma reconocida\n"); }
    | expAditiva '-' expMultiplicativa { printf("Operacion resta reconocida\n"); }
    ;

expMultiplicativa
    : expUnaria { printf("Expresion unaria reconocida\n"); }
    | expMultiplicativa '*' expUnaria { printf("Operacion multiplicacion reconocida\n"); }
    | expMultiplicativa '/' expUnaria { printf("Operacion division reconocida\n"); }
    | expMultiplicativa '%' expUnaria { printf("Operacion modulo reconocida\n"); }
    ;

expUnaria
    : expPostfijo { printf("Expresion postfijo reconocida\n"); }
    | INC_OP expUnaria { printf("Operacion incremento reconocida\n"); }
    | DEC_OP expUnaria { printf("Operacion decremento reconocida\n"); }
    | operUnario expUnaria { printf("Operacion unaria reconocida\n"); }
    | SIZEOF '(' nombreTipo ')' { printf("Operacion sizeof reconocida\n"); }
    ;

operUnario
    : '&' {}
    | '*' {}
    | '-' {}
    | '!' {}
    ;

expPostfijo
    : expPrimaria { printf("Expresion primaria reconocida en postfijo\n"); }
    | expPostfijo '[' expresion ']' { printf("Acceso a array en postfijo reconocido\n"); }
    | expPostfijo '(' listaArgumentos ')' { printf("Llamada a funcion en postfijo reconocida\n"); }
    ;

listaArgumentos
    : expAsignacion { printf("Argumento de lista reconocido\n"); }
    | listaArgumentos ',' expAsignacion { printf("Lista de argumentos reconocida\n"); }
    ;

expPrimaria
    : IDENTIFICADOR {}
    | ENTERO
    | CONSTANTE {}
    | LITERAL_CADENA {}
    | '(' expresion ')' {}
    ;

nombreTipo
    : TIPO { printf("Tipo de expresion reconocido: %s\n", $1); }
    ;

*/