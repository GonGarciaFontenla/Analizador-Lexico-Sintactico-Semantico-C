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
GenericNode* function = NULL;
GenericNode* error_list = NULL;
GenericNode* sentencias = NULL;
GenericNode* semantic_errors = NULL;
GenericNode* symbol_table = NULL;

//int* invocated_arguments = NULL;
t_variable* data_variable = NULL;

t_variable* data_variable_aux = NULL;
t_variable* data_variable_aux_2 = NULL;

t_arguments* invocated_arguments = NULL;
t_function* data_function = NULL;
t_parameter data_parameter;
t_sent* data_sent = NULL;
t_semantic_error* data_sem_error = NULL; 
t_symbol_table* data_symbol = NULL;

int declaration_flag = 0; // Si está en declaracion
int semicolon_flag = 0; // Si hay un punto y coma
int parameter_flag = 0; // Si está dentro de los parametros de X funcion
int quantity_parameters = 0; // Cantidad de parametros
int assign_void_flag = 0; // Si se asigna una variable a una funcion void
int string_flag = 0;
char* type_aux = "";
int position = 1;
int* vec_parameters = NULL;

%}

%define parse.error verbose
%locations

%union {
    char* string_type;
    int int_type;
    double double_type;
    char char_type;
    t_variable_value var_val;
}

%token <string_type> IDENTIFICADOR
%token <string_type> LITERAL_CADENA
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

%type expAsignacion expCondicional expOr expAnd expIgualdad expRelacional expAditiva expUnaria expMultiplicativa expPostfijo
%type operAsignacion operUnario nombreTipo listaArgumentos expPrimaria
%type sentExpresion sentSalto sentSeleccion sentIteracion sentEtiquetadas sentCompuesta sentencia
%type unidadTraduccion declaracionExterna definicionFuncion declaracion especificadorDeclaracion listaDeclaradores listaDeclaracionOp declarador declaradorDirecto


%start programa

%nonassoc THEN
%nonassoc ELSE 

%nonassoc VACIO
%nonassoc ','
%nonassoc '='
%nonassoc ';'

%%

programa
    : unidadTraduccion
    ;

unidadTraduccion
    : declaracionExterna {reset_token_buffer();}
    | unidadTraduccion declaracionExterna {reset_token_buffer();}
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
    : '{' {parameter_flag = 0;} listaDeclaracionOp listaSentenciasOp '}' 
    ;

listaDeclaraciones
    : declaracion listaDeclaracionOp
    | error
    ;

listaDeclaracionOp
    : listaDeclaraciones
    | %empty
    ;

listaSentencias
    : sentencia listaSentencias
    | sentencia
    | error
    ;

listaSentenciasOp
    : listaSentencias
    | %empty
    ; 

sentExpresion
    : ';' { semicolon_flag = 1;}
    | expresion opcionExpresion
    ; 

opcionExpresion
    : ';'
    | error {yerror(@0); yyerrok;}
    ;

sentSeleccion
    : IF '(' expresion ')' sentencia %prec THEN {add_sent("if", @1.first_line, @1.first_column);}
    | IF '(' expresion ')' sentencia ELSE sentencia {add_sent("if/else", @1.first_line, @1.first_column);}
    | SWITCH '(' expresion ')' {reset_token_buffer(); } sentencia {add_sent($<string_type>1, @1.first_line, @1.first_column); }
    ;

sentIteracion
    : WHILE '(' expresion ')' sentencia {add_sent($<string_type>1, @1.first_line, @1.first_column);}
    | DO sentencia WHILE '(' expresion ')' ';' {add_sent("do/while", @1.first_line, @1.first_column);} 
    | FOR '(' expresionOp ';' expresionOp ';' expresionOp ')' sentencia {add_sent($<string_type>1, @1.first_line, @1.first_column);}
    ;

expresionOp
    : expresion
    | %empty 
    ;

