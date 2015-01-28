"use strict";

// all game data is stored here. This is transient data that can be saved
// or has history, or are game options. As a result, this must be stored locally
// and then re-loaded when we start the game up

var D7 = {
	makeToast:function(string) {
		if(this.terminal != null) {
			this.terminal.addToast(string);
		}
	},
	terminal:null,
};

