"use strict";

S7.MENUS = {'MAIN_SCREEN':{
				'keys':[['1', 'Messages'],
					    ['2', 'I want to print'],
					    ['3', 'Are all here'],
					    ['4', 'Do you understand?']],
				'windows':[[0, 0, 23, 11, S7.COLOURS.DARKGREY.getRBGA('0.35')]],
				'strings':[[1, 1, 'Scheme7 v' + S7.version, S7.COLOURS.WHITE],
						   [1, 3, '1: New Game', S7.COLOURS.CYAN],
						   [1, 4, '2: Load Game', S7.COLOURS.GREY],
						   [1, 6, '3: About Scheme7', S7.COLOURS.CYAN],
						   [1, 7, '4: Exit Game', S7.COLOURS.CYAN],
						   [1, 9, 'Please enter a number', S7.COLOURS.WHITE]]},
};
						   

