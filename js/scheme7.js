"use strict";

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
};

function create() {
	setupPhysics();
	s7.addPlayer(buildPlayer());
	s7.cursors = game.input.keyboard.createCursorKeys();
	buildLevel();
	game.camera.follow(s7.player);
};

function Game() {
	// game controller
	this.cursors = null;
	this.player = null;
	this.ship_rotated = false;
	
	this.update = function() {
		if(s7.cursors.left.isDown) {
			this.player.body.rotateLeft(40);
			this.ship_rotated = true; }
		else if(s7.cursors.right.isDown) {
			this.player.body.rotateRight(40);
			this.ship_rotated = true; }
		else if(s7.ship_rotated == true) {
			this.player.body.setZeroRotation();
			this.ship_rotated = false; }
		if(this.cursors.up.isDown) {
			this.player.body.thrust(80); };
	};
	
	this.addPlayer = function(player) {
		this.player = player;
		this.player.body.onBeginContact.add(this.playerCollide, this);
	};
	
	this.addCollisionDamage(speed) {
		// damage is the square of the speed
		console.log('Damage:', speed * speed);
	};
	
	this.playerCollide = function(body, shapeA, shapeB, eq) {
		// get the speed of the collision
		if(eq[0] != null) {
			var speed = Phaser.Point.distance(new Phaser.Point(eq[0].bodyB.velocity[0], eq[0].bodyB.velocity[1]), new Phaser.Point(0,0)); }
			this.addCollisionDamage(speed);
		}
		console.log(eq);
	};
};

var s7 = new Game();

// game can be seen as the view
if(typeof CODE_TESTING == 'undefined') {
	var game = new Phaser.Game(WIDTH, HEIGHT, Phaser.CANVAS, 'Scheme7', {preload:preload, create:create, update:s7.update.bind(s7) }); }
else {
	var game = null;
}

