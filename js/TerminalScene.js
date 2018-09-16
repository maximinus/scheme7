/*

How does the terminal work?

There is a flashing block at one point
When buttons are pressed, a character is drawn and the console moved to the right
If the characters move too far to the right, they move to the next line down
When the console moves, it switches to the start of the 'ON' pattern
Backspace moves the cursor left and deletes the character
Left moves the cursor OVER the character and reverses the character when the cursor flashes on
When return is pressed, the cursor moves down a line and to the left, and the screen scrolls up
Pressing up/down cycles through previous commands
If a button is held down, there is a pause and then the character is drawn again
Repeated buttondown events are instant

Functions we need:

* Get the size of a character
* Draw the cursor
* Accept a keypress

*/

// only render these chars
var CHARS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890!@#$%^&*()_+-=<>?,./:";\'{}[] '

// prevent key bubbling
const BACKSPACE = 8;
const RETURN =13;
const STOP_BUBBLING = [BACKSPACE. RETURN];


function can_render(char) {
    if(char.length > 1) {
        return false;
    }
    // check if char is in the list
    return(CHARS.indexOf(char) > -1);
};

class TerminalCharacter {
    constructor(character, text_image) {
        this.character = character;
        this.image = text_image;
    };

    destroy() {
        this.image.destroy()
    };
};


class Cursor {
    constructor(width, height, font, scene) {
        this.position = new Phaser.Geom.Rectangle(16, 16, width, height);
        this.font = font;
        this.timer = null;
        this.scene = scene;
    };

    add(text_function) {
        this.cursor = text_function(this.position.x, this.position.y, '█', this.font);
        this.startFlash();
    };

    flash() {
        this.cursor.visible = !this.cursor.visible;
    };

    startFlash() {
        console.log(this.scene.time.addEvent);
        this.timer = this.scene.time.addEvent({delay: 800, callback: this.flash,
                                               callbackScope: this, loop: true});
    };

    stopFlash() {
        // stop the cursor animation
        if(this.timer != null) {
            this.timer.destroy();
        };
    };

    update(deltax, deltay) {
        this.stopFlash();
        this.cursor.visible = true;
        // move to new place
        this.cursor.x += deltax;
        this.cursor.y += deltay;
        this.startFlash();
    };

    destroy() {
        this.image.destroy()
    };
};


class TerminalScene extends Phaser.Scene {
    constructor() {
        super({key: 'TerminalScene'});
        this.current_line = [];
        this.font = {fontFamily: 'scheme7-terminal',
                     fontSize: '32px',
                     color: '#C85746'};
        this.char_width = 20;
        this.char_height = 35;
        this.xpos = 16;
        this.ypos = 16;
    };

    preload() {
        // pass
    };

    create() {
        this.cursor = new Cursor(this.char_width, this.char_height, this.font, this);
        this.cursor.add(this.add.text.bind(this.add));
        // we need to tell Phaser what keys to not bubble
        for(var keycode of STOP_BUBBLING) {
            this.input.keyboard.addKey(keycode);
        }
        this.input.keyboard.on('keydown', this.keydown, this);
    };

    update() {
        // pass
    };

    keydown(event) {
        console.log(event);
        // we start by looking for special keys
        if(event.keyCode === BACKSPACE) {
            this.cursor.update(-this.char.width, 0);
            // delete the last character if we have one
            if(this.current_line.length > 0) {
                this.current_line.pop().destroy();
                this.xpos -= this.char_width;
            }
            return;
        }

        // if we can't render, don't
        if(!can_render(event.key)) {
            return;
        }
        this.cursor.update(this.char_width, 0);
        var new_text = this.printCharacter(event.key);
        this.current_line.push(new TerminalCharacter(event.key, new_text));
    };

    printCharacter(character) {
        // print the character, move the cursor
        var new_text = this.add.text(this.xpos, this.ypos, character, this.font);
        this.xpos += this.char_width;
        return new_text;
    };
};
