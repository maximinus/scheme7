"use strict";

var t = new Tokeniser();
var p = new Parser();
var c = new Compiler();

QUnit.test('Tokenise error test', function(assert) {
	t.setTokenError('test');
	assert.equal(t.token_error, true, 'Must show tokeniser error');
});

QUnit.test('Parser error test', function(assert) {
	p.setParseError('test');
	assert.equal(p.parse_error, true, 'Must show parser error');
});

QUnit.test('Parens test', function(assert) {
	var test = '(+ 2 3)';
	assert.equal(t.spaceParens(test), ' ( + 2 3 ) ', 'Parens must have spaces');
	var test = '(+ (+ 1) 2 3)';
	assert.equal(t.spaceParens(test), ' ( +  ( + 1 )  2 3 ) ', 'Parens must have spaces');
});

QUnit.test('Remove empty strings', function(assert) {
	var tokens = ['', '2', ''];
	assert.equal(t.removeEmptyStrings(tokens).length, 1, 'Empty strings must be removed');
	var tokens = [];
	assert.equal(t.removeEmptyStrings(tokens).length, 0, 'Empty strings must be removed');
});

QUnit.test('Token length test', function(assert) {
	var test = '(+ 2 3)';
	assert.equal(t.tokenise(test).tokens.length, 5, 'Number of tokens must be consistent');
	var test = '(+ (+ 1) 2 3)';
	assert.equal(t.tokenise(test).tokens.length, 9, 'Number of tokens must be consistent');
});

QUnit.test('String join test', function(assert) {
	var test = '(print "hi!")';
	assert.equal(t.tokenise(test).tokens.length, 4, 'Strings must be joined consistently');
	var test = '(print "hi man!")';
	assert.equal(t.tokenise(test).tokens.length, 4, 'Strings must be joined consistently');
});


QUnit.test('Parens Balanced', function(assert) {
	var test = '(+ 1 2)';
	var tokens = t.tokenise(test).tokens;
	assert.equal(p.parensBalanced(tokens), true, 'Parser must check for balanced parens');
	var test = '(+ 1 ( 2)';
	var tokens = t.tokenise(test).tokens;
	assert.equal(p.parensBalanced(tokens), false, 'Parser must check for balanced parens');
	var test = '(+ 1 (+ 4 5) (- 5 (- 6)) 2)';
	var tokens = t.tokenise(test).tokens;
	assert.equal(p.parensBalanced(tokens), true, 'Parser must check for balanced parens');
});

QUnit.test('Parser string check', function(assert) {
	var test = '"My String"';
	assert.equal(p.tokenIsString(test), true, 'Parser checks for broken strings');
	var test = '"My string is broken';
	assert.equal(p.tokenIsString(test), false, 'Parser checks for broken strings');
	var test = '"My String "" is fine"';
	assert.equal(p.tokenIsString(test), true, 'Parser checks for broken strings');

});

QUnit.test('ParseTokens check', function(assert) {
	var test = t.tokenise('(+ 1 2)').tokens;
	assert.equal(p.parseTokens(test).length, 5, 'ParseTokens get correct number');
	var test = t.tokenise('( + 1 2').tokens;
	assert.equal(p.parseTokens(test).length, 0, 'ParseTokens returns empty on error');
});

QUnit.test('Check ParseItems', function(assert) {
	var result = new ParseItem(PARSE_TYPES.OPEN);
	assert.equal(p.getParseItem('(').type, result.type, 'ParseItems gets open bracket');
	assert.equal(p.getParseItem('(').value, result.value, 'ParseItems gets open bracket');
	var result = new ParseItem(PARSE_TYPES.CLOSE);
	assert.equal(p.getParseItem(')').type, result.type, 'ParseItems gets close bracket');
	assert.equal(p.getParseItem(')').value, result.value, 'ParseItems gets close bracket');
	var result = new ParseItem(PARSE_TYPES.NUMBER, 23);
	assert.equal(p.getParseItem('23').type, result.type, 'ParseItems gets number of integer');
	assert.equal(p.getParseItem('23').value, result.value, 'ParseItems gets number of integer');
	var result = new ParseItem(PARSE_TYPES.NUMBER, 34.56)
	assert.equal(p.getParseItem('34.56').type, result.type, 'ParseItems gets number with fraction');
	assert.equal(p.getParseItem('34.56').value, result.value, 'ParseItems gets number with fraction');
	var result = new ParseItem(PARSE_TYPES.STRING, 'hello')
	assert.equal(p.getParseItem('"hello"').type, result.type, 'ParseItems gets string');
	assert.equal(p.getParseItem('"hello"').value, result.value, 'ParseItems gets string');
	var result = new ParseItem(PARSE_TYPES.IDENTIFIER, 'FOOBAR')
	assert.equal(p.getParseItem('FOOBAR').type, result.type, 'ParseItems gets identifier 1');
	assert.equal(p.getParseItem('FOOBAR').value, result.value, 'ParseItems gets identifier 1');
	var result = new ParseItem(PARSE_TYPES.IDENTIFIER, 'FOOBAR+!@')
	assert.equal(p.getParseItem('FOOBAR+!@').type, result.type, 'ParseItems gets identifier 2');
	assert.equal(p.getParseItem('FOOBAR+!@').value, result.value, 'ParseItems gets identifier 2');
});

QUnit.test('Check sublist acquisition', function(assert) {
	var tokens = p.parseTokens(t.tokenise('(+ 1 3 4)').tokens);
	assert.equal(p.getSubList(tokens, 0).length, 6, 'Sublist returns correct list');
	var tokens = p.parseTokens(t.tokenise('()').tokens);
	assert.equal(p.getSubList(tokens, 0).length, 2, 'Sublist returns correct list');
	var tokens = p.parseTokens(t.tokenise('(+ (- 3 4) 5)').tokens);
	assert.equal(p.getSubList(tokens, 2).length, 5, 'Sublist returns correct list');
});

QUnit.test('MakeTree check', function(assert) {
	var test = p.parseTokens(t.tokenise('(+ 1 2)').tokens);
	assert.equal(p.makeTree(test).length, 3, 'MakeTree gets correct number');
	var test = p.parseTokens(t.tokenise('(+ (+ 4 6) 1 2)').tokens);
	assert.equal(p.makeTree(test).length, 4, 'MakeTree handles sub-lists');
});

QUnit.test('PrettyPrint check', function(assert) {
	var test = p.parseTokens(t.tokenise('(+ 1 2)').tokens);
	assert.equal(p.makeTree(test).length, 3, 'MakeTree gets correct number');
	var test = p.parseTokens(t.tokenise('(+ (+ 4 6) 1 2)').tokens);
	assert.equal(p.makeTree(test).length, 4, 'MakeTree handles sub-lists');
});

QUnit.test('No compiler errors check', function(assert) {
	var result = c.compile('(+ 1 2)');
	assert.equal(result.error, '', 'Compiler compiles with no errors');
	var result = c.compile('(+ 1 (- 5 6) "hello")');
	assert.equal(result.error, '', 'Compiler compiles with string and no errors');
	var result = c.compile('(+ 1 (- 5 6) hello)');
	assert.equal(result.error, '', 'Compiler compiles with identifier and no errors');
});

