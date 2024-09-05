
%{

#include <stdio.h>
#include <stdlib.h>
#include "general.h"

#include "parser.tab.h"

#define LINEA_INICIAL 1
#define COLUMNA_INICIAL 1


%}
%pointer
%option noyywrap
%x tokenNoReconocido

SUFIJO_ENTERO ([uU]?[lL]{0,2}|[lL]{0,2}[uU]?)?
SUFIJO_REAL ([eE][+-]?[0-9]+)?[fFlL]?
DIGITO_DECIMAL [0-9]
DIGITO_OCTAL [0-7]
DIGITO_HEXA [0-9a-fA-F]
ESCAPE_SIMPLE [abfnrtv\\\'\"\?]

%%

[1-9]{DIGITO_DECIMAL}*{SUFIJO_ENTERO} {
    yylloc.last_column += yyleng;
    yylval.int_type = strtoul(yytext, NULL,0); 
    printf("Decimal: %s\n",yytext);
    return CONSTANTE;
}
0{DIGITO_OCTAL}*{SUFIJO_ENTERO} {
    yylloc.last_column += yyleng;
    yylval.int_type = (int) strtoul(yytext, NULL, 0); 
    return CONSTANTE;
}
0[xX]{DIGITO_HEXA}+{SUFIJO_ENTERO} {
    yylloc.last_column += yyleng;
    yylval.int_type = (int) strtoul(yytext, NULL, 0); 
    return CONSTANTE;
}

[0-9]+\.[0-9]*{SUFIJO_REAL} {
    yylloc.last_column += yyleng;
    yylval.double_type = strtod(yytext, NULL); 
    return CONSTANTE; 
}
\.[0-9]+{SUFIJO_REAL} {
    yylloc.last_column += yyleng;
    yylval.double_type = strtod(yytext, NULL); 
    return CONSTANTE; 
}
[0-9]+{SUFIJO_REAL} {
    yylloc.last_column += yyleng;
    yylval.double_type = strtod(yytext, NULL); 
    return CONSTANTE; 
}


int|float|double|char|void|short|long|unsigned|signed {
    yylloc.last_column += yyleng;
    printf("Tipo dato: %s\n",yytext);
    return TIPO_DATO;
}

sizeof {
    yylloc.last_column += yyleng;
    return SIZEOF;
}

case {
    yylloc.last_column += yyleng;
    return CASE;
}

default {
    yylloc.last_column += yyleng;
    return DEFAULT;
}

goto {
    yylloc.last_column += yyleng;
    return GOTO;
}

return {
    yylloc.last_column += yyleng;
    return RETURN;
}

continue {
    yylloc.last_column += yyleng;
    return CONTINUE;
}

if {
    yylloc.last_column += yyleng;
    return IF;
}

switch {
    yylloc.last_column += yyleng;
    return SWITCH;
}

else {
    yylloc.last_column += yyleng;
    return ELSE;
}

break {
    yylloc.last_column += yyleng;
    return BREAK;
}

while {
    yylloc.last_column += yyleng;
    return WHILE;
}

for {
    yylloc.last_column += yyleng;
    return FOR;
}

do {
    yylloc.last_column += yyleng;
    return DO;
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
    yylloc.last_column += yyleng;
    yylval.string_type = strdup(yytext); 
    printf("ID: %s\n",yytext);
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


"+" { return '+'; }
"-" { return '-'; }
"*" { return '*'; }
"/" { return '/'; }
"%" { return '%'; }
"=" { printf("Token: =\n"); return '='; }
"+=" { return ADD_ASSIGN; }
"-=" { return SUB_ASSIGN; }
"*=" { return MUL_ASSIGN; }
"/=" { return DIV_ASSIGN; }
"%=" { return MOD_ASSIGN; }
"==" { return EQ; }
"!=" { return NEQ; }
"<" { return '<'; }
">" { return '>'; }
"<=" { return LE; }
">=" { return GE; }
"&&" { return AND; }
"||" { return OR; }
"!" { return '!'; }
"&" { return '&'; }
"|" { return '|'; }
"^" { return '^'; }
"~" { return '~'; }
"<<" { return LEFT_SHIFT; }
">>" { return RIGHT_SHIFT; }
"(" { return '('; }
")" { return ')'; }
"[" { return '['; }
"]" { return ']'; }
"{" { return '{'; }
"}" { return '}'; }
";" { return ';'; }
"," { return ','; }
"." { return '.'; }
"->" { return PTR_OP; }
"++" { return INC_OP; }
"--" { return DEC_OP; }
"..." { return ELIPSIS; }


[ \t]+ {yylloc.first_column = yylloc.last_column += yyleng;}

\n {
    yylloc.first_line = yylloc.last_line += yyleng; 
    yylloc.first_column = yylloc.last_column = INICIO_CONTEO_COLUMNA;
    return '\n';
  }


[^ \t\n] {}
<tokenNoReconocido>{
    <<EOF>> {
        fprintf(stderr, "\n");
        BEGIN(INITIAL);
    }
    " "|\t|\n {
        yyless(0);
        fprintf(stderr, "\n");
        BEGIN(INITIAL);
    }
    [^ \t\n]+ {
        yylloc.last_column += yyleng;
        fprintf(stderr, "Token no reconocido: %s\n", yytext);
        BEGIN(INITIAL);
    }
}

%%