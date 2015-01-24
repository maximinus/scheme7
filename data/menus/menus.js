"use strict";

var MENUS = {}

MENUS.MAIN_SCREEN = {'keys':[['1', 'Messages'],
							 ['2', 'I want to print'],
							 ['3', 'Are all here'],
							 ['4', 'Do you understand?']],
					 'windows':[[0, 0, 23, 11, COLOURS.DARKGREY.getRBGA('0.35')]],
					 'strings':[[1, 1, 'Scheme7 v' + scheme7.version, COLOURS.WHITE],
								[1, 3, '1: New Game', COLOURS.CYAN],
								[1, 4, '2: Load Game', COLOURS.GREY],
								[1, 6, '3: About Scheme7', COLOURS.CYAN],
								[1, 7, '4: Exit Game', COLOURS.CYAN],
								[1, 9, 'Please enter a number', COLOURS.WHITE]]};

