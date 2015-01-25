"use strict";

// A level, defined as a javascript literal object
S7.LEVELS.push({
	'name':'Level 1',
	// the array is xpos, ypos, height, width
	'areas':[{'draw':true, 'coords':[20, 20, 760, 10]},
			 {'draw':true, 'coords':[20, 30, 10, 520]},
			 {'draw':true, 'coords':[20, 550, 760, 10]},
			 {'draw':true, 'coords':[770, 30, 10, 520]}],
	'area_colour':'#ff00ff',
	'physics':{'gravity':24,
			   'restitution':0.2},
});

