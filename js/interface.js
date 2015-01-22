"use strict";

// font characterisitics
var FONT_WIDTH = 49;
var FONT_HEIGHT = 102;
var CHAR_WIDTH = 60;

function RandomNumber() {
	this.seed = (new Date.getTime()) % 32768;
	
	this.getRand = function() {
		var r = ((this.seed * 7621) + 1) % 32768;
		this.seed = r;
		return(r / 32768);
	};
};

function loadFonts() {
	game.load.image('monofur', 'data/fonts/monofur.png');
};

function createInterface() {
	start_screen.setup();
};

function ColourClass(r, g, b) {
	// store colour values
	this.r = r;
	this.g = g;
	this.b = b;
};

function StartScreen() {
	// this is an object to handle the start screen, which is:
	// some text that cn be chosen
	// a simple procedural mountains + sky scrolling backdrop
	this.terminal = new Terminal();
	
	this.setup = function() {
		terminal.setup();
	}
};

// class to handle text on a screen
function Terminal() {
	this.setup = function(width, height) {
		this.strings = new Array();
		// normal is white
		this.colour = new ColourClass(255, 255, 255);
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
		this.px_width = Math.floor(this.width / CHAR_WIDTH);
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
		image.update();
		image.processPixelRGB(this.processPixel, this, 0, 0, image.width, image.height)
		
		return(image);
	};

	this.processPixel = function(colour) {
		// colour is { r: number, g: number, b: number, a: number, color: number, rgba: string }
		// we just preserve the alpha value
		colour.r = this.colour.r;
		colour.g = this.colour.g;
		colour.b = this.colour.b;
		return(colour);
	};

	this.print = function(x, y, text, colour) {
		// get the image
		console.log(colour);
		var image = this.renderStringImage(text);
		var xpos = (x * this.px_width) + this.xoffset;
		var ypos = (y * this.px_height) + this.yoffset;
		var scale = (text.length * this.px_width) / image.width;
		var sprite = game.add.sprite(xpos, ypos, image)
		// scale image
		sprite.scale = new PIXI.Point(scale, scale);
		this.strings.push(sprite);
	};
	
	this.cls = function(x, y, text) {
		// clear all sprites in the array
		for(var i in this.strings) {
			this.strings[i].destroy();
		}
	};

	this.create = function() {
		this.print(0, 0, 'Scheme7 v0.01');
		this.print(0, 1, 'Code & Design Chris Handy 2014');
	};
};

