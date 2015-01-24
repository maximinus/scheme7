"use strict";

// font characterisitics
var FONT_WIDTH = 49;
var FONT_HEIGHT = 102;
var CHAR_WIDTH = 60;
var CHAR_HEIGHT = 38;

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
	game.load.image('stargrey', 'data/gfx/stars/stargrey.png');
};

function createInterface() {
	start_screen.setup();
};

function ColourClass(r, g, b) {
	// store colour values
	this.r = r;
	this.g = g;
	this.b = b;
	
	this.getHexString = function() {
		return('#' + this.r.toString(16) + this.g.toString(16) + this.b.toString(16));
	};
	
	this.getRBGA = function(alpha) {
		return('rgba(' + [this.r, this.g, this.b, alpha].join() + ')');
	};
};

function StartScreen() {
	// this is an object to handle the start screen, which is:
	// some text that cn be chosen, some kind of background and the key handlers
	this.terminal = new Terminal();
	this.stars = new StarField();
	this.keys = ['1', '2', '3', '4'];
	
	this.setup = function() {
		this.terminal.setup();
		this.stars.setup();
		// add out options
		this.terminal.addWindow(0, 0, 23, 11, Terminal.DARKGREY.getRBGA('0.35'));
		this.terminal.print(1, 1, 'Scheme7 v' + scheme7.version, Terminal.WHITE);
		this.terminal.print(1, 3, '1: New Game', Terminal.CYAN);
		this.terminal.print(1, 4, '2: Load Game', Terminal.GREY);
		this.terminal.print(1, 6, '3: About Scheme7', Terminal.CYAN);
		this.terminal.print(1, 7, '4: Exit Game', Terminal.CYAN);
		this.terminal.print(1, 9, 'Please enter a number', Terminal.WHITE);
	};
	
	this.update = function() {
		this.checkKeys();
		this.stars.update();
		this.terminal.update();
	};
	
	this.checkKeys = function() {
	};
};

function Star(speed, starname) {
	// set position
	var pos = Math.floor(Math.random() * 600) - 300;
	this.xpos = pos;
	this.ypos = Math.random() > 0.5 ? pos + 90: pos - 90;
    this.zpos = Math.floor(Math.random() * 2200) + 320;
	if(starname === undefined) {
		var starname = 'star' +  (Math.floor(Math.random() * (6 - 1)) + 1).toString(); }
	this.sprite = game.make.sprite(0, 0, starname);
	this.sprite.anchor.set(0.5);
	this.speed = speed;
	this.distance = 600;
	this.scaling = true;

	this.update = function() {
		this.sprite.perspective = this.distance / (this.distance - this.zpos);
		this.sprite.x = game.world.centerX + this.xpos * this.sprite.perspective;
		this.sprite.y = game.world.centerY + this.ypos * this.sprite.perspective;
		this.zpos += this.speed;
		if(this.zpos > 550) {
			this.zpos -= 1500; }
		this.sprite.alpha = Math.min(this.sprite.perspective / 2, 1);
		if(this.scaling == true) {
			this.sprite.scale.set(Math.abs(this.sprite.perspective) / 10); }
   	};
};

function StarField() {
	// handles a starfield
	this.stars = [];
	this.max_stars = 300;

	this.setup = function() {
		this.sprites = game.add.spriteBatch();
		for(var i = 0; i < this.max_stars; i++) {
			var new_star = new Star(2.8);
			this.sprites.addChild(new_star.sprite);
			this.stars.push(new_star);
			
			new_star = new Star(1.2, 'stargrey');
			new_star.scaling = false;
			this.sprites.addChild(new_star.sprite);
			this.stars.push(new_star);
		}
	};

	this.update = function() {
		for(var i in this.stars) {
			this.stars[i].update();
    	}
	};
};

