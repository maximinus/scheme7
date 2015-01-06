"use strict";

function interface_create() {
	terminal.setup();
};

// class to handle text on a screen
function Terminal() {
	this.setup = function(width, height) {
		// precalculate sides
		this.calculateArea()
		this.calculateFontSize();
		this.create();
	};

	this.calculateArea = function() {
		// we need a border of 5%
		this.width = WIDTH * 0.9;
		this.height = HEIGHT * 0.9;
		if((this.width / this.height) > 1.6) {
			// too wide, adjust width
			this.width = this.height * 1.6; }
		else {
			// too tall
			this.height = this.width * 1.6; }
	};
	
	this.calculateFontSize = function() {
		// width and height are set by this point. 80 characaters across
		var px = Math.floor((this.width / 80) / 0.55).toString();
		// line height is 1.5x this (reduction of (((width / 80) / 0.55) / 1.17) * 1.5
		this.char_height = Math.floor((px / 1.17) * 1.5);
		this.char_width = Math.floor(this.width / 80);
		// yoffset to make sure half of spacing at the top
		this.yoffset = Math.floor((this.char_height / 6) + (HEIGHT / 20));
		this.xoffset = Math.floor(WIDTH / 20);
		this.style = {font:px + 'px scheme7-standard', fill:'#ee0088', align:'left'};
	};

	this.print = function(x, y, text) {
		var xpos = this.xoffset + (x * this.char_width);
		var ypos = this.yoffset + (y * this.char_height);
		game.add.text(xpos, ypos, text, this.style);
	};
	
	this.cls = function(x, y, text) {
	};

	this.create = function() {
		this.print(0, 0, 'Scheme 0.1 by Chris Handy');
		this.print(0, 1, 'Test font functions');
	};
};

