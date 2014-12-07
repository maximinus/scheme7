"use strict";

var WIDTH = 800;
var HEIGHT = 600;

function generateSpriteImage(width, height) {
	var image = game.add.bitmapData(width, height);
	// clear to black and draw lines all over
	image.ctx.fillStyle = '#000000';
	image.ctx.fillRect(0, 0, width, height);
	// top, bottom, left, right lines
	image.ctx.strokeStyle = '#ff00ff';
	image.ctx.lineWidth = 1;
	image.ctx.strokeRect(0, 0, width, height);
	// now we can make the sprite
	return(image);
};

function setupPhysics() {
	game.physics.startSystem(Phaser.Physics.P2JS);
	game.physics.p2.gravity.y = 24;
    game.physics.p2.restitution = 0.2;
};

function buildPlayer() {
	var player = game.add.sprite(350, 150, 'ship');
	// true is for the visual debugger
	game.physics.p2.enable(player, true);
	player.body.clearShapes();
	player.body.addPolygon({}, [[0,0], [-25,60], [25,60]]);
	return(player);
};

function buildLevel() {
	// the array is xpos, ypos, height, width
	var boxes = [[20, 20, 760, 10], [20, 30, 10, 520], [20, 550, 760, 10], [770, 30, 10, 520]];
	for(var i in boxes) {
		var image = generateSpriteImage(boxes[i][2], boxes[i][3]);
		var sprite = game.add.sprite(boxes[i][0], boxes[i][1], image);
		game.physics.p2.enable(sprite, false);
		sprite.body.clearShapes();
		sprite.body.addPolygon({}, [[0, 0],	[boxes[i][2], 0], [boxes[i][2], boxes[i][3]], [0, boxes[i][3]]]);
		sprite.body.static = true;
	}
};

function preload() {
	game.load.image('ship', 'gfx/ship.png');
};

function create() {
	setupPhysics();
	model.player = buildPlayer();
	model.cursors = game.input.keyboard.createCursorKeys();
	buildLevel();
	game.world.setBounds(0, 0, 1920, 1920);
	game.camera.follow(model.player);
};

function GameModel() {
	// data model for game
	this.cursors = null;
	this.player = null;
	this.ship_rotated = false;
	
	this.update = function() {
		if(model.cursors.left.isDown) {
			this.player.body.rotateLeft(40);
			this.ship_rotated = true; }
		else if(model.cursors.right.isDown) {
			this.player.body.rotateRight(40);
			this.ship_rotated = true; }
		else if(model.ship_rotated == true) {
			this.player.body.setZeroRotation();
			this.ship_rotated = false; }
		if(this.cursors.up.isDown) {
			this.player.body.thrust(80); };
	};
};

var model = new GameModel();

// game can be seen as the view
if(typeof CODE_TESTING == 'undefined') {
	var game = new Phaser.Game(WIDTH, HEIGHT, Phaser.CANVAS, 'Scheme7', {preload:preload, create:create, update:model.update.bind(model) }); }
else {
	var game = null;
}

