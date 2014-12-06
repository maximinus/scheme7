"use strict";

var WIDTH = 800;
var HEIGHT = 600;

var game = new Phaser.Game(WIDTH, HEIGHT, Phaser.CANVAS, 'Scheme7', {preload:preload, create:create, update:update});
var cursors;
var player;
var flag;

function setupPhysics() {
	game.physics.startSystem(Phaser.Physics.P2JS);
	game.physics.p2.gravity.y = 24;
    game.physics.p2.restitution = 0.2;
};

function preload() {
	game.load.image('ship', 'gfx/ship.png');
	game.load.image('ground', 'gfx/ground.png');
};

function create() {
	setupPhysics();

	player = game.add.sprite(350, 150, 'ship');
	// true is for the visual debugger
	game.physics.p2.enable(player, true);
	player.body.clearShapes();
	player.body.addPolygon({}, [[0,0], [-25,60], [25,60], [0,0]]);


	var ground = game.add.sprite(0, 550, 'ground');
	game.physics.p2.enable(ground, false);
	ground.body.clearShapes();
	ground.body.addPolygon({}, [[0,0], [WIDTH,0], [WIDTH,5], [0,5], [0,0]]);
	ground.body.static = true;
	
	game.camera.follow(player);
	
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

