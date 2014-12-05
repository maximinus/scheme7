"use strict";

var game = new Phaser.Game(400, 600, Phaser.CANVAS, 'Scheme7', {preload:preload, create:create, update:update});

function Ship() {
	this.xpos = 0;
	this.ypos = 0;
	
	this.polygons = new Array();
};

function preload() {
};

function create() {
	var player = new Ship();
	player.xpos = 100;
	player.ypos = 100;
	
	var poly1 = new Phaser.Polygon([]);
	poly1.setTo({x:0, y:20}, {x:5, y:0}, {x:10, y:0});
	graphics = game.add.graphics(0, 0);
	graphics.beginFill(0xFF33ff);
	
	graphics.drawPolygon(poly1.points);

	graphics.endFill();
};

function update() {
};

