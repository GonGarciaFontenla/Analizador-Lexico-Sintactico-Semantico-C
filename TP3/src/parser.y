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

%token expresion 

%type <int_type> expresion
%type <string_type> especificadorDeclaracion especificadorTipo declarador listaDeclaradores inicializador

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
    : /* Vacío */
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
    : especificadorDeclaracion decla listaDeclaracionOp sentCompuesta
    ;
    
declaracion
    : especificadorDeclaracion listaDeclaradores ';' 
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
    : expresion
    | '{' listaInicializadores opcionComa '}' 
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
    | listaDeclaracionesStruct declaracionStruct
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
    : declaSi
    | ':' expresion
    ;

declaSi
    : decla expConstanteOp
    ;

expConstanteOp
    :
    | ':' expresion
    ;

decla
    : punteroOp declaradorDirecto
    ;

punteroOp
    :
    | puntero
    ;

puntero
    : '*' listaCalificadoresTipoOp punteroOp
    ;

listaCalificadoresTipoOp
    : 
    | listaCalificadoresTipo
    ;
    
listaCalificadoresTipo
    : TIPO_CALIFICADOR
    | listaCalificadoresTipo TIPO_CALIFICADOR
    ;

declaradorDirecto
    : IDENTIFICADOR
    | '(' decla ')'
    | declaradorDirecto continuacionDeclaradorDirecto
    ;

continuacionDeclaradorDirecto
    : '[' expConstanteOp ']'
    | '(' listaTiposParametrosOp ')'
    | '(' listaIdentificadoresOp ')'
    ;

listaTiposParametrosOp 
    : 
    | listaTiposParametros
    ;
    
listaTiposParametros
    : listaParametros opcionalListaParametros
    ;
    
opcionalListaParametros
    :
    | ',' ELIPSIS
    ;

listaParametros
    : declaracionParametro
    | listaParametros ',' declaracionParametro
    ;
    
declaracionParametro
    : especificadorDeclaracion opcionesDecla
    ;

opcionesDecla
    : decla
    | declaradorAbstracto
    ;

listaIdentificadoresOp
    :
    | listaIdentificadores
    ;

listaIdentificadores
    : IDENTIFICADOR
    | listaIdentificadores ',' IDENTIFICADOR
    ;

especificadorEnum
    : ENUM opcionalEspecificadorEnum
    ;

opcionalEspecificadorEnum
    : IDENTIFICADOR opcionalListaEnumeradores
    | '{' listaEnumeradores '}'
    ;

opcionalListaEnumeradores
    :
    | '{' listaEnumeradores '}'
    ;

listaEnumeradores
    : enumerador
    | listaEnumeradores ',' enumerador
    ;

enumerador
    : IDENTIFICADOR opcionalEnumerador
    ;

opcionalEnumerador
    :
    | '=' expresion
    ;

declaradorAbstracto
    : puntero declaradorAbstractoDirectoOp
    | declaradorAbstractoDirecto
    ;

declaradorAbstractoDirectoOp
    : 
    | declaradorAbstractoDirecto
    ;

declaradorAbstractoDirecto
    : '(' declaradorAbstracto ')'
    | declaradorAbstractoDirectoOp postOpcionDeclaradorAbstracto
    ;

postOpcionDeclaradorAbstracto
    : '[' expresion ']'
    | '(' listaTiposParametrosOp ')'
    ;

sentCompuesta
    : '{' listaDeclaracionSentencia '}'
    ;

listaDeclaracionSentencia
    :
    | listaDeclaracionSentencia declaracion
    | listaDeclaracionSentencia sentencia
    ;

sentencia
    : expresion ';'
    | sentCompuesta
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