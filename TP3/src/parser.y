%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include "general.h"

extern int yylex(void);
void yyerror(const char*);

/* Declaracion de variables */
GenericNode* variable = NULL;
t_variable* data_variable = NULL;
t_function* data_function;
GenericNode* function;
t_parameter* data_parameter;

int dentro_de_funcion = 0;

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
%type <int_type> sentExpresion sentSalto sentSeleccion sentIteracion sentEtiquetadas sentCompuesta sentencia
%type <string_type> unidadTraduccion declaracionExterna definicionFuncion declaracion especificadorDeclaracion listaDeclaradores listaDeclaracionOp declarador declaradorDirecto

%start programa

%%

programa
    : input { printf("Programa reconocido\n"); }
    ;

input
    : 
    | input expresion
    | input sentencia /* Permitir que el archivo termine con una sentencia */
    | input unidadTraduccion
    | input error '\n' { printf("EL ERROR ESTA ACA \n"); yyerrok; } 
    ;

sentencia
    : sentCompuesta 
    | sentExpresion 
    | sentSeleccion 
    | sentIteracion 
    | sentEtiquetadas 
    | sentSalto
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
    : listaDeclaraciones declaracion
    | declaracion
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
    | SWITCH '(' expresion ')' sentencia 
    ;

opcionElse
    : 
    | ELSE sentencia
    ;

sentIteracion
    : WHILE '(' expresion ')' sentencia
    | DO sentencia WHILE '(' expresion ')' ';'
    | FOR '(' expresionOp ';' expresionOp ';' expresionOp ')' sentencia
    ;

expresionOp
    : 
    | expresion
    ;

sentEtiquetadas
    : IDENTIFICADOR ':' sentencia 
    | CASE  expresion ':' listaSentencias
    | DEFAULT ':' listaSentencias 
    ;

sentSalto
    : RETURN sentExpresion
    | CONTINUE ';'
    | BREAK ';'
    | GOTO IDENTIFICADOR ';'
    ;

expresion
    : expAsignacion 
    | expresion ',' expAsignacion
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
    : definicionFuncion    
    | declaracion 
    ;          

definicionFuncion
    : especificadorDeclaracion decla listaDeclaracionOp sentCompuesta {
        dentro_de_funcion = 1;
        data_function->return_type = strdup($<string_type>1);
        data_function->name = strdup($<string_type>2);
        data_function->type = "definicion"; 
        add_node(&function, data_function, sizeof(t_function));
    }
    ;

declaracion
    : especificadorDeclaracion listaDeclaradores ';' {dentro_de_funcion = 0;}
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
    : declarador { 
        // if (dentro_de_funcion == 0) {
        //     add_node(&variable, data_variable, sizeof(t_variable));
    }
    | listaDeclaradores ',' declarador {
        // if(dentro_de_funcion == 0) {
        //     add_node(&variable, data_variable, sizeof(t_variable));
        // } 
    }
    ;

listaDeclaracionOp
    : 
    | listaDeclaraciones
    ;
    
declarador
    : decla { 
        if (dentro_de_funcion == 0) {
            add_node(&variable, data_variable, sizeof(t_variable));
        }
    }
    | decla '=' inicializador {

    }
    ;

opcionComa
    : 
    | ','
    ;

listaInicializadores
    : inicializador
    | listaInicializadores ',' inicializador
    ;

inicializador
    : expAsignacion {
        if (dentro_de_funcion == 0) {
            add_node(&variable, data_variable, sizeof(t_variable));
        }
    }
    | '{' listaInicializadores opcionComa '}' 
    ;

especificadorTipo
    : TIPO_DATO { data_variable->type = strdup($<string_type>1);}
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
    : punteroOp declaradorDirecto { $<string_type>$ = strdup($<string_type>2);}
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
    : IDENTIFICADOR {
        $<string_type>$ = strdup($<string_type>1);
        data_variable->variable = strdup($<string_type>1);
        data_variable->line = yylloc.first_line;  // Guardar la línea donde fue declarada
        data_function->line = yylloc.first_line;
    }
    | '(' decla ')'
    | declaradorDirecto continuacionDeclaradorDirecto  
    ;

continuacionDeclaradorDirecto
    : '[' expConstanteOp ']'
    | '(' listaTiposParametrosOp ')'

    | '(' listaIdentificadoresOp ')' 
    | '(' TIPO_DATO ')'
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
    : declaracionParametro  {
        t_parameter temp_parameter = *data_parameter;
        add_node(&(data_function->parameters), &temp_parameter, sizeof(t_parameter));
    }
    | listaParametros ',' declaracionParametro {
        t_parameter temp_parameter = *data_parameter;
        add_node(&(data_function->parameters), &temp_parameter, sizeof(t_parameter));
    }
    ;
    
declaracionParametro
    : especificadorDeclaracion opcionesDecla {
        data_parameter->type = strdup($<string_type>1);
        }
    ;

opcionesDecla
    : decla { 
        data_parameter = (t_parameter*)malloc(sizeof(t_parameter));
        data_parameter->name = strdup($<string_type>1); 
        }
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

    init_structures();

    yyparse();

    // print_statements_list();
    print_lists();

    if (yyin && yyin != stdin) {
        fclose(yyin);
    }

    //free_lists();

    return 0;
}
