use core::f64;
use std::env;
use std::fs;
use std::collections::HashMap;

#[derive(PartialEq, Clone)]
enum TokenType {
    LeftParen,
    RightParen,
    List,
    String,
    Number,
    Identifier,
    None
}

#[derive(Clone)]
struct Token {
    token_type: TokenType,
    text: Vec<char>,
    number: f64
}

impl ToString for Token {
    fn to_string(&self) -> String {
        match self.token_type {
            TokenType::LeftParen => String::from("("),
            TokenType::RightParen => String::from(")"),
            TokenType::List => String::from("List"),
            TokenType::String => format!("Str '{:?}'", self.text),
            TokenType::Number => format!("Num {:?}", self.text),
            TokenType::Identifier => format!("Ident {:?}", self.text),
            TokenType::None => String::from("None")
        }
    }
}

fn get_none_token() -> Token {
    return Token {token_type: TokenType::None, text: Vec::new(), number: 0.0};
}

struct Scanner {
    code: Vec<char>,
    start: usize,
    current: usize,
    line: u32,
    tokens: Vec<Token>
}

fn is_possible_number(test_char: char) -> bool {
    return test_char.is_digit(10) || test_char == '-';
}

fn is_possible_ident(test_char: char) -> bool {
    // must start with an underscore or a letter, or one of ><=!/+-*
    if test_char == '_' {
        return true;
    }
    if test_char.is_alphabetic() {
        return true;
    }
    for character in "><=!/+-*".chars() {
        if test_char == character {
            return true;
        }
    }
    return false;
}

fn error_and_exit(message: &String) {
    println!("Error: {}", message);
    std::process::exit(1);
}

impl Scanner {
    fn new(source: &String) -> Scanner {
        Scanner {
            // force ASCII only, probably should check this here
            code: source.chars().collect(),
            start: 0,
            current: 0,
            line: 0,
            tokens: Vec::new()
        }
    }

    fn print(&self) {
        for token in self.tokens.iter() {
            println!("{}", token.to_string());
        }
    }

    fn advance(&mut self) -> char {
        let char = self.code[self.current];
        self.current += 1;
        return char;
    }

    fn peek(&self) -> char {
        return self.code[self.current];
    }

    fn end_of_tokens(&mut self) -> bool {
        return self.current >= self.code.len();
    }

    fn add_token(&mut self, t_type: TokenType, literal: Vec<char>) {
        self.tokens.push(Token {token_type: t_type, text: literal.to_owned(), number: 0.0});
    }

    fn add_number_token(&mut self, num: f64) {
        let num_string = num.to_string().chars().collect();
        self.tokens.push(Token {token_type: TokenType::Number, text: num_string, number: num});
    }

    fn skip_comment(&mut self) {
        while !self.end_of_tokens() {
            let char = self.advance();
            if char == '\n' {
                self.line += 1;
                return
            }
        }
    }

    fn scan_single_token(&mut self){
        let test_char = self.advance();
        if test_char == ';' {
            self.skip_comment();
        }
        else if test_char == '('{
            self.add_token(TokenType::LeftParen, vec![test_char]);
        }
        else if test_char == ')' {
            self.add_token(TokenType::RightParen, vec![test_char]);
        }
        else if test_char == '\'' {
            self.add_token(TokenType::List, vec![test_char]);
        }
        else if test_char == '"' {
            self.add_string();
        }
        else if is_possible_number(test_char) {
            self.add_number()
        }
        else if test_char == '\n' {
            self.line += 1
        }
        else if is_possible_ident(test_char) {
            self.add_identifier();
        }
        // ignore tabs, spaces and newlines
        else if test_char != '\t' && test_char != '\n' && test_char != ' ' {
            error_and_exit(&format!("Error: Could not understand {} on line {}", test_char, self.line));
        }
    }

    fn add_string(&mut self) {
        // we are pointing at a " character
        // TODO: Does not handle \" constructs
        // TODO: Treats all strings as literals
        while self.peek() != '"' && !self.end_of_tokens() {
            if self.peek() == '\n' {
                self.line += 1;
            }
            self.advance();
        }
        let value = self.code[self.start + 1..self.current].to_vec();
        // move over the final "
        self.advance();
        self.add_token(TokenType::String, value)
    }

