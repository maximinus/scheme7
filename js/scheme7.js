"use strict";

var WIDTH = 800;
var HEIGHT = 600;

var game = new Phaser.Game(WIDTH, HEIGHT, Phaser.CANVAS, 'Scheme7', {preload:preload, create:create, update:update});

function setupPhysics() {
	game.physics.startSystem(Phaser.Physics.P2JS);
	game.physics.p2.gravity.y = 10;
    game.physics.p2.restitution = 0.8;
};

function preload() {
	game.load.image('ship', 'gfx/ship.png');
	game.load.image('ground', 'gfx/ground.png');
};

function create() {
	setupPhysics();

	var player = game.add.sprite(350, 150, 'ship');
	// true is for the visual debugger
	game.physics.p2.enable(player, false);
	player.body.clearShapes();
	player.body.addPolygon({}, [[0,0], [-25,60], [25,60],[0,0]]);


	var ground = game.add.sprite(0, 550, 'ground');
	game.physics.p2.enable(ground, true);
	ground.body.clearShapes();
	ground.body.addPolygon({}, [[0,0], [WIDTH,0], [WIDTH,5], [0,5], [0,0]]);
};

function update() {
};

