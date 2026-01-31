"""
Lexer test cases for TyC compiler
TODO: Implement 100 test cases for lexer
"""

import pytest
from tests.utils import Tokenizer

def test_lexer_comments():
    """Placeholder test - replace with actual test cases"""
    tokenizer = Tokenizer("// This is a \n placeholder \r test /* This is a block comment \n This is \r a block comment */")
    assert tokenizer.get_tokens_as_string() == "placeholder,test,<EOF>"

def test_lexer_keywords():
    tokenizer = Tokenizer("auto break case continue default else float for if int return string struct switch void while")

    assert tokenizer.get_tokens_as_string() == "auto,break,case,continue,default,else,float,for,if,int,return,string,struct,switch,void,while,<EOF>"

def test_lexer_float_literal():
    tokenizer = Tokenizer("0.0 3.14 -2.5 1.23e4 5.67E-2 1. .5 0e10 0.e10 .0e10 1e10 -1e10 .123e4")
    assert tokenizer.get_tokens_as_string() == "0.0,3.14,-,2.5,1.23e4,5.67E-2,1.,.5,0e10,0.e10,.0e10,1e10,-,1e10,.123e4,<EOF>"

def test_string_literal():
    tokenizer = Tokenizer("\"nothing \\r gonna \\n change \" my love \" \\\\ \" for \n you \"toi la Huy\"")
    assert tokenizer.get_tokens_as_string() == "nothing gonna change my love \\\\ for \n you,toi la Huy,<EOF>"

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
