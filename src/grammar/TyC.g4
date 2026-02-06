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

explicit_type: INT | FLOAT | STRING | ID; // ID for struct types

literal_type: INT_LIT | FLOAT_LIT | STRING_LIT;

func_decl_stmt: (explicit_type | VOID)? ID LPAREN (explicit_type ID (COMMA explicit_type ID)*)? RPAREN LBRACE stmt* RBRACE ;

struct_decl_stmt: STRUCT ID LBRACE (explicit_type ID SEMI)* RBRACE SEMI ;

struct_var_decl_stmt: ID ID (ASSIGN LBRACE (expr (COMMA expr)*)? RBRACE)? SEMI ;

// struct_ops: struct_assign | struct_member_access_expr ;

struct_member_access_expr: <assoc=left> ID DOT ID;

struct_assign: ID ASSIGN ID ;

// EXPRESSIONS
expr: expr DOT ID
    | expr (INC | DEC)
    | <assoc=right> (INC | DEC) expr
    | <assoc=right> (PLUS | MINUS | NOT) expr
    | expr (MULT | DIV | MOD) expr
    | expr (PLUS | MINUS) expr
    | expr (LT | LTE | GT | GTE) expr
    | expr (EQ | NEQ) expr
    | expr AND expr
    | expr OR expr
    | <assoc=right> expr ASSIGN expr
    | ID LPAREN (expr (COMMA expr)*)? RPAREN
    | LPAREN expr RPAREN
    | struct_literal_expr
    | ID
    | literal_type
    // (<assoc=left> (ID | INT_LIT | struct_member_access_expr) (INC | DEC)?)
    // (<assoc=right> (INC | DEC)? (ID | INT_LIT | struct_member_access_expr))
    // ((PLUS | MINUS)? (ID | INT_LIT | FLOAT_LIT | struct_member_access_expr | func_call_expr))
    // | ((ID | INT_LIT | FLOAT_LIT) (PLUS | MINUS | MULT | DIV | EQ | NEQ | LT | LTE | GT | GTE) (ID | INT_LIT | FLOAT_LIT))
    // | ((((ID | INT_LIT) (MOD | AND | OR)) | (NOT)) (ID | INT_LIT) )
    // | (STRING_LIT)
    // | (func_call_expr)
    // | (asmt_expr)
    // | (LPAREN expr RPAREN)
    // | (struct_literal_expr)
    ;

struct_literal_expr: LBRACE (expr (COMMA expr)*)? RBRACE;

// func_call_expr: ID LPAREN (expr (COMMA expr)*)? RPAREN ;

asmt_expr: <assoc=right> (ID | struct_member_access_expr) ASSIGN expr ;

// STATEMENTS
stmt: var_decl_stmt | block_stmt | if_stmt | while_stmt | for_stmt | switch_stmt | break_stmt | continue_stmt | return_stmt | expr_stmt | struct_decl_stmt | struct_var_decl_stmt | func_decl_stmt;

var_decl_stmt: (explicit_type | AUTO) ID (ASSIGN expr)? SEMI ;

block_stmt: LBRACE stmt* RBRACE ;

if_stmt: IF LPAREN expr RPAREN stmt (ELSE stmt)? ;

while_stmt: WHILE LPAREN expr RPAREN stmt ;

for_stmt: FOR LPAREN for_init? SEMI expr? SEMI update? RPAREN ( (LBRACE stmt RBRACE) | (stmt) | (LBRACE stmt stmt+ RBRACE) ) ;

for_init: ((explicit_type | AUTO) ID (ASSIGN expr)?) | asmt_expr ;

update: asmt_expr | expr;

switch_stmt: SWITCH LPAREN expr RPAREN LBRACE switchBody RBRACE;

switchBody: switchLabel*;

switchLabel: 
    CASE expr COLON stmt*
    | DEFAULT COLON stmt*
    ;

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

INT_LIT: [0-9]+;
// '0' | ([1-9] [0-9]*);

FLOAT_LIT: (((('0'? '.' [0-9]+) | ('0.' ([0-9]+)?) | ((([1-9] [0-9]* '.' ([0-9]+)?) | (([1-9] [0-9]*)? '.' [0-9]+)))) ([eE] [+-]? [1-9] [0-9]*)?) | (('0' | ([0-9]+)) [eE] [+-]? [1-9] [0-9]*)) ;

fragment ESC_SEQ: '\\' [bft"\\] ; // Removed 'n' - \n is now illegal
fragment STR_CHAR: ~[\n\r\\"] | ESC_SEQ ; // token that can be in a string literal; exclude '\' so that if the string does not match any legal escape sequence, anything starts with '\' will be treated as illegal escape
fragment ESC_ILLEGAL: '\\' ~[bfrnt"\\] ; // Updated to match ESC_SEQ (added 'n' to illegal set)

STRING_LIT: '"' STR_CHAR* '"' { self.text = self.text[1:-1] } ;
// ( (ESC_SEQ) | (~["\\\n\r]) )* or ( (ESC_SEQ) | (~[\\\n\r]) )*? both are correct (test_2) -> not allow matching double-quote in the string, if matching a second double-quote means matching the end of the string

ILLEGAL_ESCAPE: '"' STR_CHAR* ESC_ILLEGAL { self.text = self.text[1:] } ;

UNCLOSE_STRING: '"' STR_CHAR* '\\'? ('\r' | '\n' | '\\' [nr] | EOF) { self.text = self.text[1:] } ;

ERROR_CHAR: . ;