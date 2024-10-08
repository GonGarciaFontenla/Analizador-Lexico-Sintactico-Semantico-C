%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include "general.h"

extern int yylex(void);
void yyerror(const char *s);

/* Declaracion de variables */
GenericNode* variable = NULL;
t_variable* data_variable = NULL;
t_function* data_function = NULL;
GenericNode* function = NULL;
t_parameter data_parameter;
GenericNode* error_list = NULL;
GenericNode* sentencias = NULL;
t_sent* data_sent = NULL;

GenericNode* semantic_errors = NULL;
t_semantic_error* data_sem_error = NULL; 

int declaration_flag = 0;
int parameter_flag = 0;
int quantity_parameters = 0;
int assignation_flag = 0;

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
%token CONSTANTE
%token <string_type> TIPO_DATO
%token <string_type> TIPO_ALMACENAMIENTO TIPO_CALIFICADOR ENUM STRUCT UNION
%token <string_type> RETURN IF ELSE WHILE DO FOR DEFAULT CASE  
%token <string_type> CONTINUE BREAK GOTO SWITCH SIZEOF
%token <int_type> ENTERO
%token <double_type> NUM

%token ADD_ASSIGN SUB_ASSIGN MUL_ASSIGN DIV_ASSIGN MOD_ASSIGN
%token EQ NEQ LE GE AND OR
%token PTR_OP INC_OP DEC_OP
%token ELIPSIS

%type <int_type> expresion expAsignacion expCondicional expOr expAnd expIgualdad expRelacional expAditiva expMultiplicativa expUnaria expPostfijo
%type <int_type> operAsignacion operUnario nombreTipo listaArgumentos expPrimaria
%type <int_type> sentExpresion sentSalto sentSeleccion sentIteracion sentEtiquetadas sentCompuesta sentencia
%type <string_type> unidadTraduccion declaracionExterna definicionFuncion declaracion especificadorDeclaracion listaDeclaradores listaDeclaracionOp declarador declaradorDirecto  


%start programa

%%

programa
    : input
    ;

input
    : 
    | input expresion {reset_token_buffer();}
    | input sentencia {reset_token_buffer();}
    | input unidadTraduccion {reset_token_buffer();}
    ;

sentencia
    : sentCompuesta {reset_token_buffer();}
    | sentExpresion {reset_token_buffer();}
    | sentSeleccion {reset_token_buffer();}
    | sentIteracion {reset_token_buffer();}
    | sentEtiquetadas {reset_token_buffer();}
    | sentSalto {reset_token_buffer();}
    ;

sentCompuesta
    : '{' {parameter_flag = 0;} opcionDeclaracion opcionSentencia '}' 
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
    | error
    ;

listaSentencias
    : listaSentencias sentencia 
    | sentencia
    | error
    ;

sentExpresion
    : ';'
    | expresion ';' 
    | expresion error { yerror(@1);}
    ;

sentSeleccion
    : IF '(' expresion ')' sentencia {add_sent($<string_type>1, @1.first_line, @1.first_column);} 
    | IF '(' expresion ')' sentencia ELSE sentencia  {add_sent("if/else", @1.first_line, @1.first_column);} 
    | SWITCH '(' expresion ')' {reset_token_buffer(); } sentencia {add_sent($<string_type>1, @1.first_line, @1.first_column); }
    ;


sentIteracion
    : WHILE '(' expresion ')' sentencia {add_sent($<string_type>1, @1.first_line, @1.first_column);}
    | DO sentencia WHILE '(' expresion ')' ';' {add_sent("do/while", @1.first_line, @1.first_column);} 
    | FOR '(' expresionOp ';' expresionOp ';' expresionOp ')' sentencia {add_sent($<string_type>1, @1.first_line, @1.first_column);}
    ;

expresionOp
    : 
    | expresion
    ;

sentEtiquetadas
    : IDENTIFICADOR ':' sentencia 
    | CASE expresion ':' listaSentencias {add_sent($<string_type>1, @1.first_line, @1.first_column);}
    | DEFAULT ':' listaSentencias {add_sent($<string_type>1, @1.first_line, @1.first_column);}
    ;

sentSalto
    : RETURN sentExpresion {add_sent($<string_type>1, @1.first_line, @1.first_column);}
    | CONTINUE ';' {add_sent($<string_type>1, @1.first_line, @1.first_column);}
    | BREAK ';' {add_sent($<string_type>1, @1.first_line, @1.first_column);}
    | GOTO IDENTIFICADOR ';'{add_sent($<string_type>1, @1.first_line, @1.first_column);}
    ;

expresion 
    : expAsignacion
    | expresion ',' expAsignacion
    ;

expAsignacion
    : expCondicional
    | expUnaria operAsignacion {assignation_flag = 1;} expAsignacion 
    | expUnaria operAsignacion error 
    ;

operAsignacion
    : '='
    | ADD_ASSIGN 
    | SUB_ASSIGN 
    | MUL_ASSIGN 
    | DIV_ASSIGN
    | MOD_ASSIGN
    ;

