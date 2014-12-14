"use strict";

var t = new Tokeniser();
var p = new Parser();

QUnit.test('Tokenise error test 1', function(assert) {
	t.setTokenError('test');
	assert.equal(t.token_error, true, 'Must show tokeniser error');
});

QUnit.test('Parser error test 1', function(assert) {
	p.setParseError('test');
	assert.equal(p.parse_error, true, 'Must show parser error');
});

QUnit.test('Parens test 1', function(assert) {
	var test = '(+ 2 3)';
	assert.equal(t.spaceParens(test), ' ( + 2 3 ) ', 'Parens must have spaces');
});

QUnit.test('Parens test 2', function(assert) {
	var test = '(+ (+ 1) 2 3)';
	assert.equal(t.spaceParens(test), ' ( +  ( + 1 )  2 3 ) ', 'Parens must have spaces');
});

QUnit.test('Remove empty strings 1', function(assert) {
	var tokens = ['', '2', ''];
	assert.equal(t.removeEmptyStrings(tokens).length, 1, 'Empty strings must be removed');
});

QUnit.test('Remove empty strings 2', function(assert) {
	var tokens = [];
	assert.equal(t.removeEmptyStrings(tokens).length, 0, 'Empty strings must be removed');
});

QUnit.test('Token length test 1', function(assert) {
	var test = '(+ 2 3)';
	assert.equal(t.tokenise(test).tokens.length, 5, 'Number of tokens must be consistent');
});

QUnit.test('Token length test 2', function(assert) {
	var test = '(+ (+ 1) 2 3)';
	assert.equal(t.tokenise(test).tokens.length, 9, 'Number of tokens must be consistent');
});

QUnit.test('String join test 1', function(assert) {
	var test = '(print "hi!")';
	assert.equal(t.tokenise(test).tokens.length, 4, 'Strings must be joined consistently');
});

QUnit.test('String join test 2', function(assert) {
	var test = '(print "hi man!")';
	assert.equal(t.tokenise(test).tokens.length, 4, 'Strings must be joined consistently');
});

QUnit.test('Parens Balanced 1', function(assert) {
	var test = '(+ 1 2)';
	var tokens = t.tokenise(test).tokens;
	assert.equal(p.parensBalanced(tokens), true, 'Parser must check for balanced parens');
});

QUnit.test('Parens Balanced 2', function(assert) {
	var test = '(+ 1 ( 2)';
	var tokens = t.tokenise(test).tokens;
	assert.equal(p.parensBalanced(tokens), false, 'Parser must check for balanced parens');
});

QUnit.test('Parens Balanced 3', function(assert) {
	var test = '(+ 1 (+ 4 5) (- 5 (- 6)) 2)';
	var tokens = t.tokenise(test).tokens;
	assert.equal(p.parensBalanced(tokens), true, 'Parser must check for balanced parens');
});

QUnit.test('Parser string check 1', function(assert) {
	var test = '"My String"';
	assert.equal(p.tokenIsString(test), true, 'Parser checks for broken strings');
});

QUnit.test('Parser string check 1', function(assert) {
	var test = '"My string is broken';
	assert.equal(p.tokenIsString(test), false, 'Parser checks for broken strings');
});

QUnit.test('Parser string check 1', function(assert) {
	var test = '"My String "" is fine"';
	assert.equal(p.tokenIsString(test), true, 'Parser checks for broken strings');
});

