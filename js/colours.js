"use strict";

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

S7['COLOURS'] = {
	RED:new ColourClass(255, 0, 0),
	GREEN:new ColourClass(0, 255, 0),
	BLUE:new ColourClass(0, 0, 255),
	WHITE:new ColourClass(255, 255, 255),
	BLACK:new ColourClass(0, 0, 0),
	YELLOW:new ColourClass(255, 255, 0),
	ORANGE:new ColourClass(255, 127, 0),
	CYAN:new ColourClass(0, 255, 255),
	PURPLE:new ColourClass(255, 0, 255),
	BROWN:new ColourClass(150, 100, 50),
	LIGHTGREY: new ColourClass(208, 208, 208),
	GREY:new ColourClass(127, 127, 127),
	DARKGREY:new ColourClass(48, 48, 48),
};

