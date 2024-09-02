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
    char char_type;
}

%token <string_type> IDENTIFICADOR
%token <int_type> ENTERO
%token <double_type> NUM
%token <string_type> LITERAL_CADENA
%token <string_type> PALABRA_RESERVADA
%token <string_type> TIPO_DATO
%token <char_type> CONSTANTE
%token CHAR INT FLOAT DOUBLE SIZEOF

%token ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN
%token EQ NEQ LE GE AND OR
%token LEFT_SHIFT RIGHT_SHIFT
%token PTR_OP INC_OP DEC_OP



%type <int_type> inicializacion unaVarSimple expresion

%start input

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

input
        : /* intencionalmente se deja el resto de esta línea vacía: es la producción nula */
        | input line
        ;

line
        : '\n'
        | declaracion '\n'      
        ;

declaracion
        : declaVarSimples
        ;

declaVarSimples
        : TIPO_DATO listaVarSimples ';'
        ;

listaVarSimples
        : unaVarSimple
        | listaVarSimples ',' unaVarSimple
        ;

unaVarSimple
        : IDENTIFICADOR inicializacion   { $$ = $2; }
        ;

inicializacion
        : /* Vacio */
        | '=' expresion { $$ = $2; }
        ;

expresion
        : NUM                         { $$ = $1; }
        | expresion expresion '+'     { $$ = $1 + $2; }
        | expresion expresion '-'     { $$ = $1 - $2; }
        | expresion expresion '*'     { $$ = $1 * $2; }
        | expresion expresion '/'     { $$ = $1 / $2; }
        | expresion expresion '^'     { $$ = pow($1, $2); }
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
                printf("Ingrese una expresion aritmetica en notacion polaca inversa para resolver:\n");
                printf("(La funcion yyparse ha retornado con valor: %d)\n\n", yyparse());
                /* Valor | Significado */
                /*   0   | Análisis sintáctico exitoso (debido a un fin de entrada (EOF) indicado por el analizador léxico (yylex), ó bien a una invocación de la macro YYACCEPT) */
                /*   1   | Fallo en el análisis sintáctico (debido a un error en el análisis sintáctico del que no se pudo recuperar, ó bien a una invocación de la macro YYABORT) */
                /*   2   | Fallo en el análisis sintáctico (debido a un agotamiento de memoria) */
        }

        pausa();
        return 0;
}

	/* Definición de la funcion yyerror para reportar errores, necesaria para que la funcion yyparse del analizador sintáctico pueda invocarla para reportar un error */
void yyerror(const char* literalCadena)
{
        fprintf(stderr, "Bison: %d:%d: %s\n", yylloc.first_line, yylloc.first_column, literalCadena);
}

/* Fin de la sección de epílogo (código de usuario) */