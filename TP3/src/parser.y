%{  
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <general.h>

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
%token CHAR INT FLOAT DOUBLE SIZEOF

%token ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN
%token EQ NEQ LE GE AND OR
%token LEFT_SHIFT RIGHT_SHIFT
%token PTR_OP INC_OP DEC_OP


%type <int_type> expresion expAsignacion expCondicional expOr expAnd expIgualdad expRelacional expAditiva expMultiplicativa expUnaria expPostfijo
%type <int_type> operAsignacion operUnario nombreTipo
%type <int_type> listaArgumentos expPrimaria

%start expresion

%right '=' ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN
%right '?' ':'
%left OR
%left AND
%left EQ NEQ  
%left '<' '>' LE GE  
%left '+' '-'  
%left '*' '/' '%'
%right '!' '&'

%%

expresion
    : /* vacío */
    | expAsignacion { printf("Expresion asignacion reconocida\n"); }
    ;

expAsignacion
    : expCondicional { printf("Expresion condicional reconocida\n"); }
    | expUnaria operAsignacion expAsignacion { printf("Asignacion con operador reconocida\n"); $$ = $3; }
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
    | expOr '?' expresion ':' expCondicional { printf("Expresion condicional ternaria reconocida\n"); $$ = $3; }
    ;

expOr
    : expAnd { printf("Expresion AND reconocida\n"); }
    | expOr OR expAnd { printf("Operacion OR reconocida\n"); $$ = $1 || $3; }
    ;

expAnd
    : expIgualdad { printf("Expresion de igualdad reconocida\n"); }
    | expAnd AND expIgualdad { printf("Operacion AND reconocida\n"); $$ = $1 && $3; }
    ;

expIgualdad
    : expRelacional { printf("Expresion relacional reconocida\n"); }
    | expIgualdad EQ expRelacional { printf("Operacion de igualdad reconocida\n"); $$ = $1 == $3; }
    | expIgualdad NEQ expRelacional { printf("Operacion de desigualdad reconocida\n"); $$ = $1 != $3; }
    ;

expRelacional
    : expAditiva { printf("Expresion aditiva reconocida\n"); }
    | expRelacional '<' expAditiva { printf("Operacion menor que reconocida\n"); $$ = $1 < $3; }
    | expRelacional '>' expAditiva { printf("Operacion mayor que reconocida\n"); $$ = $1 > $3; }
    | expRelacional LE expAditiva { printf("Operacion menor o igual reconocida\n"); $$ = $1 <= $3; }
    | expRelacional GE expAditiva { printf("Operacion mayor o igual reconocida\n"); $$ = $1 >= $3; }
    ;

expAditiva
    : expMultiplicativa { printf("Expresion multiplicativa reconocida\n"); }
    | expAditiva '+' expMultiplicativa { printf("Operacion suma reconocida\n"); $<double_type>$ = $<double_type>1 + $<double_type>3; }
    | expAditiva '-' expMultiplicativa { printf("Operacion resta reconocida\n"); $$ = $1 - $3; }
    ;

expMultiplicativa
    : expUnaria { printf("Expresion unaria reconocida\n"); }
    | expMultiplicativa '*' expUnaria { printf("Operacion multiplicacion reconocida\n"); $$ = $1 * $3; }
    | expMultiplicativa '/' expUnaria { printf("Operacion division reconocida\n"); $$ = $1 / $3; }
    | expMultiplicativa '%' expUnaria { printf("Operacion modulo reconocida\n"); $$ = $1 % $3; }
    ;

expUnaria
    : expPostfijo { printf("Expresion postfijo reconocida\n"); }
    | INC_OP expUnaria { printf("Operacion incremento reconocida\n"); $$ = ++$2; }
    | DEC_OP expUnaria { printf("Operacion decremento reconocida\n"); $$ = --$2; }
    | operUnario expUnaria { printf("Operacion unaria reconocida\n"); $$ = -$2; }
    | SIZEOF '(' nombreTipo ')' { printf("Operacion sizeof reconocida\n"); $$ = sizeof($3); }
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
    : expAsignacion { printf("Argumento de lista reconocido\n"); $$ = $1; }
    | listaArgumentos ',' expAsignacion { printf("Lista de argumentos reconocida\n"); $$ = $1 + $3; }
    ;

expPrimaria
    : IDENTIFICADOR { printf("Identificador reconocido: %s\n", $1); }
    | CONSTANTE { printf("Constante reconocida\n"); $$ = $1; }
    | LITERAL_CADENA { printf("Literal cadena reconocida: %s\n", $1); }
    | '(' expresion ')' { printf("Expresion entre parentesis reconocida\n"); $$ = $2; }
    ;

nombreTipo
    : CHAR {}
    | INT {}
    | FLOAT {}
    | DOUBLE {}
    ;


%%

int main(int argc, char *argv[])
{
        inicializarUbicacion();

        if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            printf("Error abriendo el archivo de entrada");
            return -1;
        }
        } else {
                yyin = stdin;
        }

        while(1){
                if (yyparse() != 0) {
                        printf("Error durante el analisis sintactico\n");
                }
        }

        if (yyin != stdin) {
                fclose(yyin);
        }

        #if YYDEBUG
                yydebug = 1;
        #endif

        pausa();
        return 0;
}

/* Definición de la función yyerror para reportar errores */
void yyerror(const char* literalCadena)
{
    fprintf(stderr, "Bison: %d:%d: %s\n", yylloc.first_line, yylloc.first_column, literalCadena);
}