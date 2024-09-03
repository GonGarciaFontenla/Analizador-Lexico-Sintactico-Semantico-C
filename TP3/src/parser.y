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
%token <string_type> TIPO_ALMACENAMIENTO TIPO_CALIFICADOR ENUM STRUCT UNION

%token ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN
%token EQ NEQ LE GE AND OR
%token LEFT_SHIFT RIGHT_SHIFT
%token PTR_OP INC_OP DEC_OP
%token ELIPSIS



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
        | unidadTraduccion '\n'      
        ;

unidadTraduccion
        : declaracionExt
        | unidadTraduccion declaracionExt
        ;

declaracionExt
        : defFuncion    { printf("Se ha definido una funcion\n"); }
        | declaracion   { printf("Se ha declarado una variable\n"); }
        ;

defFuncion
        : especificadoresOp declarador listaDeclaracionOp sentCompuesta
        ;

listaDeclaracionOp
        : /* Vacio */
        | listaDeclaraciones 
        ;

listaDeclaraciones
        : declaracion
        | listaDeclaraciones declaracion
        ;

declaracion
        : especificadores listaInicializadoresDecOp ','
        ;

especificadoresOp
        : /* Vacio */
        | especificadores
        ;

especificadores
        : TIPO_ALMACENAMIENTO especificadoresOp
        | especificadorTipo especificadoresOp
        | TIPO_CALIFICADOR especificadoresOp
        ;

listaInicializadoresDecOp
        : /* Vacio */
        | listaInicializadoresDec
        ;

listaInicializadoresDec
        : inicializadorDec
        | listaInicializadoresDec ',' inicializadorDec
        ;

inicializadorDec
        : declarador
        | declarador '=' inicializador
        ;

especificadorTipo
        : TIPO_DATO
        | espStructOrUnion
        | especificadorEnum
        | nombreTypedef
        ;

espStructOrUnion
        : structUnion identOp '{' listaDeclaracionStruct '}'
        | structUnion IDENTIFICADOR
        ;

identOp
        : /* Vacio */
        | IDENTIFICADOR
        ;

structUnion
        : STRUCT
        | UNION
        ;

listaDeclaracionStruct
        : declaracionStruct
        | listaDeclaracionStruct declaracionStruct
        ;

declaracionStruct
        : especificadoresCalificadores listaStruct ';'
        ;

especificadoresCalificadores
        : especificadorTipo especificadoresCalificadoresOp
        | TIPO_CALIFICADOR especificadoresCalificadoresOp
        ;

especificadoresCalificadoresOp
        : /* Vacio */
        | especificadoresCalificadores
        ;

listaStruct
        : declaradorStruct
        | listaStruct ',' declaradorStruct
        ;

declaradorStruct
        : declarador
        | declaradorOp ':' expCondicional
        ;

declaradorOp
        : /* Vacio */
        | declarador
        ;

especificadorEnum
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

declarador
        : punteroOp declaradorDirecto
        ;

declaradorDirecto
        : IDENTIFICADOR
        |'(' declarador ')'
        | declaradorDirecto '[' expCondicionalOp ']'
        | declaradorDirecto '(' listaTipoParametros ')'
        | declaradorDirecto '(' listaIdentificadoresOp ')'
        ;

expCondicionalOp
        : /* Vacio */
        | expCondicional
        ;

punteroOp
        : /* Vacio */
        | puntero
        ;

puntero
        : '*' listaTiposCalOp
        | '*' listaTiposCalOp puntero
        ;

listaTiposCalOp
        : /* Vacio */
        | listaTiposCal
        ;

listaTiposCal
        : TIPO_CALIFICADOR
        | listaTiposCal TIPO_CALIFICADOR
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
        : especificadores declarador
        ;

listaIdentificadoresOp
        : /* Vacio */
        | listaIdentificadores
        ;

listaIdentificadores
        : IDENTIFICADOR
        | listaIdentificadores ',' IDENTIFICADOR
        ;

inicializador
        : expAsignacion
        | '{' listaInicializadores '}'
        | '{' listaInicializadores ',' '}'
        ;

listaInicializadores
        : inicializador
        | listaInicializadores ',' inicializador
        ;
        
nombreTypedef
        : IDENTIFICADOR
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