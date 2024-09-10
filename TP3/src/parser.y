%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include "general.h"

extern int yylex(void);
void yyerror(const char*);
int if_first_line, if_first_column;
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

%%

programa
    : input { printf("Programa reconocido\n"); }
    ;

input
    : /* vacío */
    | input expresion { printf("Expresion reconocida \n");}
    | input sentencia /* Permitir que el archivo termine con una sentencia */
    | input unidadTraduccion
    /* | input error '\n' { printf("EL ERROR ESTA ACA \n"); yyerrok; } */
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
    | SWITCH {

        t_statement* stament = malloc(sizeof(t_statement));
        stament->location = malloc(sizeof(location));
        stament->location->line = @1.first_line;  
        stament->location->column = @1.first_column;  
        stament->type = "switch";

        add_node(&statements_list, stament, sizeof(t_statement));
    } '(' expresion ')' sentencia 
    ;

opcionElse
    : 
    | ELSE sentencia
    ;

sentIteracion
    : WHILE '(' expresion ')' sentencia{

        t_statement* stament = malloc(sizeof(t_statement));
        stament->location = malloc(sizeof(location));
        stament->location->line = @1.first_line;  
        stament->location->column = @1.first_column;  
        stament->type = "while";

        add_node(&statements_list, stament, sizeof(t_statement));
    } 
    | DO sentencia WHILE '(' expresion ')' ';'{

        t_statement* stament = malloc(sizeof(t_statement));
        stament->location = malloc(sizeof(location));
        stament->location->line = @1.first_line;  
        stament->location->column = @1.first_column;  
        stament->type = "do/while";

        add_node(&statements_list, stament, sizeof(t_statement));
    } 
    | FOR '('opcionExp')' sentencia{

        t_statement* stament = malloc(sizeof(t_statement));
        stament->location = malloc(sizeof(location));
        stament->location->line = @1.first_line;  
        stament->location->column = @1.first_column;  
        stament->type = "for";

        add_node(&statements_list, stament, sizeof(t_statement));
    }  
    ;

sentEtiquetadas
    : IDENTIFICADOR ':' sentencia 
    | CASE  expresion ':' listaSentencias{

        t_statement* stament = malloc(sizeof(t_statement));
        stament->location = malloc(sizeof(location));
        stament->location->line = @1.first_line;  
        stament->location->column = @1.first_column;  
        stament->type = "case";

        add_node(&statements_list, stament, sizeof(t_statement));
    } 
    | DEFAULT ':' listaSentencias {

        t_statement* stament = malloc(sizeof(t_statement));
        stament->location = malloc(sizeof(location));
        stament->location->line = @1.first_line;  
        stament->location->column = @1.first_column;  
        stament->type = "default";

        add_node(&statements_list, stament, sizeof(t_statement));
    }

sentSalto
    : RETURN ';' {

        t_statement* stament = malloc(sizeof(t_statement));
        stament->location = malloc(sizeof(location));
        stament->location->line = @1.first_line;  
        stament->location->column = @1.first_column;  
        stament->type = "return";

        add_node(&statements_list, stament, sizeof(t_statement));
    }
    | RETURN expresion ';' {

        t_statement* stament = malloc(sizeof(t_statement));
        stament->location = malloc(sizeof(location));
        stament->location->line = @1.first_line;  
        stament->location->column = @1.first_column;  
        stament->type = "return";

        add_node(&statements_list, stament, sizeof(t_statement));
    } 
    ;

expresion
    : expAsignacion 
    | expresion ',' expAsignacion
    ;

opcionExp
    :
    | expresion ';' 
    | expresion ';' expresion
    | expresion ';' expresion ';' expresion
    ;

expAsignacion
    : expCondicional 
    | expUnaria operAsignacion expAsignacion 
    ;

operAsignacion
    : '=' 
    | ADD_ASSIGN 
    | SUB_ASSIGN 
    | MUL_ASSIGN 
    | DIV_ASSIGN 
    ;

expCondicional
    : expOr 
    | expOr '?' expresion : expCondicional
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
    : expRelacional 
    | expIgualdad opcionIgualdad
    ;

opcionIgualdad
    : EQ expRelacional
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
    | expUnaria INC_OP
    | expUnaria DEC_OP
    | operUnario expUnaria 
    | SIZEOF '(' nombreTipo ')' 
    ;

operUnario
    : '&' 
    | '*' 
    | '-' 
    | '!' 
    ;

expPostfijo
    : expPrimaria
    | expPostfijo expPrimaria
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
    : IDENTIFICADOR
    | ENTERO
    | NUM
    | CONSTANTE
    | LITERAL_CADENA 
    | '(' expresion ')'
    | TIPO_DATO
    | PALABRA_RESERVADA
    ;

nombreTipo
    : TIPO_DATO 
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
    : STRUCT cuerpoEspecificador
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

listaDeclaracionSentencia
    :
    | listaDeclaracionSentencia declaracion
    | listaDeclaracionSentencia sentencia
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
    #if YYDEBUG
    yydebug = 1;
    #endif

    yyparse();

    print_statements_list();

    if (yyin && yyin != stdin) {
        fclose(yyin);
    }

    return 0;
}