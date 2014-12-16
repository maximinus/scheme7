"use strict";

// enums for parser types
var PARSE_TYPES = {'OPEN':0, 'CLOSE':1, 'IDENTIFIER':2, 'NUMBER':3, 'STRING':4};

// start with an environment
var Env = {};

// code for the tokeniser
// this turns the raw text into an array of tokens
function Tokeniser() {
	this.token_error = false;
	this.error_message = '';

	this.setTokenError = function(text) {
		this.token_error = true;
		this.error_message = text;
	};

	this.spaceParens = function(text) {
		// put spaces around the parens:
		text = text.replace(/\(/g, ' ( ');
		text = text.replace(/\)/g, ' ) ');
		return(text);
	};

	this.removeEmptyStrings = function(tokens) {
		// remove null strings at start and end of the list
		return(tokens.filter(function(value) { return(value != ''); }));
	};

	this.joinStrings = function(tokens) {
		// traverse the array looking for one that starts with a "
		// token is always a string of length > 0
		var new_tokens = [];
		for(var i=0; i<tokens.length; i++) {
			// does it start with "?
			if(this.textIsNotFullyQuoted(tokens[i])) {
				var index = this.readUntilQuote(tokens.slice(i + 1));
				// now we know how long the quote is, so create it and store
				new_tokens.push(tokens.slice(i, i+index).join());
				// 1 is added to i next iteration
				i += index;
			}
			else {
				new_tokens.push(tokens[i]); }
		}
		return(new_tokens);
	};

	this.readUntilQuote = function(tokens) {
		for(var i=0; i<tokens.length;i++) {
			if(this.endIsQuote(tokens[i])) {
				// +1 because we need the offset (and arrat is zero-indexed)
				return(i + 1); }
		}
		// there is an error
		this.setTokenError('String does not end');
		return(-1);
	};

	this.textIsNotFullyQuoted = function(text) {
		// test further if start is a quote
		if(text[0] != '"') {
			return(false); }
		return(!this.endIsQuote(text));
	};

	this.endIsQuote = function(text) {
		// only length 1, easy:
		if(text.length == 1) {
			return(text[0] == '"'); }
		// otherwise, have to check for \ before:
		return((text[text.length-1] == '"') && (text[text.length-2] != '\\'));
	};

	this.tokenise = function(text) {
		text = this.spaceParens(text);
		var tokens = text.split(/\s+/);
		tokens = this.removeEmptyStrings(tokens);
		tokens = this.joinStrings(tokens);
		return({'tokens':tokens, error:this.token_error, error_message:this.error_message});
	};
};

// now the parser. We have to define an 'item'. It could be a number, or a string, or an identifier
function ParseItem(type, value) {
	this.type = type;
	this.value = value || null;
};

function Parser() {
	this.parse_error = false;
	this.error_message = '';

	this.setParseError = function(text) {
		this.parse_error = true;
		this.error_message = text;
	};

	this.parensBalanced = function(tokens) {
		// must be more than one token
		if(tokens.length < 2) {
			return(false); }
		// opening and closing must be correct
		if((tokens[0] != '(') || (tokens[tokens.length - 1] != ')')) {
			this.setParseError('Open or close parens missing');
			return(false); }
		var open = 0;
		for(var i in tokens) {
			if(tokens[i] == '(') {
				open++; }
			else if(tokens[i] == ')') {
				open--; }
			// sum of ) must be always less than (
			if(open < 0) {
				this.setParseError('Too many close parens');
				return(false); }
		};
		// equal number of ( and )
		if(open != 0) {
			this.setParseError('Parens unbalanced');
			return(false); }
		return(true);
	};

	this.tokenIsString = function(token) {
		if(token.length < 2) {
			return(false); }
		if((token[0] == '"') && (token[token.length - 1] == '"')) {
			return(true); }
		// some error
		this.setParseError('Malformed string');
		return(false);
	};

	this.stripQuotes = function(token) {
		// from tokenIsString, we know at least an array of 2 items
		return(token.slice(1, token.length - 1));
	};

	this.getParseItem = function(token) {
		// given a token, what is it?
		if(token == '(') {
			return(new ParseItem(PARSE_TYPES.OPEN)); }
		if(token == ')') {
			return(new ParseItem(PARSE_TYPES.CLOSE)); }
		// number? is ddd or dd.ddd
		if((token.match(/^[0-9]+$/)) || (token.match(/^[0-9]+\.[0-9]+/))) {
			return(new ParseItem(PARSE_TYPES.NUMBER, Number(token))); }
		if(this.tokenIsString(token)) {
			return(new ParseItem(PARSE_TYPES.STRING, this.stripQuotes(token))); }
		return(new ParseItem(PARSE_TYPES.IDENTIFIER, token));
	};

	// convert the tokens into values
	this.parseTokens = function(tokens) {
		if(!this.parensBalanced(tokens)) {
			return([]); }
		var parse_results = [];
		for(var i in tokens) {
			// go along tokens converting
			parse_results.push(this.getParseItem(tokens[i]));
		}
		return(parse_results);
	};
	
	this.getSubList = function(tokens, index) {
		// given a list of tokens and the index of the start of a sub-list,
		// return the sub-list
		var sub_list = [];
		var parens = 0;
		for(var i=index; i<tokens.length; i++) {
			if(tokens[i].type == PARSE_TYPES.OPEN) {
				parens += 1; }
			else if(tokens[i].type == PARSE_TYPES.CLOSE) {
				parens -= 1; }
			sub_list.push(tokens[i]);
			if(parens == 0) {
				return(sub_list); }
		}
		// some problem, no end parens found
		self.setParseError('No matching end param on sub-list');
		return([]);
	};
	
	this.makeTree = function(tokens) {
		// start a list
		console.log(tokens);
		var tree = [];
		// remove first and last parens
		tokens = tokens.splice(1, tokens.length - 2);
		for(var i=0; i<tokens.length; i++) {
			if(tokens[i].type == PARSE_TYPES.OPEN) {
				var mini_list = this.getSubList(tokens, i);
				i += mini_list.length;
				tree.push(this.makeTree(mini_list));
			}
			tree.push(tokens[i]);
		}
		return(tree);
	};
	
	this.convertToTree = function(tokens) {
		tokens = this.parseTokens(tokens);
		if(this.parse_error == true) {
			return([]); }
		return(this.makeTree(tokens));
	};
};

function prettyPrint(tree) {
	// given a code tree, print it
	var string = '(';
	for(var i in tree) {
		// if an array:
		if(tree[i] instanceof Array) {
			string += prettyPrint(tree[i]); }
		else if(tree[i].type == PARSE_TYPES.IDENTIFIER) {
			string += tree[i].value; }
		else if(tree[i].type == PARSE_TYPES.NUMBER) {
			string += tree[i].value.toString();
		}
		else if(tree[i].type == PARSE_TYPES.STRING) {
			string += '"' + tree[i].value + '"'; }
		else { // probably an error
			string += '??_' + tree[i].value + '_??'; }
		string += ' ';
	};
	return(string.trim() + ')');
};

