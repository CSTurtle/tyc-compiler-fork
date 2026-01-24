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
program: EOF;

WS : [ \t\f\r\n]+ -> skip ; // skip spaces, tabs

BLK_CMT: '/*' .*? '*/' -> skip ;

LINE_CMT: '//' ~('\n' | '\r')* -> skip ;

KW: 'auto' | 'break' | 'case' | 'continue' | 'default' | 'else' | 'float' | 'for' | 'if' | 'int' | 'return' | 'string' | 'struct' | 'switch' | 'void' | 'while' ;

ID: [a-zA-Z_]  [a-zA-Z0-9_]* ;

OP: ('+' | '-' | '*' | '/' | '%' | '==' | '!=' | '<' | '<=' | '>' | '>=' | '&&' | '||' | '!' | '++' | '--' | '.' | '=') ;

SEP: ('[' | ']' | '{' | '}' | '(' | ')' | ';' | ',') ;

INT_LIT: '0' | ('-'? [1-9] [0-9]*);

// FLOAT_LIT: ('0'? '.' [0-9]+) | ('-'?) ;

// ESC: ('\b' | '\f' | '\r' | '\n' | '\t' | '\\"' | '\\\\') ;

// STRING_LIT: '"' (ESC | ~('\\' | '"'))* '"'  ;

ERROR_CHAR: .;
ILLEGAL_ESCAPE: .;
UNCLOSE_STRING: .;
