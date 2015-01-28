"use strict";

// a menu screen has 2 things: messages, and keys that can be pressed
// the keys are the most important. We need the key, and what to do when the key is pressed.

// what can happen?
// 1: We go to a different menu
// 2: We run some arbitary code

// The arbitrary code could be anything. HOWEVER, we have access to the globals game, S7 and D7
// S7 is globals, D7 is game data. The latter has extensive routines to extract information

// keys:
// [KEY CHAR, FUNCTION, ARRAY OF DATA] OR
// [KEY CHAR, NEW_MENU]

// windows:
// [XPOS, YPOS, WIDTH, HEIGHT, COLOUR_AS_RBGA]

// strings
// [XPOS, YPOS, TEXT]

// there must be a menu MAIN_SCREEN, and that's where it all starts

S7.MENUS = {'MAIN_SCREEN':{
				'keys':[['1', D7.makeToast, ['New Game']],
					    ['2', D7.makeToast, ['Load Game']],
					    ['3', 'ABOUT_SCREEN']],
				'windows':[[0, 0, 23, 10, S7.COLOURS.DARKGREY.getRBGA('0.35')]],
				'strings':[[1, 1, 'Scheme7 v' + S7.version, S7.COLOURS.WHITE],
						   [1, 3, '1: New Game', S7.COLOURS.CYAN],
						   [1, 4, '2: Load Game', S7.COLOURS.GREY],
						   [1, 6, '3: About Scheme7', S7.COLOURS.CYAN],
						   [1, 8, 'Please enter a number', S7.COLOURS.WHITE]]},
			'ABOUT_SCREEN':{
				'keys':[['1', 'MAIN_SCREEN']],
				'windows':[[0, 0, 21, 10, S7.COLOURS.DARKGREY.getRBGA('0.35')]],
				'strings':[[1, 1, 'Scheme7 v' + S7.version, S7.COLOURS.WHITE],
						   [1, 3, 'Code & Design:', S7.COLOURS.GREY],
						   [3, 4, 'Chris Handy', S7.COLOURS.GREY],
						   [1, 6, 'Written with Phaser', S7.COLOURS.GREY],
						   [1, 8, '1: Return', S7.COLOURS.WHITE]]},
			'runMenu':function(func, data) { func.apply(D7, data); },
};