    fn add_number(&mut self) {
        // we are pointing at - or [0-9]
        let mut met_point: bool = false;
        while !self.end_of_tokens() {
            let next_char = self.peek();
            if next_char.is_ascii_digit() {
                self.advance();
            }
            else if next_char == '.' {
                if met_point == true {
                    error_and_exit(&format!("Invalid number on line {}", self.line));
                }
                met_point = true;
                self.advance();
            }
            else {
                // either an integer or a float
                let string_value: String = self.code[self.start..self.current].into_iter().collect();
                // can we convert this into a float?
                let num= string_value.parse::<f64>();
                if num.is_err() {
                    error_and_exit( &format!("Invalid number on line {}", self.line));
                }
                // need to handle this better in some way, since we could have different types
                self.add_number_token(num.unwrap());
                return;
            }
        }
    }
    
    fn add_identifier(&mut self) {
        // we are pointing at _ or [a-ZA-Z], or [<>!=+-*/]
        // we also allow numbers after this first value
        while !self.end_of_tokens() {
            let next_char = self.peek();
            if next_char.is_alphanumeric() || vec!['<', '>', '!', '=', '+', '-', '*', '/'].contains(&next_char) {
                self.advance();
            }
            else {
                self.add_token(TokenType::Identifier, self.code[self.start..self.current].to_vec());
                return;
            }
        }
    }

    fn scan_tokens(&mut self) {
        while !self.end_of_tokens() {
            self.start = self.current;
            self.scan_single_token();
        }
    }
}

#[derive(Clone)]
struct Atom {
    // an atom is a member of a list; either a token, or a list of atoms
    // the whole program is a list of atoms -> i.e. another atom
    token: Token,
    list: Vec<Atom>
}

impl Atom {
    fn is_list(&self) -> bool {
        return self.list.len() > 0;
    }

    fn is_identifier(&self) -> bool {
        return self.token.token_type == TokenType::Identifier;
    }

    fn get_none() -> Atom {
        return Atom {token: get_none_token(), list: Vec::new()};
    }
}

fn create_atom_from_tokens(tokens: &Vec<Token>) -> Vec<Atom> {
    if tokens.len() == 0 {
        error_and_exit(&"No tokens found, exiting".to_owned());
    }
    // first token must be a left parens
    if tokens[0].token_type != TokenType::LeftParen {
        error_and_exit(&"Code must start with a ( character".to_owned());
    }
    let mut parsed_tree: Vec<Atom> = Vec::new();
    let mut index = 0;
        
    while index < tokens.len() {
        if tokens[index].token_type == TokenType::LeftParen {
            // we found a sublist, so extract the list and recursivily extract it
            let mut parens_count = 0;
            let mut sub_list: Vec<Token> = Vec::new();
            while index < tokens.len() {
                sub_list.push(tokens[index].clone());
                if tokens[index].token_type == TokenType::LeftParen {
                    parens_count += 1;
                }
                else if tokens[index].token_type == TokenType::RightParen {
                    parens_count -= 1;
                }
                if parens_count == 0 {
                    // found the end
                    let tk = Token {token_type: TokenType::None, text: Vec::new(), number: 0.0};
                    parsed_tree.push(Atom {token: tk, list: create_atom_from_tokens(&sub_list)});
                    index += 1;
                    break;
                }
                index += 1;
            }
            if index == tokens.len() {
                error_and_exit(&"Missing closing parens in sub-list".to_owned());
            }
        }
        else {
            // not a left parens
            if index == tokens.len() - 1 {
                // at end, skip the close parens
                if tokens[index].token_type != TokenType::RightParen {
                    error_and_exit(&"Missing closing parens".to_owned());
                }
            }
            else {
                parsed_tree.push(Atom {token: tokens[index].clone(), list: Vec::new()});
            }
        }
        index += 1;
    }
    return parsed_tree;
}


