"use strict";

// all global constants are kept in one single variable called S7
// any other variables must be added to this namespace

var S7 = {'credits':['Chris Handy'],
		  'version':'0.02',
		  'last_update':'25th Jan 2015',
		  // default screen size
		  'WIDTH':640,
		  'HEIGHT':400,
		  //'MAX_COLLISIONS':5,
		  // how much time between bullets?
		  //'BULLET_PAUSE':5,
		  // font characterisitics
		  'TERMINAL':{'FONT_WIDTH':49, 'FONT_HEIGHT':102, 'CHAR_WIDTH':70, 'CHAR_HEIGHT':20},
		  'LEVELS':[],
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

