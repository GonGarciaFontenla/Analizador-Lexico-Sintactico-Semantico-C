%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include "general.h"

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
%token <int_type> ENTERO
%token <double_type> NUM

%token ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN
%token EQ NEQ LE GE AND OR
%token LEFT_SHIFT RIGHT_SHIFT
%token PTR_OP INC_OP DEC_OP
%token ELIPSIS

%type <int_type> expresion expAsignacion expCondicional expOr expAnd expIgualdad expRelacional expAditiva expMultiplicativa expUnaria expPostfijo
%type <int_type> operAsignacion operUnario nombreTipo listaArgumentos expPrimaria
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
    : input { printf("Programa reconocido\n"); }
    ;

input
    : /* vacío */
    | input linea
    | input sentencia /* Permitir que el archivo termine con una sentencia */
    | input declaracionExterna
    ;

linea
    : '\n'
    | sentencia '\n'
    | expresion { printf("Expresion reconocida \n");}
    ;

sentencia
    : sentCompuesta { printf("Sentencia compuesta reconocida\n"); }
    | sentExpresion { printf("Sentencia expresion reconocida\n"); }
    | sentSeleccion { printf("Sentencia seleccion reconocida\n"); }
    | sentIteracion { printf("Sentencia iteracion reconocida\n"); }
    | sentEtiquetadas { printf("Sentencia etiquetada reconocida\n"); }
    | sentSalto { printf("Sentencia de salto reconocida\n"); }
    | '\n'
    ;

sentCompuesta
    : '{' opcionDeclaracion opcionSentencia '}' 
    ;

opcionDeclaracion
    :
    | listaDeclaraciones
    ;

opcionSentencia
    :
    | listaSentencias
    ;

listaDeclaraciones
    : listaDeclaraciones declaracionExterna
    | declaracionExterna
    ;

listaSentencias
    : listaSentencias sentencia
    | sentencia
    ;

sentExpresion
    : ';' 
    | expresion ';' 
    ;

sentSeleccion
    : IF '(' expresion ')' sentencia opcionElse 
    ;

opcionElse
    :
    | ELSE sentencia
    ;

sentIteracion
    : WHILE '(' expresion ')' sentencia 
    | DO sentencia WHILE '(' expresion ')' ';' 
    | FOR '(' opcionExp ';' opcionExp ';' opcionExp ')' sentencia 
    ;

sentEtiquetadas
    : IDENTIFICADOR ':' sentencia 
    | CASE expresion ':' sentencia 
    | DEFAULT ':' sentencia 
    ;

sentSalto
    : RETURN ';'
    | RETURN expresion ';' 
    ;

expresion
    : expAsignacion 
    ;

opcionExp
    :
    | expresion
    ;

expAsignacion
    : expCondicional 
    | expUnaria operAsignacion expAsignacion
    ;

operAsignacion
    : '=' {}
    | ADD_ASSIGN {}
    | SUB_ASSIGN {}
    | MUL_ASSIGN {}
    | DIV_ASSIGN {}
    ;

expCondicional
    : expOr opcionCondicional
    ; 
opcionCondicional
    :
    | '?' expresion ':' expCondicional 
    ;

expOr
    : expAnd
    | expOr OR expAnd
    ;

expAnd
    : expIgualdad 
    | expAnd AND expIgualdad 
    ;

expIgualdad
    : expRelacional opcionIgualdad
    ;
opcionIgualdad
    :
    | EQ expRelacional
    | NEQ expRelacional 
    ;

expRelacional
    : expAditiva
    | expRelacional opcionRelacional
    ;
    
opcionRelacional
    :
    | '<' expAditiva
    | '>' expAditiva
    | LE expAditiva
    | GE expAditiva
    ;

expAditiva
    : expMultiplicativa
    | expAditiva opcionAditiva
    ;
opcionAditiva
    :
    | '+' expMultiplicativa
    | '-' expMultiplicativa
    ;
    
