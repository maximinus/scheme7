import sys
from enum import IntEnum, auto
from pathlib import Path


EXAMPLE_FILE = Path('./examples/test4.s7')


# Keywords

# set   -> (set foo 5)
# if    -> (if cond (...) else (...))
# while -> (while cond (...))
# func  -> (func name (vars) (...))
# for   -> (for name list (...))
# print -> (print ...)
# tests:
#   == / != / > / < / >= / <= / eq
#       (eq tests they are the exactly equal, i.e. same type and value)

# things you can do with types:
# number -> (int x)
#        -> (fract x)
#        -> (round x)
#        -> (floor x)
#        -> (ceil x)
# list   -> (idx index list) (also list[index] syntactic sugar)
#        -> (reverse list)
#        -> (sort list)
#        -> (append list)
#        -> (pop list)
# dict   -> (idx index dict) (also dict[index] syntactic sugar)

"""
    (func add_string (this) (
        (while (and (!= (this.peek) "'") (not (this.at_end))) (
            (if (== (this.peek) "\n") {
                (+= this.line 1))
            (this.advance))
        (this.advance)
        (set value this.source[(+ this.start 1), (+ this.current 1)])
        (this.add_token TokenType.STRING value))
"""


class TokenType(IntEnum):
    LEFT_PAREN = auto()
    RIGHT_PAREN = auto()
    LIST = auto()
    HASH = auto()
    STRING = auto()
    NUMBER = auto()
    IDENTIFIER = auto()
    INDEX_OPEN = auto()
    INDEX_CLOSE = auto()
    HASH_OPEN = auto()
    HASH_CLOSE = auto()
    HASH_SEPERATOR = auto()


class Token:
    def __init__(self, tkn, lit, line):
        self.token_type = tkn
        self.literal = lit
        self.line = line

    def __repr__(self):
        if self.token_type in [TokenType.STRING, TokenType.IDENTIFIER]:
            return f'{TokenType(self.token_type).name} -> "{self.literal}"'
        return f'{TokenType(self.token_type).name}'


class Scanner:
    def __init__(self, source):
        self.source = source
        self.tokens = []
        self.start = 0
        self.current = 0
        self.line = 0

    def scan_tokens(self):
        while not self.at_end():
            self.start = self.current
            self.scan_single_token()

    def at_end(self):
        return self.current >= len(self.source)

    def scan_single_token(self):
        char = self.advance()
        if char == '(':
            self.add_token(TokenType.LEFT_PAREN, char)
        elif char == ')':
            self.add_token(TokenType.RIGHT_PAREN, char)
        elif char == "'":
            self.add_token(TokenType.LIST, char)
        elif char == '[':
            self.add_token(TokenType.INDEX_OPEN, char)
        elif char == ']':
            self.add_token(TokenType.INDEX_CLOSE, char)
        elif char == '{':
            self.add_token(TokenType.HASH_OPEN, char)
        elif char == '}':
            self.add_token(TokenType.HASH_CLOSE, char)
        elif char == ':':
            self.add_token(TokenType.HASH_SEPERATOR, char)
        elif char == ';':
            # simple comment, ignore until end of line
            self.skip_comment()
        elif char == '"':
            self.add_string()
        elif char.isdigit():
            self.add_number()
        elif char == '-':
            self.add_number()
        elif char == '\n':
            # EOL, ignore here
            self.line += 1
        elif char == '\t':
            pass
        elif char == '\r':
            pass
        elif char == ' ':
            pass
        # any character starting with a-zAZ is an identifier
        elif char.isalpha():
            self.add_identifier()
        elif self.is_math(char):
            self.add_math()
        else:
            # anything else must be an identifier (or an error)
            error(self.line, f'No match found for {char}')

    def is_math(self, char):
        if char in ['>', '<', '=', '!', '+']:
            return True

    def add_math(self):
        while self.is_math(self.peek()):
            self.advance()
        value = self.source[self.start: self.current - 1]
        self.advance()
        self.add_token(TokenType.IDENTIFIER, value)

    def add_string(self):
        while self.peek() != '"' and not self.at_end():
            if self.peek() == '\n':
                self.line += 1
            self.advance()
        value = self.source[self.start + 1: self.current]
        # move over the final "
        self.advance()
        self.add_token(TokenType.STRING, value)

    def add_identifier(self):
        while True:
            next_char = self.peek()
            if next_char.isalnum() or next_char in ['-', '_']:
                self.advance()
            else:
                value = self.source[self.start: self.current]
                self.add_token(TokenType.IDENTIFIER, value)
                return

    def add_number(self):
        # could start with a '-', but this is handled elsewhere
        met_point = False
        while not self.at_end():
            next_char = self.peek()
            if next_char.isdigit():
                self.advance()
            elif next == '.':
                if met_point is True:
                    error(self.line, 'Bad number')
                met_point = True
                self.advance()
            else:
                # either an integer or a float
                value = self.source[self.start: self.current]
                try:
                    float_value = float(value)
                    self.add_token(TokenType.NUMBER, float_value)
                    return
                except ValueError:
                    error(self.line, f'{value} is not a valid number')

    def skip_comment(self):
        while not self.at_end():
            char = self.advance()
            if char == '\n':
                self.line += 1
                return

    def advance(self):
        char = self.source[self.current]
        self.current += 1
        return char

    def peek(self):
        return self.source[self.current]

    def add_token(self, token_type, literal):
        text = self.source[self.start:self.current]
        self.tokens.append(Token(token_type, literal, self.line))