expCondicional
    : expOr 
    | expOr '?' expresion ':' expCondicional
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
    | expMultiplicativa '*' expUnaria
    | expMultiplicativa '/' expUnaria
    | expMultiplicativa '%' expUnaria 
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
    | IDENTIFICADOR opcionPostfijo {
        insert_sem_error_invocate_function(@1.first_line, @1.first_column, $<string_type>1, quantity_parameters);
        quantity_parameters = 0;
    }
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
    : expAsignacion { quantity_parameters ++;}
    | listaArgumentos ',' expAsignacion { quantity_parameters ++;}
    ;

expPrimaria
    : IDENTIFICADOR { 
        if(!declaration_flag) {
            if(!fetch_element(variable, data_variable, compare_ID_variable) && fetch_element(data_function->parameters, &data_parameter, compare_variable_and_parameter)) {
                asprintf(&data_sem_error -> msg, "%i:%i: '%s' sin declarar", @1.first_line, @1.first_column, $<string_type>1);
                insert_node(&semantic_errors, data_sem_error, sizeof(t_semantic_error));
            }
        }
        declaration_flag = 0;
    }
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
        save_function("definicion", $<string_type>1, $<string_type>2);
    
        if(!fetch_element(function, data_function, compare_ID_in_declaration_or_definition) && !fetch_element(function, data_function, compare_ID_and_different_type_functions)) {
            insert_node(&function, data_function, sizeof(t_function));
            data_function->parameters = NULL;
        }
        else {
            insert_sem_error_different_symbol();
            data_function->parameters = NULL;
        }                
    }
            
    ;

declaracion
    : especificadorDeclaracion listaDeclaradores ';'
    | especificadorDeclaracion decla ';' {
        if (parameter_flag) {
            save_function("declaracion", $<string_type>1, $<string_type>2);
            if(!fetch_element(function, data_function, compare_ID_in_declaration_or_definition) && !fetch_element(function, data_function, compare_ID_and_different_type_functions)) {
                insert_node(&function, data_function, sizeof(t_function));
                data_function->parameters = NULL;
            } else {
                insert_sem_error_different_symbol();
            }
        } else {
            insert_node(&variable, data_variable, sizeof(t_variable));
        }
    }
    ;

especificadorDeclaracion 
    : TIPO_ALMACENAMIENTO especificadorDeclaracionOp
    | especificadorTipo especificadorDeclaracionOp 
    | TIPO_CALIFICADOR especificadorDeclaracionOp 
    ;
    
especificadorDeclaracionOp
    : 
    | especificadorDeclaracion
    ;

listaDeclaradores
    : declarador { 
        int redeclaration_line = data_variable->line;
        int redeclaration_column = data_variable->column;
        handle_redeclaration(redeclaration_line, redeclaration_column, data_variable->variable);
        insert_if_not_exists(&variable, function, data_variable);
    }
    | listaDeclaradores ',' declarador {
        int redeclaration_line = data_variable->line;
        int redeclaration_column = data_variable->column;
        handle_redeclaration(redeclaration_line, redeclaration_column, data_variable->variable);
        insert_if_not_exists(&variable, function, data_variable);
    }
    ;

listaDeclaracionOp
    : 
    | listaDeclaraciones
    ;
    
declarador
    : decla
    | decla '=' inicializador
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
    : expAsignacion {declaration_flag = 1;}
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
        data_variable->line = yylloc.first_line;
        data_variable->column = yylloc.first_column;
        data_function->column = yylloc.first_column;

    }
    | '(' decla ')'
    | declaradorDirecto continuacionDeclaradorDirecto { data_function->line = yylloc.first_line; parameter_flag = 1;}
    ;

continuacionDeclaradorDirecto
    : '[' expConstanteOp ']'
    | '(' listaTiposParametrosOp ')'
    | '(' listaIdentificadoresOp ')'
    | '(' TIPO_DATO ')' {  
            data_parameter.type = strdup($<string_type>2);
            data_parameter.name = NULL;
            insert_node(&data_function->parameters, &data_parameter, sizeof(t_parameter));
        }
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
        insert_node(&(data_function->parameters), &data_parameter, sizeof(t_parameter));
    }
    | listaParametros ',' declaracionParametro {
        insert_node(&(data_function->parameters), &data_parameter, sizeof(t_parameter));
    }
    ;
    
declaracionParametro
    : especificadorDeclaracion opcionesDecla {
        data_parameter.type = strdup($<string_type>1);
    }
    ;

opcionesDecla
    :  {data_parameter.name = strdup("");}
    | decla { 
        data_parameter.name = strdup($<string_type>1); 
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
            printf("Error abriendo el archivo de entrada");
            return 1;
        }
        yyin = file;
    }
    
    init_structures();
    
    yyparse();

    print_lists();

    if (yyin && yyin != stdin) {
        fclose(yyin);
    }
    
    free_all_lists(); 

    return 0;
}

void yyerror(const char *s) {
    //fprintf(stderr, "Error sintactico");
}