expMultiplicativa
    : expUnaria
    | expMultiplicativa opcionMultiplicativa
    ;
opcionMultiplicativa
    : '*' expUnaria
    | '/' expUnaria
    | '%' expUnaria
    ;

expUnaria
    : expPostfijo 
    | INC_OP expUnaria 
    | DEC_OP expUnaria 
    | operUnario expUnaria 
    | SIZEOF '(' nombreTipo ')' 
    ;

operUnario
    : '&' {}
    | '*' {}
    | '-' {}
    | '!' {}
    ;

expPostfijo
    : expPrimaria
    | expPostfijo opcionPostfijo
    ;
opcionPostfijo
    : '[' expresion ']'
    | '(' listaArgumentosOp ')'
    ;

listaArgumentosOp
    : 
    | listaArgumentos
    ;

listaArgumentos
    : expAsignacion 
    | listaArgumentos ',' expAsignacion
    ;

expPrimaria
    : IDENTIFICADOR {}
    | ENTERO
    | CONSTANTE {}
    | LITERAL_CADENA {}
    | '(' expresion ')' {}
    ;

nombreTipo
    : TIPO_DATO 
    ;

declaracionExterna
    : especificadorDeclaracionOp decla restoDeclaracionExterna
    ;

restoDeclaracionExterna
    : sentCompuesta { printf("Se ha definido una función\n"); }
    | ';' { printf("Se ha declarado una variable o estructura\n"); }
    ;

especificadorDeclaracionOp
    : especificadorDeclaracion
    | /* vacío */
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
    : listaDeclaradores
    | /* vacío */
    ;
    
declarador
    : decla
    | decla '=' inicializador
    ;

inicializador
    : expAsignacion
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
    | IDENTIFICADOR
    ;

especificadorStructUnion
    : UNION cuerpoEspecificador
    ;



especificadorStructUnion
    : STRUCT cuerpoEspecificador
    | UNION cuerpoEspecificador
    ;

cuerpoEspecificador
    : IDENTIFICADOR cuerpoStructOp
    | '{' listaDeclaracionesStruct '}'
    ;

cuerpoStructOp
    : /* vacío */
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
    : listaCalificadores
    | /* vacío */
    ;

declaradoresStruct
    : declaStruct
    | declaradoresStruct ',' declaStruct
    ;

declaStruct     
    : declaSi
    | ':' expCondicional
    ;

declaSi
    : decla expCondicionalOp
    ;

expCondicionalOp
    : ':' expCondicional
    | /* vacío */
    ;

decla
    : punteroOp declaradorDirecto
    ;

punteroOp
    : puntero
    | /* vacío */
    ;

puntero
    : '*' listaCalificadoresTipoOp punteroOp
    ;

listaCalificadoresTipoOp
    : listaCalificadoresTipo
    | /* vacío */
    ;
    
listaCalificadoresTipo
    : TIPO_CALIFICADOR
    | listaCalificadoresTipo TIPO_CALIFICADOR
    ;

declaradorDirecto
    : IDENTIFICADOR
    | '(' declarador ')'
    | declaradorDirecto '[' opcionExp ']'   /* Para arreglos */
    | declaradorDirecto '(' listaParametrosOp ')'  /* Para funciones con parámetros */
    ;

opcionExp
    :
    | expresion
    ;

listaParametrosOp
    :
    | listaParametros
    ;

listaParametros
    : especificadorDeclaracionOp decla
    | listaParametros ',' especificadorDeclaracionOp decla
    ;

especificadorEnum
    : ENUM cuerpoEnumOp
    ;

cuerpoEnumOp
    : cuerpoEnum
    | /* vacío */
    ;

cuerpoEnum
    : IDENTIFICADOR
    | '{' listaEnumeradores '}'
    ;

listaEnumeradores
    : listaEnumeradores ',' enumerador
    | enumerador
    ;

enumerador
    : IDENTIFICADOR
    | IDENTIFICADOR '=' constanteExp
    ;

constanteExp
    : expresion
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