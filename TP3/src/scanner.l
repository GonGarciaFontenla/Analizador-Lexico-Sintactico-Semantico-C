<<<<<<< HEAD
=======
%{

#include "general.h"

#include "parser.tab.h"

#define LINEA_INICIAL 1
#define COLUMNA_INICIAL 1

int inicializar = 1;
GenericNode* intokens = NULL;
t_token_unrecognised* data_intoken;


%}

SUFIJO_ENTERO ([uU]?[lL]{0,2}|[lL]{0,2}[uU]?)?
SUFIJO_REAL ([eE][+-]?[0-9]+)?[fFlL]?
DIGITO_DECIMAL [0-9]
DIGITO_OCTAL [0-7]
DIGITO_HEXA [0-9a-fA-F]
ESCAPE_SIMPLE [abfnrtv\\\'\"\?]

%pointer
%option noyywrap
%x tokenNoReconocido

%%

    // Inicializa las ubicaciones
    if (inicializar == 1) {
        inicializarUbicacion();
        inicializar = -1;
    }
    reinicializarUbicacion();

[1-9]{DIGITO_DECIMAL}*{SUFIJO_ENTERO} {
    yylloc.last_column += yyleng;
    yylval.int_type = strtoul(yytext, NULL, 0); 
    return ENTERO;
}
0{DIGITO_OCTAL}*{SUFIJO_ENTERO} {
    yylloc.last_column += yyleng;
    yylval.int_type = (int) strtoul(yytext, NULL, 0); 
    return ENTERO;
}
0[xX]{DIGITO_HEXA}+{SUFIJO_ENTERO} {
    yylloc.last_column += yyleng;
    yylval.int_type = (int) strtoul(yytext, NULL, 0); 
    return ENTERO;
}
[0-9]+\.[0-9]*{SUFIJO_REAL} {
    yylloc.last_column += yyleng;
    yylval.double_type = strtod(yytext, NULL); 
    return NUM; 
}
\.[0-9]+{SUFIJO_REAL} {
    yylloc.last_column += yyleng;
    yylval.double_type = strtod(yytext, NULL); 
    return NUM; 
}
[0-9]+{SUFIJO_REAL} {
    yylloc.last_column += yyleng;
    yylval.double_type = strtod(yytext, NULL); 
    return NUM; 
}

int|float|double|char|void|short|long|unsigned|signed {
    yylval.string_type = strdup(yytext);  // Asigna el valor del token reconocido
    yylloc.last_column += yyleng;
    return TIPO_DATO;
}

"unsigned int"|"signed int"|"short int"|"signed short int"|"unsigned short int"|"long int"|"signed long int" {
    yylval.string_type = strdup(yytext); 
    yylloc.last_column += yyleng;
    return TIPO_DATO;
}

return  {
    yylloc.last_column += yyleng;
    yylval.string_type = strdup(yytext);
    return RETURN;
}

if  {
    yylloc.last_column += yyleng;
    yylval.string_type = strdup(yytext);
    return IF;
}

else  {
    yylloc.last_column += yyleng;
    yylval.string_type = strdup(yytext);
    return ELSE;
}

while  {
    yylval.string_type = strdup(yytext);
    yylloc.last_column += yyleng;
    return WHILE;
}

do  {
    yylloc.last_column += yyleng;
    yylval.string_type = strdup(yytext);
    return DO;
}

for  {
    yylloc.last_column += yyleng;
    yylval.string_type = strdup(yytext);
    return FOR;
}

case  {
    yylloc.last_column += yyleng;
    yylval.string_type = strdup(yytext);
    return CASE;
}

default  {
    yylloc.last_column += yyleng;
    yylval.string_type = strdup(yytext);
    return DEFAULT;
}

switch {
    yylloc.last_column += yyleng;
    yylval.string_type = strdup(yytext);
    return SWITCH;
}

sizeof {
    yylloc.last_column += yyleng;
    yylval.string_type = strdup(yytext);
    return SIZEOF;
}

break {
    yylloc.last_column += yyleng;
    yylval.string_type = strdup(yytext);
    return BREAK;
}

goto {
    yylloc.last_column += yyleng;
    yylval.string_type = strdup(yytext);
    return GOTO;
}

continue {
    yylloc.last_column += yyleng;
    yylval.string_type = strdup(yytext);
    return CONTINUE;
}

volatile|const {
    yylloc.last_column += yyleng;
    return TIPO_CALIFICADOR;
}

typedef|static|extern|auto|register {
    yylloc.last_column += yyleng;
    return TIPO_ALMACENAMIENTO;
}

union {
    yylloc.last_column += yyleng;
    return UNION;
}

struct {
    yylloc.last_column += yyleng;
    return STRUCT;
}

enum {
    yylloc.last_column += yyleng;
    return ENUM;
}

[_a-zA-Z][_a-zA-Z0-9]* {
    append_token(yytext);
    yylloc.last_column += yyleng;
    yylval.string_type = strdup(yytext); 
    return IDENTIFICADOR;
}

'[^\\\']' {
    yylloc.last_column += yyleng;
    yylval.char_type = yytext[1];  // Almacena el carácter entre comillas
    return CONSTANTE; 
}

'\\{ESCAPE_SIMPLE}' {
    yylloc.last_column += yyleng;
    yylval.char_type = yytext[1];  // Maneja el carácter de escape
    return CONSTANTE; 
}

'\\{DIGITO_OCTAL}{1,3}' {
    yylloc.last_column += yyleng;
    yylval.char_type = (char)strtol(yytext+1, NULL, 8);  // Convierte de octal
    return CONSTANTE; 
}

'\\x{DIGITO_HEXA}+' {
    yylloc.last_column += yyleng;
    yylval.char_type = (char)strtol(yytext+2, NULL, 16);  // Convierte de hexadecimal
    return CONSTANTE; 
}

\"([^\\\"\n]|\\{ESCAPE_SIMPLE}|\\{DIGITO_OCTAL}{1,3}|\\x{DIGITO_HEXA}+)*\" {
    yylloc.last_column += yyleng;
    yylval.string_type = strdup(yytext); 
    return LITERAL_CADENA; 
}

