"use strict";

// start with an environment
var Env = {};
var token_error = false;

function setTokenError(text) {
	token_error = true;
};

function spaceParens(text) {
	// put spaces around the parens:
	text = text.replace(/\(/g, ' ( ');
	text = text.replace(/\)/g, ' ) ');
	return(text);
};

function removeEmptyStrings(tokens) {
	// remove null strings at start and end of the list
	return(tokens.filter(function(value) { return(value != ''); }));
};

function joinStrings(tokens) {
	// traverse the array looking for one that starts with a "
	// token is always a string of length > 0
	var new_tokens = [];
	for(var i=0; i<tokens.length; i++) {
		// does it start with "?
		if(textIsNotFullyQuoted(tokens[i])) {
			var index = readUntilQuote(tokens.slice(i + 1));
			// now we know how long the quote is, so create it and store
			console.log(tokens.slice(i, i+index));
			new_tokens.push(tokens.slice(i, i+index).join());
			// 1 is added to i next iteration
			i += index;
		}
		else {
			new_tokens.push(tokens[i]);
		}
	}
	return(new_tokens);
};

function readUntilQuote(tokens) {
	var i;
	for(i=0; i<tokens.length;i++) {
		if(endIsQuote(tokens[i])) {
			// +1 because we need the offset (and arrat is zero-indexed)
			return(i + 1); }
	}
	// there is an error
	setTokenError('String does not end');
	return(-1);
};

function textIsNotFullyQuoted(text) {
	// test further is start is not a quote
	if(text[0] != '"') {
		return(false); }
	return(!endIsQuote(text));
};

function endIsQuote(text) {
	// only length 1, easy:
	if(text.length == 1) {
		return(text[0] == '"'); }
	// otherwise, have to check for \ before:
	return((text[text.length-1] == '"') && (text[text.length-2] != '\\'));
};

function tokenise(text) {
	text = spaceParens(text);
	var tokens = text.split(/\s+/);
	tokens = removeEmptyStrings(tokens);
	tokens = joinStrings(tokens);
	return(tokens);
};

