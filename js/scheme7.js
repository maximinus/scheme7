"use strict";

var WIDTH = 800;
var HEIGHT = 600;

if(typeof CODE_TESTING == 'undefined') {
	var game = new Phaser.Game(WIDTH, HEIGHT, Phaser.CANVAS, 'Scheme7', {preload:preload, create:create, update:update}); }
else {
	var game = null;
}

var cursors;
var player;
var flag;

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
	player = game.add.sprite(350, 150, 'ship');
	// true is for the visual debugger
	game.physics.p2.enable(player, true);
	player.body.clearShapes();
	player.body.addPolygon({}, [[0,0], [-25,60], [25,60]]);
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
	buildPlayer();
	buildLevel();
	//game.camera.follow(player);
	cursors = game.input.keyboard.createCursorKeys();
};

function update() {
	if(cursors.left.isDown) {
		player.body.rotateLeft(40);
		flag = true; }
	else if(cursors.right.isDown) {
		player.body.rotateRight(40);
		flag = true; }
	else if(flag == true) {
		player.body.setZeroRotation();
		flag = false; }
	if(cursors.up.isDown) {
		player.body.thrust(80); };
};

