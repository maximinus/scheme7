"use strict";

// font characterisitics
var FONT_WIDTH = 49;
var FONT_HEIGHT = 102;

function loadFonts() {
	game.load.image('monofur', 'data/fonts/monofur.png');
};

function createInterface() {
	terminal.setup();
};

// class to handle text on a screen
function Terminal() {
	this.setup = function(width, height) {
		this.strings = new Array();
		this.colour = null;
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
		this.xoffset = Math.floor((WIDTH - this.width) / 2);
		this.yoffset = Math.floor((HEIGHT - this.height) / 2);
	};
	
	this.calculateFontSize = function() {
		// width and height are set by this point. 80 characters across
		this.px_width = Math.floor(this.width / 80);
		this.px_height = Math.floor(this.px_width * (FONT_HEIGHT / FONT_WIDTH));
	};

	this.renderStringImage = function(string) {
		// given a string, render to the correct size
		// convert the string to an array of ASCII and subtract 32
		var chars = new Array();
		for(var i=0; i<string.length; i++) {
			chars.push(string.charCodeAt(i) - 32); }
		// make an empty image and blit font to it
		var image = game.add.bitmapData(FONT_WIDTH * chars.length, FONT_HEIGHT);
		// blit the letters
		var xpos = 0;
		for(var i in chars) {
			var source_rect = new Phaser.Rectangle(chars[i] * FONT_WIDTH, 0, FONT_WIDTH, FONT_HEIGHT);			
			image.copyRect('monofur', source_rect, xpos, 0);
			xpos += FONT_WIDTH;
		}
		this.renderStringColour();
		return(this.stringResize(image));
		var fimage = game.add.bitmapData(this.px_width * chars.length, this.px_height);
		var scale = fimage.width / image.width;
		fimage.copy(image, 0, 0, image.width, image.height, 0, 0, fimage.width, fimage.height);
		return(fimage);
	};

	this.renderStringColour = function() {
		if(this.colour == null) {
			return; }
	};

	this.setColour = function(new_colour) {
		this.colour = new_colour;
	};

	this.print = function(x, y, text) {
		// get the image
		var image = this.renderStringImage(text);
		var xpos = (x * this.px_width) + this.xoffset;
		var ypos = (y * this.px_height) + this.yoffset;
		var sprite = game.add.sprite(xpos, ypos, image);
	};
	
	this.cls = function(x, y, text) {
		// clear all sprites in the array
		for(var i in this.strings) {
			this.strings[i].destroy();
		}
	};

	this.create = function() {
		this.print(0, 0, 'Scheme7 0.1 by Chris Handy');
		this.print(0, 1, 'Test font functions');
		this.print(2, 2, 'This line is offset by 2');
	};
};

