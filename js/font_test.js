"use strict";

// calculate view size on page load
if(typeof window.innerWidth != 'undefined') {
	var WIDTH = window.innerWidth;
	var HEIGHT = window.innerHeight; }
else {
	// some error, use a small default
	var WIDTH = 640;
	var HEIGHT = 400; }


function preload() {
};

function create() {
};

function render() {
	 game.debug.text('Scheme7 Font Test', 32, 32);
};

function update() {
};

var game = new Phaser.Game(WIDTH, HEIGHT, Phaser.CANVAS, 'Scheme7', {preload:preload, create:create, update:update, render:render });

