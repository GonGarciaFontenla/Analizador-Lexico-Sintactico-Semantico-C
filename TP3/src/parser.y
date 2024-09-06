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
%token <string_type> LITERAL_CADENA
%token <string_type> PALABRA_RESERVADA
%token <string_type> TIPO_DATO
%token CONSTANTE
%token CHAR INT FLOAT DOUBLE
%token <string_type> TIPO_ALMACENAMIENTO TIPO_CALIFICADOR ENUM UNION_STRUCT
%token <string_type> DO IF CONTINUE WHILE ELSE BREAK FOR GOTO SWITCH RETURN CASE SIZEOF DEFAULT

%token ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN
%token EQ NEQ LE GE AND OR
%token LEFT_SHIFT RIGHT_SHIFT
%token PTR_OP INC_OP DEC_OP
%token ELIPSIS
%token sentCompuesta expAsignacion expCondicional

%type <int_type> expresion

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
    : /* Vacio */
    | input line
    ;

line
    : '\n'
    | unidadTraduccion '\n'   { printf ("Expresion reconocida\n"); YYACCEPT; }   
    ;

unidadTraduccion
    : declaracionExterna
    | unidadTraduccion declaracionExterna
    ;

declaracionExterna
    : definicionFuncion     { printf("Se ha definido una funcion\n"); }
    | declaracion           { printf("Se ha declarado una variable\n"); }
    ;

definicionFuncion
    : especificadorDeclaracionOp decla listaDeclaracionOp sentCompuesta
    ;
    
declaracion
    : especificadorDeclaracion listaDeclaracionOp 
    ;
    
especificadorDeclaracionOp
    :
    | especificadorDeclaracion
    ;
    
especificadorDeclaracion 
    : TIPO_ALMACENAMIENTO especificadorDeclaracionOp
    | especificadorTipo especificadorDeclaracionOp
    | TIPO_CALIFICADOR especificadorDeclaracionOp 
    ;

listaDeclaradores
    : declarador
    | listaDeclaradores ',' declarador
    ;

listaDeclaracionOp
    : 
    | listaDeclaradores
    ;
    
declarador    
    : decla
    | decla '=' inicializador
    ;

inicializador
    : expAsignacion
    | '{' listaInicializadores opcionComa'}' 
    ;

opcionComa
    :
    | ','
    ;

listaInicializadores
    : inicializador
    | listaInicializadores ',' inicializador
    ;

especificadorTipo
    : TIPO_DATO
    | especificadorStructUnion
    | especificadorEnum
    | nombreTypeDef 
    ;

especificadorStructUnion
    : UNION_STRUCT cuerpoEspecificador
    ;

cuerpoEspecificador
    : '{' listaDeclaracionesStruct '}'
    | IDENTIFICADOR cuerpoStructOp
    ;

cuerpoStructOp
    : 
    | '{' listaDeclaracionesStruct '}'
    ;

listaDeclaracionesStruct
    : declaracionStruct
    | listaDeclaracionStruct declaracionStruct
    ;

declaracionStruct
    : listaCalificadores declaradoresStruct ';'
    ;

listaCalificadores
    : especificadorTipo listaCalificadoresOp
    | TIPO_CALIFICADOR listaCalificadoresOp
    ;

listaCalificadoresOp
    :
    | listaCalificadores
    ;

declaradoresStruct
    : declaStruct
    | declaradoresStruct ',' declaStruct
    ;

declaStruct     
    : decla
    | declaOp ':' expCondicional
    ;

--------------------------------

especificadoresOp
        : /* Vacio */
        | especificadores
        ;

especificadores
        : TIPO_ALMACENAMIENTO especificadoresOp
        | especificadorTipo especificadoresOp
        | TIPO_CALIFICADOR especificadoresOp
        ;









structUnion
        : STRUCT | UNION
        ;

listaDecStruct
        : decStruct
        | listaDecStruct decStruct
        ;



listaCalificadores
        : especificadorTipo listaCalificadoresOp
        | TIPO_CALIFICADOR listaCalificadoresOp
        ;

listaCalificadoresOp
        : /* Vacio */
        | listaCalificadores
        ;





declaOp
        : /* Vacio */
        | decla
        ;

decla
        : declaradorDirecto
        ;

declaradorDirecto
        : IDENTIFICADOR
        | '(' decla ')'
        | declaradorDirecto '[' expCondicionalOp ']'
        | declaradorDirecto '(' listaTipoParametros ')'
        | declaradorDirecto '(' listaIdentificadoresOp ')'
        ;

expCondicionalOp
        : /* Vacio */
        | expCondicional
        ;

listaTipoParametros
        : listaParametros
        | listaParametros ',' ELIPSIS
        ;

listaParametros
        : declaracionParametro
        | listaParametros ',' declaracionParametro
        ;

declaracionParametro
        : especificadores decla
        ;

listaIdentificadoresOp
        : /* Vacio */
        | listaIdentificadores
        ;

listaIdentificadores
        : IDENTIFICADOR
        | listaIdentificadores ',' IDENTIFICADOR
        ;

espEnum
        : ENUM identOp '{' listaEnum '}'
        | ENUM IDENTIFICADOR
        ;

listaEnum
        : enumerador
        | listaEnum ',' enumerador
        ;

enumerador
        : IDENTIFICADOR
        | IDENTIFICADOR '=' expCondicional
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
                printf("Ingrese una expresion para probar:\n");
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