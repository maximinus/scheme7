"use strict";

// global constants
var MAX_COLLISIONS = 5;
// how much time between bullets?
var BULLET_PAUSE = 5;

// calculate view size on page load
if(typeof window.innerWidth != 'undefined') {
	var WIDTH = window.innerWidth;
	var HEIGHT = window.innerHeight; }
else {
	// some error, use a small default
	var WIDTH = 640;
	var HEIGHT = 400; }

// a state is a section of something that acts differently. 1 of these states is the game
// the other is the UI. The game is run via the keyboard.
function TextInterface() {
	this.preload = function() {
	
	};
	
	this.create = function() {
	};
	
	this.render = function() {
	};
};

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

function setupPhysics() {
	game.physics.startSystem(Phaser.Physics.P2JS);
	game.physics.p2.gravity.y = LEVEL.physics.gravity;
    game.physics.p2.restitution = LEVEL.physics.restitution;
};

function buildPlayer() {
	var player = game.add.sprite(LEVEL.player.xpos, LEVEL.player.ypos, 'ship');
	
	// true is for the visual debugger
	game.physics.p2.enable(player, true);
	player.body.clearShapes();
	player.body.addPolygon({}, [[0,-30], [-25,30], [25,30]]);
	// 0.5 because of moved offsets for rotation
	player.anchor.set(0.5, 0.5);
	return(player);
};

function getBoundingRect(coords) {
	// coords is an array of coords representing the position
	// we need to return an array of [xmin, ymin, width, height]
	var xpos = coords.map(function(v, i, a) { return(v[0]); });
	var ypos = coords.map(function(v, i, a) { return(v[1]); });
	var minx = Math.min.apply(Math, xpos);
	var miny = Math.min.apply(Math, ypos);
	// return the bounds
	return([minx, miny, Math.max.apply(Math, xpos) - minx, Math.max.apply(Math, ypos) - miny]);
};

function generateWallImage(bounds, coords, colour) {
	// bounds: [xpos, ypos, width, height]
	var image = game.add.bitmapData(bounds[2], bounds[3]);
	// cycle through the coords and correct for x/y
	// all the points in these new coords are inside the image
	image.ctx.fillStyle = colour;
	image.ctx.beginPath();
	image.ctx.moveTo(coords[0][0], coords[0][1]);
	for(var i=1; i<coords.length; i++) {
		image.ctx.lineTo(coords[i][0], coords[i][1]); 
	}
	image.ctx.closePath();
	image.ctx.fill();
	return(image);
};

function setLevelBounds(bounds) {
	// given an array of [xpos, ypos, width, height], calculate the
	// bounds for this level and set them
	var xmax = Math.max.apply(Math, bounds.map(function(v, i, a) { return(v[2] + v[0]); }));
	var ymax = Math.max.apply(Math, bounds.map(function(v, i, a) { return(v[3] + v[1]); }));
	// add half the size of the screen, allow extra 1 for off-by one errors
	game.world.setBounds(0, 0, xmax, ymax);
};

function buildLevel() {
	var level_bounds = new Array();
	for(var i in LEVEL.walls) {
		var bounds = getBoundingRect(LEVEL.walls[i].coords);
		var coords = LEVEL.walls[i].coords.map(function(v, i, a) { return([v[0] - bounds[0], v[1] - bounds[1]]) });
		
		level_bounds.push(bounds);
		var image = generateWallImage(bounds, coords, LEVEL.area_colour);
		var sprite = game.add.sprite(bounds[0], bounds[1], image);
		game.physics.p2.enable(sprite, false);
		sprite.body.clearShapes();
		sprite.body.addPolygon({}, coords);
		sprite.body.static = true;
		// must do this to correct for Phaser
		// also remove line this.adjustCenterOfMass() in fromPolygon() in Phaser source
		sprite.anchor.set(0,0);
	};
	setLevelBounds(level_bounds);
};

function preload() {
	game.load.image('ship', 'data/gfx/ship.png');
	// some test images
	game.load.image('test', 'data/gfx/test.png');
	game.load.image('square', 'data/gfx/square.png');
};

function create() {
	setupPhysics();
	buildLevel();
	s7.setup();
	game.camera.follow(s7.player);
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

function Game() {
	// game controller
	// put things in the constructor, which is this.setup()
	this.ship_rotated = false;
	

	this.setup = function() {
		this.addPlayer(buildPlayer());
		this.cursors = game.input.keyboard.createCursorKeys();
		this.emitter = new Emitter();
		this.bullet = generateSpriteImage(4, 4, '#FFFFFF');
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
			this.player.body.thrust(350); };
		if(this.cursors.down.isDown) {
			// fire a bullet
			this.fireBullet();
		};
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
		if(eq[0].contactPointA == null) {
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
	
	this.fireBullet = function() {
		// get player angle and position
		var xpos = this.player.body.x - 50;
		var ypos = this.player.body.y;
		var angle = this.player.body.angle;
		var sprite = game.add.sprite(xpos, ypos, this.bullet);
		game.physics.p2.enable(sprite, false);
		sprite.body.clearShapes();
		sprite.body.addCircle(2);
	};
};

function render() {
	 game.debug.text('Xpos/Ypos:' + (s7.player.x|0) + ',' + (s7.player.y|0) + ' - ' + HEIGHT, 32, 32);
};

//var s7 = new Game();
var start_screen = new StartScreen();

// game can be seen as the view
if(typeof CODE_TESTING == 'undefined') {
	//var game = new Phaser.Game(WIDTH, HEIGHT, Phaser.CANVAS, 'Scheme7', {preload:preload, create:create, update:s7.update.bind(s7), render:render }); }
	var game = new Phaser.Game(WIDTH, HEIGHT, Phaser.CANVAS, 'Scheme7', {preload:loadFiles, create:createInterface, update:start_screen.update.bind(start_screen) }); }
else {
	var game = null;
}

