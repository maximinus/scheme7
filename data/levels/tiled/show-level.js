"use strict";

function MapDraw() {
	this.clearScreen = function() {
		this.ctx.fillStyle = '#ffffff';
		this.ctx.fillRect(0, 0, this.width, this.height);
	};
	
	this.renderMap = function() {
		// use the variable test-level
		console.log(test_level.length + ' shapes to render');
		for(var i in test_level) {
			this.drawShape(test_level[i]);
		}
	};
	
	this.drawShape = function(shape) {
		console.log(shape)
		// offsets already included in file. Just multiply by size and we are done.
		// we draw a shape in green and a line in black. Shape first
		this.ctx.strokeStyle = '#00ff00';
		this.ctx.fillStyle = '#00ff00';
		this.ctx.lineWidth = 2;
		this.ctx.beginPath();
		this.ctx.moveTo((shape[0][0] * this.size), (shape[0][1] * this.size));
		var end_point = shape.shift()
		for(var i in shape) {
		
			console.log(shape[i][0] * this.size, shape[i][1] * this.size);
		
			this.ctx.lineTo((shape[i][0] * this.size), (shape[i][1] * this.size)); }
		this.ctx.lineTo(end_point[0] * this.size, end_point[1] * this.size);
		this.ctx.stroke();
		this.ctx.fill();
		this.ctx.closePath();

		shape.unshift(end_point);
		this.ctx.strokeStyle = '#000000';
		this.ctx.lineWidth = 2;
		this.ctx.beginPath();
		this.ctx.moveTo((shape[0][0] * this.size), (shape[0][1] * this.size));
		var end_point = shape.shift()
		for(var i in shape) {
			this.ctx.lineTo((shape[i][0] * this.size), (shape[i][1] * this.size)); }
		this.ctx.lineTo(end_point[0] * this.size, end_point[1] * this.size);
		this.ctx.stroke();
		this.ctx.closePath();
	};

	this.canvas = document.getElementById('map-canvas');
	this.ctx = this.canvas.getContext('2d');
	this.width = 768;
	this.height = 512;
	this.clearScreen();
	this.size = 32;
};

function drawMap() {
	var engine = new MapDraw();
	engine.renderMap();
};

window.addEventListener('load', drawMap, false);


