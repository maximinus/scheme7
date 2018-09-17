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
const STOP_BUBBLING = [BACKSPACE, RETURN];
const TEXT_SIZE = new Phaser.Geom.Rectangle(20, 20, 20, 32);
const FONT = {fontFamily: 'scheme7-terminal',
              fontSize: '32px',
              color: '#C85746'};

function can_render(char) {
    if(char.length > 1) {
        return false;
    }
    // check if char is in the list
    return(CHARS.indexOf(char) > -1);
};

class TerminalCharacter {
    constructor(character, text_image, can_delete=true) {
        this.character = character;
        this.image = text_image;
        this.can_delete = can_delete;
    };

    destroy() {
        this.image.destroy()
    };
};


class Cursor {
    constructor(scene) {
        this.timer = null;
        this.scene = scene;
    };

    add(position) {
        this.cursor = this.scene.add.text(position.x, position.y, '█', FONT);
        this.startFlash();
    };

    flash() {
        this.cursor.visible = !this.cursor.visible;
    };

    startFlash() {
        this.timer = this.scene.time.addEvent({delay: 800, callback: this.flash,
                                               callbackScope: this, loop: true});
    };

    stopFlash() {
        // stop the cursor animation
        if(this.timer != null) {
            this.timer.destroy();
        };
    };

    update(position) {
        this.stopFlash();
        this.cursor.visible = true;
        // move to new place
        this.cursor.x = position.x;
        this.cursor.y = position.y;
        this.startFlash();
    };

    destroy() {
        this.image.destroy()
    };
};


class TextHolder {
    // TODO: Add left / right / up  / down cursor
    //       Allow terminal to scroll up
    //       Accept size argument for the terminal

    constructor(scene, line_length, prompt) {
        this.line_length = line_length;
        this.line_position = 0;
        this.text = [];
        this.ypos = 0;
        this.prompt = prompt;
        this.scene = scene;
        this.addPrompt();
    };

    getCursorPos() {
        // where should the cursor be?
        var x = this.text.length % this.line_length;
        var y = Math.trunc(this.text.length / this.line_length);
        return new Phaser.Geom.Point((x * TEXT_SIZE.width) + TEXT_SIZE.x,
                                     (y * TEXT_SIZE.height) + this.ypos + TEXT_SIZE.y);
    };

    add(new_char, can_delete=true, color=null) {
        var pos = this.getCursorPos();
        // reset color?
        if(color != null) {
            var old_color = FONT.color;
            FONT.color = color;
            var new_text = this.scene.add.text(pos.x, pos.y, new_char, FONT);
            FONT.color = old_color;
        }
        else {
            var new_text = this.scene.add.text(pos.x, pos.y, new_char, FONT);
        }
        this.text.push(new TerminalCharacter(new_char, new_text, can_delete));
    };

    delete() {
        // delete if possible
        if(this.text[this.text.length - 1].can_delete == false) {
            return;
        }
        if(this.text.length > 0) {
            this.text.pop().destroy();
        }
    };

    newline() {
        // cursor moves to next line and input is removed
        // do we add more chars because of overflow?
        var total_lines = Math.trunc(this.text.length / this.line_length) + 1
        this.ypos += total_lines * TEXT_SIZE.height;
        this.resetText();
        this.addPrompt();
    };

    resetText() {
        // clean up the existing text
        this.text = [];
    }

    addPrompt() {
        // add a prompt and move the cursor over
        for(var c of this.prompt) {
            this.add(c, false, '#BBBBBB');
        }
    };
};

class TerminalScene extends Phaser.Scene {
    constructor() {
        super({key: 'TerminalScene'});
        this.current_line = [];
    };

    preload() {
        // pass
    };

    create() {
        this.text = new TextHolder(this, 38, 'S7> ');
        this.cursor = new Cursor(this);
        this.cursor.add(this.text.getCursorPos());
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
        //console.log(event);
        // we start by looking for special keys
        if(event.keyCode === BACKSPACE) {
            this.text.delete();
            this.cursor.update(this.text.getCursorPos());
            return;
        }

        if(event.keyCode === RETURN) {
            this.text.newline();
            this.cursor.update(this.text.getCursorPos());
        }

        // if we can't render, don't
        if(!can_render(event.key)) {
            return;
        }
        this.text.add(event.key);
        this.cursor.update(this.text.getCursorPos());
    };
};
