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
program: decl+ EOF;

// BASICS

decl: struct_decl_stmt | func_decl_stmt ;

struct_name: ID;

typ: 'int' | 'float' | 'string' | struct_name;

func_decl_stmt: (typ | 'void')? ID '(' (typ ID (',' typ ID)*)? ')' '{' stmt* '}' ;

struct_decl_stmt: 'struct' struct_name '{' (typ ID ';')* '}' ';' ;

struct_var_decl_stmt: struct_name ID ('=' '{' (expr (',' expr)*)? '}')? ';' ;

struct_ops: struct_assign | struct_member_access_expr ;

struct_member_access_expr: <assoc=left> ID '.' ID;

struct_assign: struct_name '=' struct_name ;

// EXPRESSIONS
expr: (struct_member_access_expr)
    | (<assoc=left> (ID | INT_LIT) ('++' | '--')?)
    | (<assoc=right> ('++' | '--')? (ID | INT_LIT))
    | (('+' | '-')? (ID | INT_LIT | FLOAT_LIT ))
    | ((ID | INT_LIT | FLOAT_LIT) ('+' | '-' | '*' | '/' | '==' | '!=' | '<' | '<=' | '>' | '>=') (ID | INT_LIT | FLOAT_LIT))
    | ((((ID | INT_LIT) ('%' | '&&' | '||')) | ('!')) (ID | INT_LIT) )
    | (STRING_LIT)
    | (func_call_expr)
    | (asmt_expr)
    ;

func_call_expr: ID '(' (expr (',' expr)*)? ')' ;

asmt_expr: <assoc=right> (ID | struct_member_access_expr) '=' expr ;

// STATEMENTS
stmt: var_decl_stmt | block_stmt | if_stmt | while_stmt | for_stmt | switch_stmt | break_stmt | continue_stmt | return_stmt | expr_stmt | struct_decl_stmt | func_decl_stmt;

var_decl_stmt: (typ | 'auto') ID ('=' expr)? ';' ;

block_stmt: '{' stmt* '}' ;

if_stmt: 'if' '(' expr ')' stmt ('else' stmt)? ;

while_stmt: 'while' '(' expr ')' stmt ;

for_stmt: 'for' '(' for_init? ';' expr? ';' update? ')' stmt ;

for_init: var_decl_stmt | asmt_expr ;

update: asmt_expr | expr;

switch_stmt: 'switch' '(' expr ')' '{' case_stmt* '}' ;

case_stmt: 'case' expr ':' stmt ;

break_stmt: 'break' ';' ;

continue_stmt: 'continue' ';' ;

return_stmt: 'return' expr? ';' ;

expr_stmt: expr ';' ;

// Lexer rules
WS : [ \t\f\r\n]+ -> skip ; // skip spaces, tabs

BLK_CMT: '/*' .*? '*/' -> skip ;

LINE_CMT: '//' ~('\n' | '\r')* -> skip ;

KW: 'auto' | 'break' | 'case' | 'continue' | 'default' | 'else' | 'float' | 'for' | 'if' | 'int' | 'return' | 'string' | 'struct' | 'switch' | 'void' | 'while' ;

ID: [a-zA-Z_] [a-zA-Z0-9_]* ;

OP: ('+' | '-' | '*' | '/' | '%' | '==' | '!=' | '<' | '<=' | '>' | '>=' | '&&' | '||' | '!' | '++' | '--' | '.' | '=') ;

SEP: ('{' | '}' | '(' | ')' | ';' | ',' | ':') ;

INT_LIT: '0' | ('-'? [1-9] [0-9]*);

FLOAT_LIT: (((('0'? '.' [0-9]+) | ('0.' ([0-9]+)?) | ('-'? (([1-9] [0-9]* '.' ([0-9]+)?) | (([1-9] [0-9]*)? '.' [0-9]+)))) ([eE] [+-]? [1-9] [0-9]*)?) | (('0' | ('-'? [0-9]+)) [eE] [+-]? [1-9] [0-9]*)) ;

fragment ESC_SEQ: '\\' [bfrnt"\\] ; 

STRING_LIT: '"' ( (ESC_SEQ) | (~[\\\n\r]) )*? '"' { self.text = self.text[1:-1] } ; // exclude '\\' so that if the string does not match any legal escape sequence, anything starts with '\\' will be treated as illegal escape

ILLEGAL_ESCAPE: '"' ( ESC_SEQ | ~["\\\n\r] )*? '\\' ~[bfrnt"\\] { self.text = self.text[1:] } ;

UNCLOSE_STRING: '"' ( ESC_SEQ | ~["\\\n\r] )*? ('\r' | '\n' | EOF) { self.text = self.text[1:] } ;

ERROR_CHAR: . ;