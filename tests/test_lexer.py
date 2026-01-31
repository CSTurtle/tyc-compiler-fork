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
    result = ["placeholder,test,<EOF>", "<EOF>"]

    compare_results(source, result)

def test_lexer_keywords():
    source = ["auto", "break", "case", "continue", "default", "else", "float", "for", "if", "int", "return", "string", "struct", "switch", "void", "while"]
    result = ["auto,<EOF>", "break,<EOF>", "case,<EOF>", "continue,<EOF>", "default,<EOF>", "else,<EOF>", "float,<EOF>", "for,<EOF>", "if,<EOF>", "int,<EOF>", "return,<EOF>", "string,<EOF>", "struct,<EOF>", "switch,<EOF>", "void,<EOF>", "while,<EOF>"]

    compare_results(source, result)

def test_lexer_float_literal():
    source = ["0.0", "3.14", "-2.5", "1.23e4", "5.67E-2", "1.", ".5", "0e10", "0.e10", ".0e10", "1e10", "-1e10", ".123e4"]
    result = ["0.0,<EOF>", "3.14,<EOF>", "-,2.5,<EOF>", "1.23e4,<EOF>", "5.67E-2,<EOF>", "1.,<EOF>", ".5,<EOF>", "0e10,<EOF>", "0.e10,<EOF>", ".0e10,<EOF>", "1e10,<EOF>", "-,1e10,<EOF>", ".123e4,<EOF>"]

    compare_results(source, result)

def test_string_literal():
    source= ["\"nothing \\r gonna \\n change \" my love \" \\\\ \" for \n you", "\"toi la Huy\""]
    result = ["nothing gonna change my love \\\\ for \n you,EOF", "toi la Huy,EOF"]

    compare_results(source, result)
# ========== Simple Test Cases (10 types) ==========
def test_keyword_auto():
    """1. Keyword"""
    tokenizer = Tokenizer("auto")
    assert tokenizer.get_tokens_as_string() == "auto,<EOF>"


def test_operator_assign():
    """2. Operator"""
    tokenizer = Tokenizer("=")
    assert tokenizer.get_tokens_as_string() == "=,<EOF>"


def test_separator_semi():
    """3. Separator"""
    tokenizer = Tokenizer(";")
    assert tokenizer.get_tokens_as_string() == ";,<EOF>"


def test_integer_single_digit():
    """4. Integer literal"""
    tokenizer = Tokenizer("5")
    assert tokenizer.get_tokens_as_string() == "5,<EOF>"


def test_float_decimal():
    """5. Float literal"""
    tokenizer = Tokenizer("3.14")
    assert tokenizer.get_tokens_as_string() == "3.14,<EOF>"


def test_string_simple():
    """6. String literal"""
    tokenizer = Tokenizer('"hello"')
    assert tokenizer.get_tokens_as_string() == "hello,<EOF>"


def test_identifier_simple():
    """7. Identifier"""
    tokenizer = Tokenizer("x")
    assert tokenizer.get_tokens_as_string() == "x,<EOF>"


def test_line_comment():
    """8. Line comment"""
    tokenizer = Tokenizer("// This is a comment")
    assert tokenizer.get_tokens_as_string() == "<EOF>"


def test_integer_in_expression():
    """9. Mixed: integers and operator"""
    tokenizer = Tokenizer("5+10")
    assert tokenizer.get_tokens_as_string() == "5,+,10,<EOF>"


def test_complex_expression():
    """10. Complex: variable declaration"""
    tokenizer = Tokenizer("auto x = 5 + 3 * 2;")
    assert tokenizer.get_tokens_as_string() == "auto,x,=,5,+,3,*,2,;,<EOF>"
