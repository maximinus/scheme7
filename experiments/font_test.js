"use strict";

// Note: using this code gets us the average text WIDTH of font_size in px * 0.55
//                           and an average text HEIGHT of font_size in px * (0.85 x 1.5) = 1.275

// so the ratio of width:height of 1 letter for px x would be 0.55x:1.275x

// for a screen ratio that is 1.6:1 we get a ratio of 3.87:1 width/height
// this can give us either 80x21 resolution, or about 

var frequency = [40, 7, 14, 21, 64, 11, 10, 31, 35, 1, 4, 20, 12, 33, 37, 10, 1, 30, 31, 45, 14, 5, 12, 1, 10, 1]
var letters = 'abcdefghijklmnopqrstuvwxyz'

// calculate view size on page load
if(typeof window.innerWidth != 'undefined') {
	var WIDTH = window.innerWidth;
	var HEIGHT = window.innerHeight; }
else {
	// some error, use a small default
	var WIDTH = 640;
	var HEIGHT = 400; }

function testMetrics() {
	// get some simple metrics for analysis
	// make a stupid string of all letters with frequencies
	var base_string = '';
	for(var i in frequency) {
		var chr = letters.charAt(i);
		for(var j=0; j<frequency[i]; j++) {
			base_string += chr; }
	}
	var style = {font:'100px font-standard', fill:'#ffffff', align:'left'};
	var text = game.add.text(0, 0, base_string, style);
	console.log(text.height + ' height');
};

function testHeights() {
	// do we have enough spacing?
	var text1 = 'qYp[_!yMKkj';
	var text2 = 'plD%@->yWL;';
	var style = {font:'50px font-standard', fill:'#ffffff', align:'left'};
	// from previous, we know height @ 50px = 41
	game.add.text(0, 0, text1, style);
	// but this is not enough, however, 41 * 1.5 is
	game.add.text(0, 61, text2, style);
}

function outputSize() {
	console.log('Width: ' + WIDTH + ' / Height: ' + HEIGHT);
	console.log('Ratio: ' + (WIDTH / HEIGHT));
	// we want a ratio of 1.6
	// if width / height > 1.6, screen is too wide
	// otherwise, screen is too tall
	// but we want a border of 5% of the screen
	// let's factor the border in first
};

function create() {
	//outputSize();
	//testMetrics();
	var style = {font:'50px serif', fill:'#ff0077', align:'left'};
	game.add.text(0, 250, 'Phaser test', style);
	testHeights();
};

var game = new Phaser.Game(WIDTH, HEIGHT, Phaser.CANVAS, 'Scheme7', {create:create});