/* TODO: VER CASE, EN TP3 ANDA DE PEDO*/
sentEtiquetadas
    : IDENTIFICADOR ':' sentencia 
    | CASE expresion ':' listaSentencias {add_sent($<string_type>1, @1.first_line, @1.first_column);}
    | DEFAULT ':' listaSentencias {add_sent($<string_type>1, @1.first_line, @1.first_column);}
    ;

sentSalto
    : RETURN sentExpresion {add_sent($<string_type>1, @1.first_line, @1.first_column);
        t_symbol_table* existing_symbol = (t_symbol_table*)get_element(FUNCTION, data_function->name, compare_char_and_ID_function);
        if(existing_symbol) {
            return_conflict_types(existing_symbol, @1.first_line, @1.last_column);
        }
    }
    | CONTINUE ';' {add_sent($<string_type>1, @1.first_line, @1.first_column);}
    | BREAK ';' {add_sent($<string_type>1, @1.first_line, @1.first_column);}
    | GOTO IDENTIFICADOR ';'{add_sent($<string_type>1, @1.first_line, @1.first_column);}
    ;

expresion
    : expAsignacion %prec VACIO
    | expAsignacion ',' expresion
    ;

expAsignacion
    : expCondicional { $<var_val>$ = $<var_val>1;}
    | expUnaria operAsignacion expAsignacion {
        if(assign_void_flag) {
            _asprintf(&data_sem_error->msg, "%i:%i: No se ignora el valor de retorno void como deberia ser", @1.first_line, @1.first_column);
            insert_node(&semantic_errors, data_sem_error, sizeof(t_semantic_error));
            assign_void_flag = 0;
        }

        check_assignation_types ($<var_val>1, $<var_val>3, @3.first_line, @3.first_column);
    }
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
    : expOr { $<var_val>$ = $<var_val>1;}
    | expOr '?' expresion ':' expCondicional
    ; 

expOr
    : expAnd { $<var_val>$ = $<var_val>1;}
    | expOr OR expAnd
    ;

expAnd
    : expIgualdad { $<var_val>$ = $<var_val>1;}
    | expAnd AND expIgualdad 
    ;

expIgualdad
    : expRelacional { $<var_val>$ = $<var_val>1;}
    | expIgualdad opcionIgualdad
    ;

opcionIgualdad
    : EQ expRelacional
    | NEQ expRelacional 
    ;

expRelacional
    : expAditiva { $<var_val>$ = $<var_val>1;}
    | expRelacional opcionRelacional
    ;
    
opcionRelacional
    : '<' expAditiva
    | '>' expAditiva
    | LE expAditiva
    | GE expAditiva
    ;

expAditiva
    : expMultiplicativa { $<var_val>$ = $<var_val>1;}
    | expAditiva opcionAditiva
    ;

opcionAditiva
    : '+' expMultiplicativa
    | '-' expMultiplicativa
    ;
    
expMultiplicativa
    : expUnaria { $<var_val>$ = $<var_val>1;}
    | expMultiplicativa '*' expUnaria/* { 
        if(data_variable_aux = getId($1)) {
            printf("El tipo del primer operando () es: %s \n", data_variable_aux->type);F
            printf("El tipo del segundo operando () es: %s \n", tipo_auxiliar);
        } else { 
            printf("No esta \n"); 
        }
    } */
    | expMultiplicativa '/' expUnaria
    | expMultiplicativa '%' expUnaria 
    ;

expUnaria
    : expPostfijo { $<var_val>$ = $<var_val>1;}
    | opcionIncDec expPostfijo 
    | expPostfijo opcionIncDec
    | operUnario expUnaria  { $<var_val>$ = $<var_val>2;}
    | SIZEOF '(' nombreTipo ')' 
    ;  

opcionIncDec
    : INC_OP 
    | DEC_OP
    ;

operUnario
    : '&' 
    | '*' 
    | '-' 
    | '!' 
    ;