class SyntaxCleaner:
    # convert all the syntactic sugar elements into pure s7
    def __init__(self, tokens):
        self.tokens = tokens

    def clean_tokens(self):
        return self.parse(self.tokens)

    def parse(self, tokens):
        index = 0
        # move along tokens
        while not self.at_end(index, tokens):
            # loop until we meet a special character
            single_token = tokens[index]
            if single_token.token_type == TokenType.LIST:
                error_message = self.get_list(index, tokens)
                if error_message != '':
                    error(single_token.line, error_message)
            index += 1
        return tokens

    def get_list(self, index, tokens):
        # a list is simple:
        # replace [' LEFT_PAREM]
        # with [LEFT_PAREM 'LIST']
        index += 1
        if self.at_end(index, tokens):
            return 'Returned early from list creation'
        current_token = tokens[index]
        if current_token.token_type != TokenType.LEFT_PAREN:
            return 'Malformed list creation'
        tokens[index - 1] = current_token
        tokens[index] = Token(TokenType.IDENTIFIER, 'list', current_token.line)
        return ''

    def get_index(self, index, tokens):
        # TODO
        pass

    def get_hash(self, index, tokens):
        # TODO
        pass

    def at_end(self, index, tokens):
        return index >= len(tokens)


def parser(tokens):
    # build a tree out of the tokens
    # go over all tokens
    if len(tokens) == 0:
        error(0, 'No tokens to parse')
    if tokens[0].token_type != TokenType.LEFT_PAREN:
        error(0, 'First token not a left parens')
    parsed_tree = []
    index = 1
    while index < len(tokens):
        if tokens[index].token_type == TokenType.LEFT_PAREN:
            parens_count = 0
            # grab until the matched end parens
            sub_list = []
            while index < len(tokens):
                sub_list.append(tokens[index])
                if tokens[index].token_type == TokenType.LEFT_PAREN:
                    parens_count += 1
                elif tokens[index].token_type == TokenType.RIGHT_PAREN:
                    parens_count -= 1
                if parens_count == 0:
                    # found the end
                    parsed_tree.append(parser(sub_list))
                    # move past index
                    index += 1
                    break
                index += 1
            if index == len(tokens):
                error(0, 'Mis-matched parens')
        else:
            # don't add if at the end; must be a close parens
            if index == len(tokens) - 1:
                if tokens[index].token_type != TokenType.RIGHT_PAREN:
                    error(0, 'No closing parens')
            else:
                parsed_tree.append(tokens[index])
        index += 1
    return parsed_tree


def error(line_number, message):
    print(f'Line {line_number}: Error: {message}')
    sys.exit()


def run(source):
    scanner = Scanner(source)
    scanner.scan_tokens()
    cleaner = SyntaxCleaner(scanner.tokens)
    cleaned_tokens = cleaner.clean_tokens()
    cleaned_tree = parser(cleaned_tokens)
    print(cleaned_tree)


def repl():
    while True:
        line = input('> ')
        run(line)


def load_file():
    with open(EXAMPLE_FILE) as f:
        text = f.read()
    return text


if __name__ == '__main__':
    source_code = load_file()
    run(source_code)
