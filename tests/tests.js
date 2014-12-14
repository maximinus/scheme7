"use strict";

QUnit.test('Parens test 1', function(assert) {
	var test = '(+ 2 3)';
	assert.equal(spaceParens(test), ' ( + 2 3 ) ', 'Parens must have spaces');
});

QUnit.test('Parens test 2', function(assert) {
	var test = '(+ (+ 1) 2 3)';
	assert.equal(spaceParens(test), ' ( +  ( + 1 )  2 3 ) ', 'Parens must have spaces');
});

QUnit.test('Remove empty strings 1', function(assert) {
	var tokens = ['', '2', ''];
	assert.equal(removeEmptyStrings(tokens).length, 1, 'Empty strings must be removed');
});

QUnit.test('Remove empty strings 2', function(assert) {
	var tokens = [];
	assert.equal(removeEmptyStrings(tokens).length, 0, 'Empty strings must be removed');
});

QUnit.test('Token length test 1', function(assert) {
	var test = '(+ 2 3)';
	assert.equal(tokenise(test).length, 5, 'Number of tokens must be consistent');
});

QUnit.test('Token length test 2', function(assert) {
	var test = '(+ (+ 1) 2 3)';
	assert.equal(tokenise(test).length, 9, 'Number of tokens must be consistent');
});

QUnit.test('String join test 1', function(assert) {
	var test = '(print "hi!")';
	assert.equal(tokenise(test).length, 4, 'Strings must be joined consistently');
});

QUnit.test('String join test 2', function(assert) {
	var test = '(print "hi man!")';
	assert.equal(tokenise(test).length, 4, 'Strings must be joined consistently');
});

QUnit.test('String join test 3', function(assert) {
	var test = '(print "hi man, this is longer ( ( with some stuff!")';
	assert.equal(tokenise(test).length, 4, 'Strings must be joined consistently');
});

