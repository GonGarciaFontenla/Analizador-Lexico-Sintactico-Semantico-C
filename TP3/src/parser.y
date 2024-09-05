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
    unsigned long unsigned_long_type;
}

%token <string_type> IDENTIFICADOR
%token <string_type> LITERAL_CADENA
%token <string_type> PALABRA_RESERVADA
%token CONSTANTE
%token <string_type> TIPO_DATO
%token <string_type> TIPO_ALMACENAMIENTO TIPO_CALIFICADOR ENUM STRUCT UNION
%token <string_type> RETURN IF ELSE WHILE DO FOR DEFAULT CASE  
%token <string_type> CONTINUE BREAK GOTO SWITCH SIZEOF

%token ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN
%token EQ NEQ LE GE AND OR
%token LEFT_SHIFT RIGHT_SHIFT
%token PTR_OP INC_OP DEC_OP
%token ELIPSIS

%type <int_type> expresion expAsignacion expCondicional expOr expAnd expIgualdad expRelacional expAditiva expMultiplicativa expUnaria expPostfijo
%type <int_type> operAsignacion operUnario
%type <int_type> listaArgumentos expPrimaria
%type <unsigned_long_type> sentExpresion sentSalto sentSeleccion sentIteracion sentEtiquetadas sentCompuesta sentencia

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

%%

programa
        : input
        ;

input
        : /* Vacio */
        | input unidadTraduccion
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

declaracion
        : especificadores listaDeclaradores ';' 
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

listaDeclaradores
        : declarador
        | listaDeclaradores ',' declarador
        ;

declarador    
        : decla
        | decla '=' inicializador
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

especificadorTipo
        : TIPO_DATO
        | espStructUnion
        | espEnum
        ;

espStructUnion
        : structUnion identOp '{' listaDecStruct '}'
        | structUnion IDENTIFICADOR
        ;

identOp
        : /* Vacio */
        | IDENTIFICADOR
        ;

structUnion
        : STRUCT | UNION
        ;

listaDecStruct
        : decStruct
        | listaDecStruct decStruct
        ;

decStruct
        : listaCalificadores declaradoresStruct ';'
        ;

listaCalificadores
        : especificadorTipo listaCalificadoresOp
        | TIPO_CALIFICADOR listaCalificadoresOp
        ;

listaCalificadoresOp
        : /* Vacio */
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

sentencia
    : sentCompuesta { printf("Sentencia compuesta\n"); }
    | sentExpresion { printf("Sentencia de expresion\n"); }
    | sentSeleccion { printf("Sentencia de seleccion\n"); }
    | sentIteracion { printf("Sentencia de iteracion\n"); }
    | sentEtiquetadas { printf("Sentencia etiquetada\n"); }
    | sentSalto { printf("Sentencia de salto\n"); }
    ;

sentExpresion
    : ';'       { $$ = 0; }
    | expresion ';'     { $$ = $1; }
    ;

sentCompuesta
    : '{' opcionDeclaracion opcionSentencia '}' 
    ;

opcionDeclaracion
    : /* vacío */
    | listaDeclaraciones
    ;

listaDeclaraciones
        : declaracion
        | listaDeclaraciones declaracion
        ;

opcionSentencia
    : /* vacío */
    | listaSentencias
    ;

listaSentencias
        : sentencia
        | listaSentencias sentencia
        ;

sentSeleccion
    : IF '(' expresion ')' sentencia opcionElse { $$ = $3; }
    | SWITCH '(' expresion ')' sentencia
    ;

opcionElse
    : /* vacío */
    | ELSE sentencia
    ;

sentIteracion
    : WHILE '(' expresion ')' sentencia         { $$ = $3; }
    | DO sentencia WHILE '(' expresion ')' ';'  { $$ = $5; }
    | FOR '(' opcionExp ';' opcionExp ';' opcionExp ')' sentencia 
    ;

opcionExp
    : /* vacío */
    | expresion
    ;

sentEtiquetadas
    : IDENTIFICADOR ':' sentencia
    | CASE expCondicional ':' sentencia
    | DEFAULT ':' sentencia 
    ;