#[derive(PartialEq, Clone)]
enum VarType {
    String,
    Number,
    List,
    Function,
    None
}

#[derive(Clone)]
struct Variable {
    var_type: VarType,
    str: Vec<char>,
    number: f64,
    list: Vec<Variable>
}

impl Variable {
    fn from_string(str: &Vec<char>) -> Variable {
        Variable {
            var_type: VarType::String,
            str: str.clone(),
            number: 0.0,
            list: Vec::new()
        }
    }

    fn from_number(num: f64) -> Variable {
        Variable {
            var_type: VarType::Number,
            str: Vec::new(),
            number: num,
            list: Vec::new()
        }
    }

    fn from_list(l: &Vec<Variable>) -> Variable {
        Variable {
            var_type: VarType::List,
            str: Vec::new(),
            number: 0.0,
            list: l.to_vec()
        }
    }

    fn from_none() -> Variable {
        Variable {
            var_type: VarType::None,
            str: Vec::new(),
            number: 0.0,
            list: Vec::new()
        }
    }
}


struct Handy {
    // this is the base machine which runs the code
    code: Vec<Atom>,
    variables: HashMap<String, Atom>
}


impl Handy {
    fn new(source: Vec<Atom>) -> Handy {
        Handy { code: source, variables: HashMap::new() }
    }

    fn run_code(&mut self) {
        // each element in the token is a simple list
        let mut index: usize = 0;
        while index < self.code.len() {
            let code_copy = self.code[index].clone();
            self.run_list(&code_copy);
            index += 1;
        }
    }

    fn run_list(&mut self, code: &Atom) -> Atom {
        // if atom is not a list, then error
        if code.is_list() == false {
            error_and_exit(&format!("Error: Asked to run a list, but given an atom"));
        }
        if code.list.len() == 0 {
            // nothing to run, empty list
            return Atom::get_none();
        }
        // in the list, the first thing must be an identifier of some kind
        if !code.list[0].is_identifier() {
            error_and_exit(&format!("Error: First member of list not an identifier"));
        }
        let fcall = &code.list[0];
        // iterate over the rest: if a list, compute it to get an atom
        let mut args: Vec<Atom> = Vec::new();
        for single_arg in &code.list[1..] {
            if single_arg.is_list() {
                args.push(self.run_list(single_arg));
            }
            else {
                args.push(single_arg.clone());
            }
        }
        return self.run_function(fcall, &args);
    }

    fn run_function(&mut self, fcall: &Atom, args: &Vec<Atom>) -> Atom {
        // fcall is ALWAYS an identifier
        // we just need to compare against all the function types and find the right one
        let identifier: String = fcall.token.text.clone().into_iter().collect();
        match identifier.as_str() {
            "let" =>   { return self.f_let(args) },
            "print" => { return self.f_print(args) },
            _ => { return Atom::get_none(); }
        }
    }

    // here are the built-in functions
    fn f_let(&mut self, args: &Vec<Atom>) -> Atom {
        // requires 2 args, the identifier and another atom
        if args.len() != 2 {
            error_and_exit(&format!("Invalid args in let function"));
        }
        if !args[0].is_identifier() {
            error_and_exit(&format!("First argument to let must be an identifier"));
        }
        self.variables.insert(args[0].token.text.clone().into_iter().collect(), args[1]);
        return Atom::get_none();
    }

    fn f_print(&mut self, args: &Vec<Atom>) -> Atom {
        // print all arguments, seperated by a space
        for single_arg in args {

        }
        return Atom::get_none();
    }
}


fn run_file(filepath: &String) {
    let source = fs::read_to_string(filepath)
        .expect("Could not load file");
    let mut token_scanner = Scanner::new(&source);
    token_scanner.scan_tokens();
    token_scanner.print();
    let atoms = create_atom_from_tokens(&token_scanner.tokens);
}

fn main() {
    let args: Vec<String> = env::args().collect();
    if args.len() < 2 {
        println!("Error: No file specified");
        return;
    }
    run_file(&args[1]);
}
