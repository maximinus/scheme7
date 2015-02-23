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
		this.back_ctx.drawImage(this.canvas, 0, 0);
	};
	
	this.drawLine = function(start, end) {
		this.ctx.beginPath();
		this.ctx.moveTo(start[0], start[1]);
		this.ctx.lineTo(end[0], end[1]);
		this.ctx.stroke();
		this.ctx.closePath();
	};
	
	this.drawMousePoint = function(p) {
		if(this.points.length == 0) {
			return; }			
		var smallest = 100000;
		for(var i in this.points) {
			var d = Math.pow(Math.abs(this.points[i][0] - p[0]), 2) + Math.pow(Math.abs(this.points[i][1] - p[1]), 2);
			if(d < smallest) {
				smallest = d;
				var point = this.points[i]; }
		}
		this.drawGridPoint(point);
	};
	
	this.clearGridPoint = function() {
		if(this.highlight_point == null) {
			return; }
		// redraw the grid surrounding the point by 13 pixels
		var x = this.highlight_point[0] - 13;
		var y = this.highlight_point[1] - 13;
		// copy over from back image
		this.ctx.drawImage(this.back, x, y, 26, 26, x, y, 26, 26);
	};
	
	this.drawGridPoint = function(point) {
		this.clearGridPoint();
		// draw the circle at the given point
		this.ctx.beginPath();
		this.ctx.arc(point[0], point[1], 12, 0, 2 * Math.PI, false);
		this.ctx.fillStyle = 'green';
		this.ctx.fill();
		this.ctx.lineWidth = 2;
		this.ctx.strokeStyle = '#003300';
		this.ctx.stroke();
		this.highlight_point = point;
	};
	
	this.updateMouse = function(e) {
		// convert to real co-ords
		var rect = this.canvas.getBoundingClientRect();
		var point = this.drawMousePoint([e.clientX - rect.left, e.clientY - rect.top])
	};
	
	this.canvas = document.getElementById('grid-canvas');
	//this.canvas.style.cursor = 'none'
	this.ctx = this.canvas.getContext('2d');
	this.canvas.addEventListener('mousemove', this.updateMouse.bind(this));
	this.width = width;
	this.height = height;
	this.back = document.createElement('canvas');
	this.back_ctx = this.back.getContext('2d');
	this.back.width = this.width;
	this.back.height = this.height;
	this.points = [];
	this.highlight_point = null;
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