/* TODO: ver expPostFijo */
expPostfijo
    : expPrimaria  { $<var_val>$ = $<var_val>1;}
    | expPostfijo expPrimaria
    | IDENTIFICADOR opcionPostfijo { 
        insert_sem_error_invocate_function(@1.first_line, @1.first_column, $<string_type>1, quantity_parameters);
        manage_conflict_arguments($<string_type>1); 
        free_invocated_arguments();

        if(fetch_element(FUNCTION, $<string_type>1, compare_void_function)) {
            assign_void_flag = 1;
        }
        quantity_parameters = 0;

        $<var_val>$.value.id_val = strdup($<string_type>1);
        $<var_val>$.type = ID;
    }
    | IDENTIFICADOR '(' ')' { 
        $<var_val>$.value.id_val = strdup($<string_type>1);
        $<var_val>$.type = ID;
        }
    ;

opcionPostfijo
    : '[' expresion ']'
    | '(' { parameter_flag = 1;} listaArgumentos ')' { parameter_flag = 0;}
    ;

listaArgumentos
    : expAsignacion masListaArgumentos { quantity_parameters ++;}
    ;

masListaArgumentos
    : masListaArgumentos ',' expAsignacion
    | %empty
    ;

expPrimaria
    : IDENTIFICADOR {
        if(!declaration_flag) {
            if(!fetch_element(VARIABLE, $<string_type>1, compare_ID_parameter) && !fetch_parameter($<string_type>1) && !fetch_element(FUNCTION, $<string_type>1, compare_char_and_ID_function)) {
               _asprintf(&data_sem_error -> msg, "%i:%i: '%s' sin declarar", @1.first_line, @1.first_column, $<string_type>1);
               insert_node(&semantic_errors, data_sem_error, sizeof(semantic_errors));
            }
        }
        declaration_flag = 0;
        string_flag = 0;
        type_aux = strdup($<string_type>1);
        
        if(parameter_flag) {
            add_argument(@1.first_line, @1.first_column, ID);
        }

        $<var_val>$.value.id_val = strdup($<string_type>1);
        $<var_val>$.type = ID;
    }
    | ENTERO            { 
        if(parameter_flag) {  
            add_argument(@1.first_line, @1.first_column, INT);
        }

        $<var_val>$.value.int_val = $<int_type>1;
        $<var_val>$.type = INT;
    } 
    | NUM               { 
        if(parameter_flag){
            add_argument(@1.first_line, @1.first_column, NUMBER);
        }   

        $<var_val>$.value.double_val = $<double_type>1;
        $<var_val>$.type = NUMBER;
    }
    | CONSTANTE         {
        if(parameter_flag) {
            add_argument(@1.first_line, @1.first_column, INT);
        }

        $<var_val>$.value.int_val = $<int_type>1;
        $<var_val>$.type = INT;
    }
    | LITERAL_CADENA    { 
        if(parameter_flag) {
            add_argument(@1.first_line, @1.first_column, STRING);
        }
        string_flag = 1;

        $<var_val>$.value.string_val = strdup($<string_type>1);
        $<var_val>$.type = STRING;
    }
    | '(' expresion ')' 
    ;
/* TODO: revisar falta PALABRA_RESERVADA */

nombreTipo
    : TIPO_DATO 
    ;

declaracionExterna
    : definicionFuncion    
    | declaracion
    ;        

definicionFuncion
    : especificadorDeclaracion decla listaDeclaracionOp sentCompuesta { 
        save_function("definicion", $<string_type>1, $<string_type>2);
        manage_conflict_types(@2.first_line, @2.first_column + 1);    
    }
    ;

declaracion
    : especificadorDeclaracion listaDeclaradores ';'
    | especificadorDeclaracion decla ';' {
        if (parameter_flag) {
            save_function("declaracion", $<string_type>1, $<string_type>2);
            manage_conflict_types(@2.first_line, @2.first_column + 1);
        } else {
            insert_node(&variable, data_variable, sizeof(t_variable));
            insert_symbol(VARIABLE);
        }
    }
    ;

especificadorDeclaracionOp
    : especificadorDeclaracion
    | %empty
    ;

