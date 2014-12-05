"use strict";

var game = new Phaser.Game(800, 600, Phaser.CANVAS, 'Scheme7', {preload:preload, create:create, update:update});

function Ship() {
	this.xpos = 0;
	this.ypos = 0;
	this.colour = 0xAA8822;
	
	this.polygons = new Array();
	
	this.addPolygon = function(points) {
		for(var i in points) {
			points[i]['x'] += this.xpos;
			points[i]['y'] += this.ypos;
		}
		var poly = new Phaser.Polygon([]);
		poly.setTo(points);
		this.polygons.push(poly);
	};
	
	this.render = function(gfx) {
		for(var i in this.polygons) {
			gfx.beginFill(this.colour);
			gfx.drawPolygon(this.polygons[i].points);
			gfx.endFill();
		}
	};
};

function preload() {
};

function create() {
	var player = new Ship();
	player.ypos = 50;
	player.xpos = 150;
	player.addPolygon([{x:0, y:0}, {x:-100, y:240}, {x:0, y:200}]);
	player.addPolygon([{x:0, y:0}, {x:0, y:200}, {x:100, y:240}]);

	var gfx = game.add.graphics(0, 0);
	console.log(gfx);
	player.render(gfx);
};

function update() {
};

