/* Calculadora de notación polaca inversa */

/* Inicio de la seccion de prólogo (declaraciones y definiciones de C y directivas del preprocesador) */
%{
#include <stdio.h>
#include <math.h>

#include "general.h"

	/* Declaración de la funcion yylex del analizador léxico, necesaria para que la funcion yyparse del analizador sintáctico pueda invocarla cada vez que solicite un nuevo token */
extern int yylex(void);
	/* Declaracion de la función yyerror para reportar errores, necesaria para que la función yyparse del analizador sintáctico pueda invocarla para reportar un error */
void yyerror(const char*);
%}
/* Fin de la sección de prólogo (declaraciones y definiciones de C y directivas del preprocesador) */

/* Inicio de la sección de declaraciones de Bison */

	/* Para requerir una versión mínima de Bison para procesar la gramática */
/* %require "2.4.1" */

	/* Para requirle a Bison que describa más detalladamente los mensajes de error al invocar a yyerror */
%error-verbose
	/* Nota: esta directiva (escrita de esta manera) quedó obsoleta a partir de Bison v3.0, siendo reemplazada por la directiva: %define parse.error verbose */

	/* Para activar el seguimiento de las ubicaciones de los tokens (número de linea, número de columna) */
%locations

	/* Para especificar la colección completa de posibles tipos de datos para los valores semánticos */
%union {
	unsigned long unsigned_long_type;
        char* string;
}

        /* */
%token <unsigned_long_type> NUM
%token <string> RETURN IF ELSE WHILE DO FOR DEFAULT CASE IDENTIFICADOR DECLARACION

	/* */
%type <unsigned_long_type> exp sentExpresion sentSalto sentSeleccion sentIteracion sentEtiquetadas sentCompuesta sentencia

	/* Para especificar el no-terminal de inicio de la gramática (el axioma). Si esto se omitiera, se asumiría que es el no-terminal de la primera regla */
%start input

/* Fin de la sección de declaraciones de Bison */

/* Inicio de la sección de reglas gramaticales */
%%

input
        : /* intencionalmente se deja el resto de esta línea vacía: es la producción nula */
        | input line
        ;

line
        : '\n'
        | sentencia '\n'
        ;

/*                                         REGLAS GRAMATICALES DE LAS SENTENCIAS                                         */
sentencia
        : sentCompuesta   { printf("El resultado de la sentencia compuesta es: %lu\n", $1); }
                         /* la macro 'YYACEPT;' produce que la función yyparse() retorne inmediatamente con valor 0 */ 
        | sentExpresion   { printf ("El resultado de la sentencia expresion es: %lu\n", $1); } 
        | sentSeleccion   { printf("El resultado de la sentencia seleccion es: %lu\n", $1); }
        | sentIteracion   { printf("El resultado de la sentencia iteracion es: %lu\n", $1); }
        | sentEtiquetadas { printf("%lu: FILA: %d COLUMNA: %d \n", $1, yylloc.first_line, yylloc.first_column); }
        | sentSalto       { printf("El resultado de la sentencia salto es: %lu\n", $1); }
        | '\n'
        ;

sentCompuesta
        : '{' opcionDeclaracion opcionSentencia '}' { $$ = 160902; }  /* TO DO */
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

sentIteracion
        : WHILE '(' exp ')' sentencia                                   { $$ = $3; }
	| DO sentencia WHILE '(' exp ')' ';'                            { $$ = $5; }
        | FOR '(' opcionExp ';' opcionExp ';' opcionExp ')' sentencia   { $$ = 99; }    /* TO DO */
        ;

opcionExp
        : 
        | exp 
        ;

sentExpresion
        : ';'              { $$ = 0; }       /* TO DO: usar el opcionExp  */
        | exp ';'          { $$ = $1; }
        ;

sentSeleccion
        : IF '(' exp ')' sentencia opcionElse  { $$ = $3; }
        ;

opcionElse
        : 
        | ELSE sentencia 
        ;

sentEtiquetadas
        : IDENTIFICADOR ':' sentencia   { $$ = 11111; } 
        | CASE exp ':' sentencia        { $$ = 22222; }
        | DEFAULT ':' sentencia         { $$ = 33333; }
        ;

sentSalto
        : RETURN ';'       { $$ = 0; }       /* TO DO */
        | RETURN exp ';'   { $$ = $2; }
        ;
/*                                         FIN REGLAS GRAMATICALES DE LAS SENTENCIAS                                         */

exp
        : NUM             { $$ = $1; }
        | exp exp '+'     { $$ = $1 + $2; }
        | exp exp '-'     { $$ = $1 - $2; }
        | exp exp '*'     { $$ = $1 * $2; }
        | exp exp '/'     { $$ = $1 / $2; }
        | exp exp '^'     { $$ = pow($1, $2); }
        ;
        


%%
/* Fin de la sección de reglas gramaticales */

/* Inicio de la sección de epílogo (código de usuario) */

int main(int argc, char *argv[])
{

        if (argc > 1) {
        yyin = fopen(argv[1], "r");
        if (!yyin) {
            printf("Error abriendo el archivo de entrada");
            return -1;
        }
        } else {
                yyin = stdin;
        }

        while(1){
                if (yyparse() != 0) {
                        printf("Error durante el analisis sintactico\n");
                }
        }

        if (yyin != stdin) {
                fclose(yyin);
        }

        inicializarUbicacion();

        #if YYDEBUG
                yydebug = 1;
        #endif

        pausa();
        return 0;
}

	/* Definición de la funcion yyerror para reportar errores, necesaria para que la funcion yyparse del analizador sintáctico pueda invocarla para reportar un error */
void yyerror(const char* literalCadena)
{
        fprintf(stderr, "Bison: %d:%d: %s\n", yylloc.first_line, yylloc.first_column, literalCadena);
}

/* Fin de la sección de epílogo (código de usuario) */