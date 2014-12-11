"use strict";

var TERM_SETTINGS = {
	greetings: 'Scheme7 Terminal',
	name: 'Scheme7',
	height: 480,
	prompt: '> '};

$(function($, undefined) {
	$('#terminal').terminal(readInput, TERM_SETTINGS);
});

