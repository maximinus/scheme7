"use strict";

// to stop game from running, set a global
var CODE_TESTING = true;

QUnit.test("Test Example", function( assert ) {
	var value = "hello";
	assert.equal( value, "hello", "We expect value to be hello" );
});

