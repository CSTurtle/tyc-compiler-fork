"""
Lexer test cases for TyC compiler
TODO: Implement 100 test cases for lexer
"""

import pytest
from tests.utils import Tokenizer

def compare_results(source, expected_result):
    for s, r in zip(source, expected_result):
        tokenizer = Tokenizer(s)
        print(tokenizer.get_tokens_as_string())
        # TODO: Add actual test assertions
        assert tokenizer.get_tokens_as_string() == r

def test_lexer_comments():
    """Placeholder test - replace with actual test cases"""
    source = ["// This is a \n placeholder \r test", "/* This is a block comment \n This is \r a block comment */"]
    result = ["ID,placeholder,ID,test,EOF", "EOF"]

    compare_results(source, result)

def test_lexer_keywords():
    source = ["auto", "break", "case", "continue", "default", "else", "float", "for", "if", "int", "return", "string", "struct", "switch", "void", "while"]
    result = ["KW,auto,EOF", "KW,break,EOF", "KW,case,EOF", "KW,continue,EOF", "KW,default,EOF", "KW,else,EOF", "KW,float,EOF", "KW,for,EOF", "KW,if,EOF", "KW,int,EOF", "KW,return,EOF", "KW,string,EOF", "KW,struct,EOF", "KW,switch,EOF", "KW,void,EOF", "KW,while,EOF"]

    compare_results(source, result)

def test_lexer_float_literal():
    source = ["0.0", "3.14", "-2.5", "1.23e4", "5.67E-2", "1.", ".5", "0e10", "0.e10", ".0e10", "1e10", "-1e10", ".123e4"]
    result = ["FLOAT_LIT,0.0,EOF", "FLOAT_LIT,3.14,EOF", "FLOAT_LIT,-2.5,EOF", "FLOAT_LIT,1.23e4,EOF", "FLOAT_LIT,5.67E-2,EOF", "FLOAT_LIT,1.,EOF", "FLOAT_LIT,.5,EOF", "FLOAT_LIT,0e10,EOF", "FLOAT_LIT,0.e10,EOF", "FLOAT_LIT,.0e10,EOF", "FLOAT_LIT,1e10,EOF", "FLOAT_LIT,-1e10,EOF", "FLOAT_LIT,.123e4,EOF"]

    compare_results(source, result)

def test_string_literal():
    source= ["\"nothing \\r gonna \\n change \" my love \" \\\\ \" for \n you", "\"toi la Huy\""]
    result = ["STRING_LIT,nothing gonna change my love \\\\ for \n you,EOF", "STRING_LIT,toi la Huy,EOF"]

    compare_results(source, result)