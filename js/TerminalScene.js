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

*/

// only render these chars
var CHARS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890!@#$%^&*()_+-=<>?,./:";\'{}[] '

// prevent key bubbling
const BACKSPACE = 8;
const RETURN =13;
const CURSOR_RIGHT = 39;
const CURSOR_LEFT = 37;

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
    constructor(character, text_image, can_edit=true) {
        this.character = character;
        this.image = text_image;
        this.can_edit = can_edit;
    };

    destroy() {
        this.image.destroy()
    };

    setPosition(position) {
        this.image.x = position.x;
        this.image.y = position.y;
    };
};

class Cursor {
    constructor(scene, position) {
        this.timer = null;
        this.scene = scene;
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


class TextLine {
    // a line of text, or one command, currently in the terminal
    constructor(line_length, yoffset=0) {
        this.line_length = line_length;
        this.yoffset = yoffset;
        this.text = [];
    };

    add(t_char, index=-1) {
        if((index < 0) || (index > this.text.length)) {
            // append to end
            this.text.push(t_char);
        }
        else {
            this.text.splice(index, 0, t_char);
        }
        // update places
        this.arrange();
    };

    remove(index=-1) {
        if((index < 0) || (index > this.text.length)) {
            // remove from end
            if(this.text[this.text.length - 1].can_edit == true) {
                this.text.pop().destroy();
            }
        }
        else {
            // remove this index position
            if(this.text[index].can_edit == true) {
                this.text[index].destroy()
                this.text.splice(index, 1);
            }
        }
        this.arrange();
    };

    getPosition(index) {
        // given the index position, return where this should be
        var xpos = index % this.line_length;
        var ypos = Math.trunc(index / this.line_length);
        xpos = (xpos * TEXT_SIZE.width) + TEXT_SIZE.x;
        ypos = (ypos * TEXT_SIZE.height) + TEXT_SIZE.y + this.yoffset;
        return new Phaser.Geom.Point(xpos, ypos);
    };

    arrange() {
        // given the offset and size, make sure
        // they are in the right place
        for(var i = 0; i < this.text.length; i++) {
            this.text[i].setPosition(this.getPosition(i));
        }
    };

    getEndPos() {
        // normally where the cursor should be
        return this.getPosition(this.text.length);
    }

    clear() {
        // return the current images and clear the current text
        var old_chars = this.text.map(x => x.image);
        this.text = [];
        return old_chars;
    };

    toString() {
        var string = [];
        for(var i of this.text) {
            if(i.can_edit == true) {
                string.push(i.character);
            }
        }
        return string.join('');
    };
};

class TextHolder {
    // TODO: Move cursor object into textholder
    //       Add left / right / up  / down cursor
    //       Allow terminal to scroll up
    //       Accept size argument for the terminal
    constructor(scene, line_length, prompt) {
        this.text = new TextLine(line_length);
        this.prompt = prompt;
        this.scene = scene;
        this.displayed = [];
        this.cursor = new Cursor(scene, this.text.getEndPos());
        this.addPrompt();
    };

    buildChar(new_char, pos, color=null) {
        // reset color?
        if(color != null) {
            var old_color = FONT.color;
            FONT.color = color;
            var new_char = this.scene.add.text(pos.x, pos.y, new_char, FONT);
            FONT.color = old_color;
        }
        else {
            var new_char = this.scene.add.text(pos.x, pos.y, new_char, FONT);
        }
        return new_char
    };

    add(new_char, can_edit=true, color=null) {
        var pos = this.text.getEndPos();
        var new_text = this.buildChar(new_char, pos, color);
        this.text.add(new TerminalCharacter(new_char, new_text, can_edit));
        this.cursor.update(this.text.getEndPos());
    };

    delete() {
        this.text.remove();
        this.cursor.update(this.text.getEndPos());
    };

    newline() {
        // cursor moves to next line and input is removed
        this.displayed.push(...this.text.clear());
        // letters already have the offset baked in
        var offset = TEXT_SIZE.height - TEXT_SIZE.y;
        this.text.yoffset = this.displayed[this.displayed.length - 1].y + offset;
        this.addPrompt();
        this.cursor.update(this.text.getEndPos());
    };

    addPrompt() {
        // add a prompt
        for(var c of this.prompt) {
            this.add(c, false, '#BBBBBB');
        }
    };

    cursorLeft() {
        // if there is text to the left
        console.log('Left');
    }

    cursorRight() {
        // if there is text to the right
        console.log('Right');
    }
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
            return this.text.delete();
        }

        if(event.keyCode === RETURN) {
            return this.text.newline();
        }

        if(event.keyCode == CURSOR_RIGHT) {
            return this.text.cursorRight();
        }
        if(event.keyCode == CURSOR_LEFT) {
            return this.text.cursorLeft();
        }

        // if we can't render, don't
        if(!can_render(event.key)) {
            return;
        }
        this.text.add(event.key);
    };
};
