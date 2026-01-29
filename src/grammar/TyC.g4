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
program: decls+ EOF;

decls: struct_decl_stmt | func_decl_stmt ;

typ: 'int' | 'float' | 'string' | ID;

func_decl_stmt: (typ | 'void')? ID '(' (typ ID (',' typ ID)*)? ')' '{' stmt* '}' ;

struct_decl_stmt: 'struct' ID '{' (typ ID ';')* '}' ';' ;

stmt: if_stmt | while_stmt | for_stmt | switch_stmt | break_stmt | continue_stmt | return_stmt | expr_stmt | block_stmt | var_decl_stmt | member_decl_stmt | struct_decl_stmt | func_decl_stmt | assign_stmt;

expr:   ('+' | '-')? (ID | INT_LIT | FLOAT_LIT ) 
        | (ID | INT_LIT | FLOAT_LIT) ('+' | '-' | '*' | '/' | '==' | '!=' | '<' | '<=' | '>' | '>=') (ID | INT_LIT | FLOAT_LIT) 
        | (ID | INT_LIT) ('%' | '&&' | '||') (ID | INT_LIT) 
        | ('++' | '--')? (ID | INT_LIT) ('++' | '--')?
        | STRING_LIT
        | func_call
        | member_access
        | '(' expr ')' ;

member_access: ID '.' ID;

func_call: ID '(' (expr (',' expr)*)? ')' ;

assign_stmt: ID '=' expr | member_access '=' expr | ID '=' assign_stmt ';' ;

block_stmt: '{' stmt* '}' ;

if_stmt: 'if' '(' expr ')' stmt ('else' stmt)? ;

while_stmt: 'while' '(' expr ')' stmt ;

for_stmt: 'for' '(' for_init? ';' expr? ';' expr? ')' stmt ;

for_init: (('int' | 'float' | 'string' | 'auto' | ID) ID ('=' expr)?) | expr ;

switch_stmt: 'switch' '(' expr ')' '{' case_stmt* '}' ;

break_stmt: 'break' ';' ;

continue_stmt: 'continue' ';' ;

return_stmt: 'return' expr? ';' ;

expr_stmt: expr ';' ;

case_stmt: 'case' expr ':' stmt ;

var_decl_stmt: (typ | 'auto') ID ('=' expr)? ';';

member_decl_stmt: typ ID ';';

struct_decl_stmt: 'struct' ID '{' var_decl_stmt* '}' ';';


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