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

def test_lexer_placeholder():
    """Placeholder test - replace with actual test cases"""
    source = ["// This is a placeholder test", "/* This is a block comment \n This is a block comment */", "PPL", "auto"]
    result = ["EOF", "EOF", "ID,PPL,EOF", "KW,auto,EOF"]

    compare_results(source, result)

def test_lexer_keywords():
    source = ["auto", "break", "case", "continue", "default", "else", "float", "for", "if", "int", "return", "string", "struct", "switch", "void", "while"]
    result = ["KW,auto,EOF", "KW,break,EOF", "KW,case,EOF", "KW,continue,EOF", "KW,default,EOF", "KW,else,EOF", "KW,float,EOF", "KW,for,EOF", "KW,if,EOF", "KW,int,EOF", "KW,return,EOF", "KW,string,EOF", "KW,struct,EOF", "KW,switch,EOF", "KW,void,EOF", "KW,while,EOF"]

    compare_results(source, result)

def test_escape_characters():
    source=["\"\\b\"", "\"\\f\"", "\"\\r\"", "\"\\n\"", "\"\\t\"", "\"\\\"\"", "\"\\\\\"", "\"\\b\\f\\r\\n\\t\\\"\\\\\""]
    result = ["STRING_LIT,\"\\b\",EOF", "STRING_LIT,\"\\f\",EOF", "STRING_LIT,\"\\r\",EOF", "STRING_LIT,\"\\n\",EOF", "STRING_LIT,\"\\t\",EOF", "STRING_LIT,\"\\\"\",EOF", "STRING_LIT,\"\\\\\",EOF", "STRING_LIT,\"\\b\\f\\r\\n\\t\\\"\\\\\",EOF"]

    compare_results(source, result)
