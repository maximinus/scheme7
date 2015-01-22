"use strict";

// font characterisitics
var FONT_WIDTH = 49;
var FONT_HEIGHT = 102;
var CHAR_WIDTH = 60;
var STAR_TYPES

function loadFiles() {
	loadFonts();
	loadImages();
};

function loadFonts() {
	game.load.image('monofur', 'data/fonts/monofur.png');
};

function loadImages() {
	game.load.image('star1', 'data/gfx/stars/star1.png');
	game.load.image('star2', 'data/gfx/stars/star2.png');
	game.load.image('star3', 'data/gfx/stars/star3.png');
	game.load.image('star4', 'data/gfx/stars/star4.png');
	game.load.image('star5', 'data/gfx/stars/star5.png');
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
	// some kind of background
	this.terminal = new Terminal();
	this.stars = new StarField();
	
	this.setup = function() {
		this.terminal.setup();
		this.stars.setup();
		// add out options
		this.terminal.print(0, 0, 'Scheme7 v0.01', Terminal.WHITE);
		this.terminal.print(0, 2, '1: New Game', Terminal.CYAN);
		this.terminal.print(0, 3, '2: Load Game', Terminal.GREY);
		this.terminal.print(0, 5, '3: About Scheme7', Terminal.CYAN);
		this.terminal.print(0, 6, '4: Exit Game', Terminal.CYAN);
	};
	
	this.update = function() {
		this.stars.update();
	};
};

function StarField() {
	// handles a starfield
	this.distance = 600;
	this.speed = 1.8;
	this.stars = [];
	this.max_stars = 400;
	this.xpos = [];
	this.ypos = [];
	this.zpos = [];

	this.setup = function() {
		this.sprites = game.add.spriteBatch();
		for(var i = 0; i < this.max_stars; i++) {
			// TODO: Fix magic numbers
			this.xpos[i] = Math.floor(Math.random() * 1600) - 800;
    	    this.ypos[i] = Math.random() > 0.5 ? 80:-80;
    	    this.zpos[i] = Math.floor(Math.random() * 2700) + 320;

			// choose a star in the form star[1-5]
			var starname = 'star' +  (Math.floor(Math.random() * (6 - 1)) + 1).toString();
			var star = game.make.sprite(0, 0, starname);
			star.anchor.set(0.5);
			this.sprites.addChild(star);
			this.stars.push(star);
		}
    };

	this.update = function update() {
		for(var i = 0; i < this.max_stars; i++) {
			this.stars[i].perspective = this.distance / (this.distance - this.zpos[i]);
			this.stars[i].x = game.world.centerX + this.xpos[i] * this.stars[i].perspective;
			this.stars[i].y = game.world.centerY + this.ypos[i] * this.stars[i].perspective;
			this.zpos[i] += this.speed;
			if(this.zpos[i] > 550) {
				this.zpos[i] -= 1500; }
			this.stars[i].scale.set(Math.abs(this.stars[i].perspective / 12));
    	}
	};
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
		var old_colour = this.colour;
		if(colour != undefined) {
			this.colour = colour; }
		// get the image
		var image = this.renderStringImage(text);
		var xpos = (x * this.px_width) + this.xoffset;
		var ypos = (y * this.px_height) + this.yoffset;
		var scale = (text.length * this.px_width) / image.width;
		var sprite = game.add.sprite(xpos, ypos, image)
		// scale image
		sprite.scale = new PIXI.Point(scale, scale);
		this.strings.push(sprite);
		this.colour = old_colour;
	};
	
	this.cls = function(x, y, text) {
		// clear all sprites in the array
		for(var i in this.strings) {
			this.strings[i].destroy();
		}
	};
};

// some static colours
Terminal.RED = new ColourClass(255, 0, 0);
Terminal.GREEN = new ColourClass(0, 255, 0);
Terminal.BLUE = new ColourClass(0, 0, 255);
Terminal.WHITE = new ColourClass(255, 255, 255);
Terminal.BLACK = new ColourClass(0, 0, 0);
Terminal.YELLOW = new ColourClass(255, 255, 0);
Terminal.ORANGE = new ColourClass(255, 127, 0);
Terminal.CYAN = new ColourClass(0, 255, 255);
Terminal.PURPLE = new ColourClass(255, 0, 255);
Terminal.BROWN = new ColourClass(150, 100, 50);
Terminal.GREY = new ColourClass(127, 127, 127);

