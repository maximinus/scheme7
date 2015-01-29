"use strict";

// all game data is stored here. This is transient data that can be saved
// or has history, or are game options. As a result, this must be stored locally
// and then re-loaded when we start the game up

function GameSave() {
	// all the data for a game save
	this.score = 0;
};

function Options() {
};

var D7 = {
	// first we have functions and data we never actually store
	makeToast:function(string) {
		if(this.terminal != null) {
			this.terminal.addToast(string);
		}
	},
	
	newGame:function(player_name) {
		var game = new GameSave();
		games[player_name] = game;
		this.current_game = game;
	},
	
	terminal:null,
	current:null,

	// games: all saved games
	games:{},
	// options: options taken by user
	options:{},
};

function initWebStorage(){
	// fill D7 with default values
	// all of this data must be json enabled
	localStorage.setItem('S7', 'enabled');
	localStorage.setItem('games', JSON.stringify({}));
	localStorage.setItem('options', JSON.stringify(new Options()));
};

function restoreData() {
	D7.games = localStorage.getItem('games');
	D7.options = localStorage.getItem('options');
};

function checkWebStorage() {
	// check for a flag
	if(!localStorage.getItem('S7')) {
		restoreData(); }
	else {
		console.log('Initing local web storage');
		initWebStorage(); }
};

// when the game starts, we need to check to make sure that web storage is turned on
checkWebStorage();