especificadorDeclaracion 
    : TIPO_ALMACENAMIENTO especificadorDeclaracionOp
    | especificadorTipo especificadorDeclaracionOp 
    | TIPO_CALIFICADOR especificadorDeclaracionOp 
    ;
    
listaDeclaradores
    : declarador { 
        int redeclaration_line = data_variable->line;
        int redeclaration_column = data_variable->column;
        handle_redeclaration(redeclaration_line, redeclaration_column, data_variable->variable);
        insert_if_not_exists();
    }
    | listaDeclaradores ',' declarador {
        int redeclaration_line = data_variable->line;
        int redeclaration_column = data_variable->column;
        handle_redeclaration(redeclaration_line, redeclaration_column, data_variable->variable);
        insert_if_not_exists();
    }
    ;

declarador
    : decla opcionPostDeclarador
    ;

opcionPostDeclarador
    : %prec VACIO %empty
    | '=' inicializador {
        t_variable_value var_val;
        var_val.type = ID;
        var_val.value.id_val = strdup($<string_type>0);
        
        check_assignation_types(var_val, $<var_val>2, @2.first_line, @2.first_column);
    }
    ;

opcionComa
    : ','
    | %empty
    ;

listaInicializadores
    : inicializador
    | listaInicializadores ',' inicializador
    ;

inicializador
    : expAsignacion {declaration_flag = 1; $<var_val>$ = $<var_val>1;}
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
    : '{' listaDeclaracionesStruct '}'
    | %empty
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
    | %empty
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
    : ':' expresion
    | %empty
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
        data_variable->line = data_symbol->line = yylloc.first_line;
        data_variable->column =  data_symbol->column = yylloc.first_column;
    }
    | '(' decla ')'
    | declaradorDirecto continuacionDeclaradorDirecto { data_function->line = yylloc.first_line; parameter_flag = 1;}
    ;

continuacionDeclaradorDirecto
    : '[' expConstanteOp ']'
    | '(' opcional 
    ;

opcional
    : ')' 
    | listaTiposParametros  ')' 
    | listaIdentificadores ')' 
    | TIPO_DATO ')' { 
        data_parameter.type = strdup($<string_type>1);
        data_parameter.name = NULL;
        insert_node((GenericNode**)&(data_function->parameters), &data_parameter, sizeof(t_parameter));
        }
    ;

listaTiposParametrosOp 
    : listaTiposParametros 
    | %empty 
    ;
    
listaTiposParametros
    : listaParametros opcionalListaParametros
    ;
    
opcionalListaParametros
    : ',' ELIPSIS
    | %empty
    ;

listaParametros
    : declaracionParametro  {
        insert_node((GenericNode**)&(data_function->parameters), &data_parameter, sizeof(t_parameter));
    }
    | listaParametros ',' declaracionParametro {
        insert_node((GenericNode**)&(data_function->parameters), &data_parameter, sizeof(t_parameter));
    }
    ;

declaracionParametro
    : especificadorDeclaracion opcionesDecla {
        data_parameter.type = strdup($<string_type>1);
        data_parameter.line = @1.first_line;
        data_parameter.column = @1.first_column;
        
    }
    ;

opcionesDecla
    :  {data_parameter.name = (char*)malloc(1); data_parameter.name = '\0';}
    | decla { 
        data_parameter.name = strdup($<string_type>1); 
        }
    ;
/*TODO: si genera muchos conflictos sacar el empty */
listaIdentificadoresOp
    : listaIdentificadores
    | %empty
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
    : '{' listaEnumeradores '}'
    | %empty
    ;

listaEnumeradores
    : enumerador
    | listaEnumeradores ',' enumerador
    ;

enumerador
    : IDENTIFICADOR opcionalEnumerador
    ;

opcionalEnumerador
    : '=' expresion
    | %empty
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
    free(yylval.string_type);

    return 0;
}

void yyerror(const char *s) {
    //fprintf(stderr, "Error sintactico");
}