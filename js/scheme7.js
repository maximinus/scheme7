"use strict";

// global constants
var MAX_COLLISIONS = 5;

// calculate view size on page load
if(typeof window.innerWidth != 'undefined') {
	var WIDTH = window.innerWidth;
	var HEIGHT = window.innerHeight; }
else {
	// some error, use a small default
	var WIDTH = 640;
	var HEIGHT = 400; }

function generateSpriteImage(width, height, colour) {
	var image = game.add.bitmapData(width, height);
	// clear to black and dcoords lines all over
	image.ctx.fillStyle = '#000000';
	image.ctx.fillRect(0, 0, width, height);
	// top, bottom, left, right lines
	image.ctx.strokeStyle = colour;
	image.ctx.lineWidth = 1;
	image.ctx.strokeRect(0, 0, width, height);
	// now we can make the sprite
	return(image);
};

function generateParticleImage() {
	var image = game.add.bitmapData(1, 1);
	image.ctx.fillStyle = '#FFFFFF';
	image.ctx.fillRect(0, 0, 1, 1);
	return(image);
};

function calculateBounds() {
	// from the level, calculate the level bounding
	// first generate a list of all co-ords
	var xcoords = new Array();
	var ycoords = new Array();
	var boxes = LEVEL.areas;
	for(var i in boxes) {
		// generate and save kust the top-left and bottom-right (only after max and min)
		xcoords.push(boxes[i][0], boxes[i][0] + boxes[i][2]);
		ycoords.push(boxes[i][1], boxes[i][1] + boxes[i][3]);
	}
	// make an array of thos values, x and y, min and max
	// add half the size of the screen, allow extra 1 for off-by one errors
	var limits = [Math.min.apply(Math, xcoords) - ((WIDTH / 2) + 1)];
	limits.push(Math.max.apply(Math, xcoords) + ((WIDTH / 2) + 1));
	limits.push(Math.min.apply(Math, ycoords) - ((HEIGHT / 2) + 1));
	limits.push(Math.max.apply(Math, ycoords) + ((HEIGHT / 2) + 1));
	return(limits);
};

function setupPhysics() {
	game.physics.startSystem(Phaser.Physics.P2JS);
	game.physics.p2.gravity.y = LEVEL.physics.gravity;
    game.physics.p2.restitution = LEVEL.physics.restitution;
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
	var boxes = LEVEL.areas;
	var colour = LEVEL.area_colour;
	for(var i in boxes) {
		var coords = boxes[i].coords;
		var image = generateSpriteImage(coords[2], coords[3], colour);
		var sprite = game.add.sprite(coords[0], coords[1], image);
		game.physics.p2.enable(sprite, false);
		sprite.body.clearShapes();
		sprite.body.addPolygon({}, [[0, 0],	[coords[2], 0], [coords[2], coords[3]], [0, coords[3]]]);
		sprite.body.static = true;
	}
	var bounds = calculateBounds();
	game.world.setBounds(bounds[0], bounds[1], bounds[2], bounds[3]);
};

function preload() {
	game.load.image('ship', 'gfx/ship.png');
	// a simple green circle as a test image
	game.load.image('test', 'gfx/test.png');
};

function create() {
	setupPhysics();
	buildLevel();
	s7.setup();
	game.camera.follow(s7.player);
	game.camera.roundPx = false;
};

function Emitter() {
	var image = generateParticleImage();
	this.emitter = game.add.emitter(0, 0, 10);
	this.emitter.makeParticles(image);
	this.emitter.gravity = 200;
	
	this.start = function(xpos, ypos) {
		this.emitter.x = xpos;
		this.emitter.y = ypos;
		this.alpha = 0.5;
		// from 0 to 1, in 1000ms
		this.emitter.setAlpha(1, 0, 2000);
		// true = explode, 2000ms length, do 10 particles
		this.emitter.start(true, 2000, null, 10);
	};
};

function CollisionEmitter() {
	// problem: we only want MAX_COLLISIONS to be showing.
	// if more than this, stop the oldest and make that the new one
};

function Game() {
	// game controller
	this.ship_rotated = false;
	
	this.setup = function() {
		this.addPlayer(buildPlayer());
		this.cursors = game.input.keyboard.createCursorKeys();
		this.emitter = new Emitter();
	};
	
	this.update = function() {
		if(this.cursors.left.isDown) {
			this.player.body.rotateLeft(40);
			this.ship_rotated = true; }
		else if(this.cursors.right.isDown) {
			this.player.body.rotateRight(40);
			this.ship_rotated = true; }
		else if(this.ship_rotated == true) {
			this.player.body.setZeroRotation();
			this.ship_rotated = false; }
		if(this.cursors.up.isDown) {
			this.player.body.thrust(80); };
	};
	
	this.addPlayer = function(player) {
		this.player = player;
		this.player.body.onBeginContact.add(this.playerCollide, this);
	};
	
	this.addCollisionDamage = function(speed) {
		// damage is the square of the speed
		console.log('Damage:', speed * speed);
	};
	
	this.playerCollide = function(body, shapeA, shapeB, eq) {
		// get the speed of the collision
		if(eq[0] != null) {
			var speed = Phaser.Point.distance(new Phaser.Point(eq[0].bodyB.velocity[0], eq[0].bodyB.velocity[1]), new Phaser.Point(0,0));
			//this.addCollisionDamage(speed);
		}
		if(eq[0].contactPointB == null) {
			return; }
		var pos = eq[0].bodyA.position;
		var pnt = eq[0].contactPointA;
		this.drawParticles(pos[0] + pnt[0], pos[1] + pnt[1]);
	};
	
	this.drawParticles = function(xpos, ypos) {
		xpos = xpos * -20;
		ypos = ypos * -20;
		// xpos and ypos are world co-ordinates
		this.emitter.start(xpos, ypos);
	};
};

var s7 = new Game();

// game can be seen as the view
if(typeof CODE_TESTING == 'undefined') {
	var game = new Phaser.Game(WIDTH, HEIGHT, Phaser.CANVAS, 'Scheme7', {preload:preload, create:create, update:s7.update.bind(s7) }); }
else {
	var game = null;
}

