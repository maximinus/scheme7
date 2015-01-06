"use strict";

function interface_create() {
	console.log(terminal);
	terminal.setup(game, 0, 0);
};

// class to handle text on a screen
function Terminal() {
	this.setup = function(game, width, height) {
		// we build the 
		this.xpos = 0;
		this.ypos = 0;
		this.game = game;
		this.create();
	};
	
	this.create = function() {
		var style = {font:'50px scheme7-standard', fill:'#ff0066', align:'left'};
		game.add.text(this.xpos, this.ypos, 'Hello, World', style);
	};
};

