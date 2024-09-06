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

%token <string_type> DECLARACION

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
    ;


linea
    : '\n'
    | sentencia '\n'
    | expresion 
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
    : '{' opcionDeclaracion opcionSentencia '}' { printf("Bloque compuesto reconocido\n"); }
    ;

opcionDeclaracion
    :
    | listaDeclaraciones
    ;

opcionSentencia
    :
    | sentencia
    ;

listaDeclaraciones
    : DECLARACION
    | listaDeclaraciones DECLARACION
    ;

sentExpresion
    : ';' { printf("Sentencia vacía reconocida\n"); }
    | expresion ';' { printf("Expresion reconocida\n"); }
    ;

sentSeleccion
    : IF '(' expresion ')' sentencia opcionElse { printf("Sentencia if reconocida\n"); }
    ;

opcionElse
    :
    | ELSE sentencia
    ;

sentIteracion
    : WHILE '(' expresion ')' sentencia { printf("Sentencia while reconocida\n"); }
    | DO sentencia WHILE '(' expresion ')' ';' { printf("Sentencia do-while reconocida\n"); }
    | FOR '(' opcionExp ';' opcionExp ';' opcionExp ')' sentencia { printf("Sentencia for reconocida\n"); }
    ;

sentEtiquetadas
    : IDENTIFICADOR ':' sentencia { printf("Sentencia etiquetada reconocida\n"); }
    | CASE expresion ':' sentencia { printf("Caso reconocido\n"); }
    | DEFAULT ':' sentencia { printf("Sentencia default reconocida\n"); }
    ;

sentSalto
    : RETURN ';' { printf("Sentencia return sin expresion reconocida\n"); }
    | RETURN expresion ';' { printf("Sentencia return con expresion reconocida\n"); }
    ;

expresion
    : expAsignacion { printf("Expresion asignacion reconocida\n"); }
    ;

opcionExp
    :
    | expresion
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
    | expOr '?' expresion ':' expCondicional { printf("Expresion ternaria reconocida\n"); }
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
    : expPrimaria { printf("Expresion primaria reconocida\n"); }
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
    : TIPO_DATO { printf("Tipo reconocido: %s\n", $1); }
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
