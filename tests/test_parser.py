"""
Parser test cases for TyC compiler
TODO: Implement 100 test cases for parser
"""

import pytest
from tests.utils import Parser

def compare_results(source):
    for s in source:
        parser = Parser(s)
        result = parser.parse()
        # TODO: Add actual test assertions
        assert result == "success"

def test_parser_placeholder():
    """Placeholder test - replace with actual test cases"""
    source = ["int x = 10;", "x = y = 5 ;", ]
    # TODO: Add actual test assertions
    compare_results(source)