":" { yylloc.last_column += yyleng; return ':'; }
"?" { yylloc.last_column += yyleng; return '?';}
"+" { yylloc.last_column += yyleng; return '+'; }
"-" { yylloc.last_column += yyleng; return '-'; }
"*" { yylloc.last_column += yyleng; return '*'; }
"/" { yylloc.last_column += yyleng; return '/'; }
"%" { yylloc.last_column += yyleng; return '%'; }
"=" { append_token("="); yylloc.last_column += yyleng; return '='; }
"+=" { yylloc.last_column += yyleng; return ADD_ASSIGN; }
"-=" { yylloc.last_column += yyleng; return SUB_ASSIGN; }
"*=" { yylloc.last_column += yyleng; return MUL_ASSIGN; }
"/=" { yylloc.last_column += yyleng; return DIV_ASSIGN; }
"%=" { yylloc.last_column += yyleng; return MOD_ASSIGN; }
"==" { yylloc.last_column += yyleng; return EQ; }
"!=" { yylloc.last_column += yyleng; return NEQ; }
"<" { yylloc.last_column += yyleng; return '<'; }
">" { yylloc.last_column += yyleng; return '>'; }
"<=" { yylloc.last_column += yyleng; return LE; }
">=" { yylloc.last_column += yyleng; return GE; }
"&&" { yylloc.last_column += yyleng; return AND; }
"||" { yylloc.last_column += yyleng; return OR; }
"!" { yylloc.last_column += yyleng; return '!'; }
"&" { yylloc.last_column += yyleng; return '&'; }
"|" { yylloc.last_column += yyleng; return '|'; }
"^" { yylloc.last_column += yyleng; return '^'; }
"~" { yylloc.last_column += yyleng; return '~'; }
"<<" { yylloc.last_column += yyleng; return LEFT_SHIFT; }
">>" { yylloc.last_column += yyleng; return RIGHT_SHIFT; }
"(" { yylloc.last_column += yyleng; return '('; }
")" { yylloc.last_column += yyleng; return ')'; }
"[" { yylloc.last_column += yyleng; return '['; }
"]" { yylloc.last_column += yyleng; return ']'; }
"{" { yylloc.last_column += yyleng; return '{'; }
"}" { yylloc.last_column += yyleng; return '}'; }
";" { yylval.string_type = strdup(yytext); yylloc.last_column += yyleng; return ';'; }
"," { yylloc.last_column += yyleng; return ','; }
"." { yylloc.last_column += yyleng; return '.'; }
"->" { yylloc.last_column += yyleng; return PTR_OP; }
"++" { yylloc.last_column += yyleng; return INC_OP; }
"--" { yylloc.last_column += yyleng; return DEC_OP; }
"..." { yylloc.last_column += yyleng; return ELIPSIS; }


[ \t]+ {
    yylloc.first_column += yyleng;
    yylloc.last_column += yyleng;
}

\n {
    yylloc.first_line = ++yylloc.last_line;
    yylloc.first_column = yylloc.last_column = 1;
}

[^ \r\t\n] {
    yyless(0);
    BEGIN(tokenNoReconocido);
}

<tokenNoReconocido>{
    <<EOF>> {
        BEGIN(INITIAL);  
    }
    [ \r\t\n] { 
        yyless(0);
        BEGIN(INITIAL); 
    }
    [^ \r\t\n]+ {
        add_unrecognised_token(yytext); 
        BEGIN(INITIAL); 
    }
}

%%
>>>>>>> TP3-Gramatica