sentSalto
    : CONTINUE ';'
    | BREAK ';'
    | GOTO IDENTIFICADOR ';'
    | RETURN ';'        { $$ = 0 }
    | RETURN expresion ';' { $$ = $2; }
    ;

expresion
    : expresion ',' expAsignacion
    | expAsignacion { printf("Expresion asignacion reconocida\n"); }
    ;

expAsignacion
    : expCondicional { printf("Expresion condicional reconocida\n"); }
    | expUnaria operAsignacion expAsignacion { printf("Asignacion con operador reconocida\n"); }
    ;

operAsignacion
    : '='
    | ADD_ASSIGN
    | SUB_ASSIGN
    | MUL_ASSIGN
    | DIV_ASSIGN
    ;

expCondicional
    : expOr { printf("Expresion OR reconocida\n"); }
    | expOr '?' expresion ':' expCondicional { printf("Expresion condicional ternaria reconocida\n"); }
    ;

expOr
    : expAnd { printf("Expresion AND reconocida\n"); }
    | expOr OR expAnd { printf("Expresion OR reconocida\n"); }
    ;

expAnd
    : expIgualdad { printf("Expresion de igualdad reconocida\n"); }
    | expAnd AND expIgualdad { printf("Expresion AND binaria reconocida\n"); }
    ;

expIgualdad
    : expRelacional { printf("Expresion relacional reconocida\n"); }
    | expIgualdad EQ expRelacional { printf("Expresion de igualdad reconocida\n"); }
    | expIgualdad NEQ expRelacional { printf("Expresion de desigualdad reconocida\n"); }
    ;

expRelacional
    : expAditiva { printf("Expresion aditiva reconocida\n"); }
    | expRelacional '<' expAditiva { printf("Menor que reconocido\n"); }
    | expRelacional '>' expAditiva { printf("Mayor que reconocido\n"); }
    | expRelacional LE expAditiva { printf("Menor o igual que reconocido\n"); }
    | expRelacional GE expAditiva { printf("Mayor o igual que reconocido\n"); }
    ;

expAditiva
    : expMultiplicativa { printf("Expresion multiplicativa reconocida\n"); }
    | expAditiva '+' expMultiplicativa { printf("Suma reconocida\n"); }
    | expAditiva '-' expMultiplicativa { printf("Resta reconocida\n"); }
    ;

expMultiplicativa
    : expUnaria { printf("Expresion unaria reconocida\n"); }
    | expMultiplicativa '*' expUnaria { printf("Multiplicacion reconocida\n"); }
    | expMultiplicativa '/' expUnaria { printf("Division reconocida\n"); }
    | expMultiplicativa '%' expUnaria { printf("Modulo reconocido\n"); }
    ;

expUnaria
    : operUnario expUnaria { printf("Expresion unaria con operador reconocida\n"); }
    | expPostfijo { printf("Expresion postfija reconocida\n"); }
    ;

operUnario
    : '!'
    | '&'
    | INC_OP
    | DEC_OP
    | SIZEOF
    ;

expPostfijo
    : expPrimaria { printf("Expresion primaria reconocida\n"); }
    | expPostfijo '[' expresion ']' { printf("Array reconocido\n"); }
    | expPostfijo '(' listaArgumentosOp ')' { printf("Llamada a funcion reconocida\n"); }
    | expPostfijo '.' IDENTIFICADOR { printf("Acceso a campo reconocido\n"); }
    | expPostfijo PTR_OP IDENTIFICADOR { printf("Acceso a puntero reconocido\n"); }
    | expPostfijo INC_OP { printf("Incremento postfijo reconocido\n"); }
    | expPostfijo DEC_OP { printf("Decremento postfijo reconocido\n"); }
    ;

listaArgumentosOp
    : /* vacío */
    | listaArgumentos
    ;

listaArgumentos
    : expAsignacion
    | listaArgumentos ',' expAsignacion
    ;

expPrimaria
    : IDENTIFICADOR
    | CONSTANTE
    | LITERAL_CADENA
    | '(' expresion ')'
    ;

%%
void yyerror(const char* s) {
    fprintf(stderr, "Error de sintaxis: %s\n", s);
}

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