"use strict";

var GRID_SIZE = 32;
var GRID_X = 18;
var GRID_Y = 10;

function Grid(width, height) {
	this.render = function(ctx) {
		this.ctx.fillStyle = '#00ff00';
		this.ctx.fillRect(0, 0, this.width, this.height);
		
		// now the grid itself
		var spacing = this.width / (GRID_X + 1);
		var xoff = spacing / 2;
		var yoff = (this.height - (GRID_Y * spacing)) /2;
		// draw the grid
		this.ctx.strokeStyle = '#000000';
		this.ctx.lineWidth = 1;
		for(var xpos=0; xpos<=((GRID_X + 1)* spacing); xpos+=spacing) {
			this.drawLine([xpos + xoff, yoff],[xpos + xoff, yoff + (GRID_Y * spacing)]);
		}
		for(var ypos=0; ypos<=((GRID_Y + 1) * spacing); ypos+=spacing) {
			this.drawLine([xoff, yoff + ypos], [xoff + ((GRID_X) * spacing), yoff + ypos]);
		}
		this.points = [];
		for(var xpos=0; xpos<=((GRID_X + 1)* spacing); xpos+=spacing) {
			for(var ypos=0; ypos<=((GRID_Y + 1) * spacing); ypos+=spacing) {
				this.points.push([xpos + xoff, ypos + yoff]);
			}
		}
		// copy the canvas and store elsewhere
		back_ctx.drawImage(this.canvas, 0, 0);
	};
	
	this.drawLine = function(start, end) {
		this.ctx.beginPath();
		this.ctx.moveTo(start[0], start[1]);
		this.ctx.lineTo(end[0], end[1]);
		this.ctx.stroke();
		this.ctx.closePath();
	};
	
	this.updateMouse = function(e) {
		// convert to real co-ords
		var rect = this.canvas.getBoundingClientRect();
		console.log([e.clientX - rect.left, e.clientY - rect.top]);
	};
	
	this.canvas = document.getElementById('grid-canvas');
	this.canvas.style.cursor = 'none'
	this.ctx = this.canvas.getContext('2d');
	this.canvas.addEventListener('mousemove', this.updateMouse.bind(this));
	this.width = width;
	this.height = height;
	var back = document.createElement('canvas');
	var back_ctx = back.getContext('2d');
	back.width = this.width;
	back.height = this.height;
	this.points = [];
	// vars for grid
	this.zoom = 1;
};

function Editor() {
	this.width = 768;
	this.height = 512;
	
	this.init = function() {
		// set size of iconbar and grid
		this.grid = new Grid(this.width, this.height);
		this.grid.render(this.ctx);
	};
};

function startEditor() {
	var editor = new Editor();
	editor.init();
};

window.addEventListener('load', startEditor, false);