function getWindow(width, height, colour) {
	// contains a glass effect window with transparency and colour
	if(colour === undefined) {
		var colour = Terminal.GREY.getRBGA(0.5); }
	var radius = 10;
	// build the image
	var image = game.add.bitmapData(width, height);
	// clear to black and dcoords lines all over
	image.ctx.fillStyle = colour;
	image.ctx.beginPath();
	image.ctx.moveTo(0 + radius, 0);
	image.ctx.lineTo(width - radius, 0);
	image.ctx.quadraticCurveTo(width, 0, width, radius);
	image.ctx.lineTo(width, height - radius);
	image.ctx.quadraticCurveTo(width, height, width - radius, height);
	image.ctx.lineTo(radius, height);
	image.ctx.quadraticCurveTo(0, height, 0, height - radius);
	image.ctx.lineTo(0, radius);
	image.ctx.quadraticCurveTo(0, 0, radius, 0);
	image.ctx.closePath();
	image.ctx.stroke();
	image.ctx.fill();
	return(image);
};

function ToastMessage(time, sprite) {
	this.time = time;
	this.sprite = sprite;
	this.alpha_delta = 0.05;
	// toast alphas always start at 0, i.e. not showing
	this.alpha = 0;
	this.fade = true;
	this.sprite.alpha = this.alpha;
	
	this.update = function() {
		if(this.fade ==  true) {
			this.alpha += this.alpha_delta;
			if(this.alpha >= 1) {
				// faded in complete. start timer
				this.alpha = 0;
				window.setTimeout(this.startFadeOut.bind(this), this.time);
			}
			else if(this.alpha <= 0) {
				// faded out, can destroy this sprite
				this.sprite.destroy()
				return(true);
			}
			this.sprite.alpha = this.alpha;
		}
		return(false);
	};
	
	this.startFadeOut = function() {
		this.fade = true;
		this.alpha_delta *= -1;
	};
};

// class to handle text on a screen
function Terminal() {
	this.setup = function(width, height) {
		this.strings = new Array();
		this.toast = new Array();
		// normal is white
		this.colour = new ColourClass(255, 255, 255);8
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
		// width and height are set by this point. CHAR_WIDTH characters across
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
		var sprite = this.buildSprite(x, y, text, colour);
		this.strings.push(sprite);
	};

	this.buildSprite = function(x, y, text, colour) {
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
		this.colour = old_colour;
		return(sprite);
	};
	
	this.cls = function(x, y, text) {
		// clear all sprites in the array
		for(var i in this.strings) {
			this.strings[i].destroy();
		}
	};
	
	this.addWindow = function(xpos, ypos, width, height, colour) {
		var xpos = (xpos * this.px_width) + this.xoffset;
		var ypos = (ypos * this.px_height) + this.yoffset;
		// convert to real height and width
		width *= this.px_width;
		height *= this.px_height;
		var window = getWindow(width, height, colour);
		var sprite = game.add.sprite(xpos, ypos, window)
		this.strings.push(sprite);
	};
	
	this.addToast = function(string, time) {
		// add a toast message, simialar to android
		// it will fade in, stay around for time seconds, and then clear
		if(time === undefined) {
			var time = 5000; }
		// build the sprite
		// must be in the middle of the screen, at the bottom
		var xpos = Math.floor((CHAR_WIDTH - string.length) / 2);
		var sprite = this.buildSprite(xpos, CHAR_HEIGHT - 1, string);
		this.toast.push(new Toast(sprite, time));
	};
	
	this.update = function() {
		// normally we do very little, but we have to check toast...
		if(this.toast.length == 0) {
			return; }
		// handle the current toast only. this.toast is a queue
		if(this.toast[0].update() == true) {
			// toast has ended, delete the first one
			this.toast.shift()
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
Terminal.LIGHTGREY = new ColourClass(208, 208, 208);
Terminal.GREY = new ColourClass(127, 127, 127);
Terminal.DARKGREY = new ColourClass(48, 48, 48);

