grammar TyC;

@lexer::header {
from lexererr import *
}

@lexer::members {
def emit(self):
    tk = self.type
    if tk == self.UNCLOSE_STRING:       
        result = super().emit();
        raise UncloseString(result.text);
    elif tk == self.ILLEGAL_ESCAPE:
        result = super().emit();
        raise IllegalEscape(result.text);
    elif tk == self.ERROR_CHAR:
        result = super().emit();
        raise ErrorToken(result.text); 
    else:
        return super().emit();
}

options{
	language=Python3;
}

// TODO: Define grammar rules here
program: decl* EOF;

// BASICS

decl: struct_decl_stmt | func_decl_stmt ;

struct_name: ID;

typ: INT | FLOAT | STRING | struct_name;

func_decl_stmt: (typ | VOID)? ID LPAREN (typ ID (COMMA typ ID)*)? RPAREN LBRACE stmt* RBRACE ;

struct_decl_stmt: STRUCT struct_name LBRACE (typ ID SEMI)* RBRACE SEMI ;

struct_var_decl_stmt: struct_name ID (ASSIGN LBRACE (expr (COMMA expr)*)? RBRACE)? SEMI ;

struct_ops: struct_assign | struct_member_access_expr ;

struct_member_access_expr: <assoc=left> ID DOT ID;

struct_assign: struct_name ASSIGN struct_name ;

// EXPRESSIONS
expr: (struct_member_access_expr)
    | (<assoc=left> (ID | INT_LIT | struct_member_access_expr) (INC | DEC)?)
    | (<assoc=right> (INC | DEC)? (ID | INT_LIT | struct_member_access_expr))
    | ((PLUS | MINUS)? (ID | INT_LIT | FLOAT_LIT | struct_member_access_expr | func_call_expr))
    | ((ID | INT_LIT | FLOAT_LIT) (PLUS | MINUS | MULT | DIV | EQ | NEQ | LT | LTE | GT | GTE) (ID | INT_LIT | FLOAT_LIT))
    | ((((ID | INT_LIT) (MOD | AND | OR)) | (NOT)) (ID | INT_LIT) )
    | (STRING_LIT)
    | (func_call_expr)
    | (asmt_expr)
    | (LPAREN expr RPAREN)
    ;

func_call_expr: ID LPAREN (expr (COMMA expr)*)? RPAREN ;

asmt_expr: <assoc=right> (ID | struct_member_access_expr) ASSIGN expr ;

// STATEMENTS
stmt: var_decl_stmt | block_stmt | if_stmt | while_stmt | for_stmt | switch_stmt | break_stmt | continue_stmt | return_stmt | expr_stmt | struct_decl_stmt | struct_var_decl_stmt | func_decl_stmt;

var_decl_stmt: (typ | AUTO) ID (ASSIGN expr)? SEMI ;

block_stmt: LBRACE stmt* RBRACE ;

if_stmt: IF LPAREN expr RPAREN stmt (ELSE stmt)? ;

while_stmt: WHILE LPAREN expr RPAREN stmt ;

for_stmt: FOR LPAREN for_init? expr? SEMI update? RPAREN ( (LBRACE? stmt RBRACE?) | (LBRACE stmt stmt+ RBRACE) ) ;

for_init: var_decl_stmt | asmt_expr SEMI ;

update: asmt_expr | expr;

switch_stmt: SWITCH LPAREN expr RPAREN LBRACE (case_stmt* default_stmt?) RBRACE ;

case_stmt: CASE expr COLON stmt* break_stmt? ;

default_stmt: DEFAULT COLON stmt* ;

break_stmt: BREAK SEMI ;

continue_stmt: CONTINUE SEMI ;

return_stmt: RETURN expr? SEMI ;

expr_stmt: expr SEMI ;

// Lexer rules
WS : [ \t\f\r\n]+ -> skip ; // skip spaces, tabs

BLK_CMT: '/*' .*? '*/' -> skip ;

LINE_CMT: '//' ~('\n' | '\r')* -> skip ;

// Keywords (must come before ID)
AUTO: 'auto';
BREAK: 'break';
CASE: 'case';
CONTINUE: 'continue';
DEFAULT: 'default';
ELSE: 'else';
FLOAT: 'float';
FOR: 'for';
IF: 'if';
INT: 'int';
RETURN: 'return';
STRING: 'string';
STRUCT: 'struct';
SWITCH: 'switch';
VOID: 'void';
WHILE: 'while';
// END_OF_FILE: '<EOF>';

ID: [a-zA-Z_] [a-zA-Z0-9_]* ;

// Operators (longer operators first to avoid partial matches)
INC: '++';
DEC: '--';
EQ: '==';
NEQ: '!=';
LTE: '<=';
GTE: '>=';
AND: '&&';
OR: '||';
PLUS: '+';
MINUS: '-';
MULT: '*';
DIV: '/';
MOD: '%';
LT: '<';
GT: '>';
NOT: '!';
DOT: '.';
ASSIGN: '=';

// Separators
LBRACE: '{';
RBRACE: '}';
LPAREN: '(';
RPAREN: ')';
SEMI: ';';
COMMA: ',';
COLON: ':';

INT_LIT: '0' | ([1-9] [0-9]*);

FLOAT_LIT: (((('0'? '.' [0-9]+) | ('0.' ([0-9]+)?) | ((([1-9] [0-9]* '.' ([0-9]+)?) | (([1-9] [0-9]*)? '.' [0-9]+)))) ([eE] [+-]? [1-9] [0-9]*)?) | (('0' | ([0-9]+)) [eE] [+-]? [1-9] [0-9]*)) ;

fragment ESC_SEQ: '\\' [bfrnt"\\] ; 

STRING_LIT: '"' ( (ESC_SEQ) | (~[\\\n\r]) )*? '"' { self.text = self.text[1:-1] } ; // exclude '\\' so that if the string does not match any legal escape sequence, anything starts with '\\' will be treated as illegal escape

ILLEGAL_ESCAPE: '"' ( ESC_SEQ | ~["\\\n\r] )*? '\\' ~[bfrnt"\\] { self.text = self.text[1:] } ;

UNCLOSE_STRING: '"' ( ESC_SEQ | ~["\\\n\r] )*? ('\r' | '\n' | EOF) { self.text = self.text[1:] } ;

ERROR_CHAR: . ;