/*
TODO: Scroll Terminal up
      Add print callback
      Allow cursor up and down
      Check other blocking keys
      Capture and uncapture input
      Handle differnt fonts
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
const PROMPT_COLOR = '#BBBBBB';
const TEXT_COLOR = '#C85746';
const FONT = {fontFamily: 'scheme7-terminal',
              fontSize: '32px',
              color: TEXT_COLOR};
const CURSOR_FONT = {fontFamily: 'scheme7-terminal',
                     fontSize: '32px',
                     color: '#000000',
                     backgroundColor: '#C85746'};

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
        this.cursor = this.scene.add.text(position.x, position.y, ' ', CURSOR_FONT);
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

    update(position, character) {
        this.updateImage(position, character);
        this.cursor.visible = true;
        this.startFlash();
    };

    updateImage(position, character) {
        this.stopFlash();
        this.cursor.destroy();
        this.cursor = this.scene.add.text(position.x, position.y, character, CURSOR_FONT);
    };

    destroy() {
        this.cursor.destroy()
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
        // the cursor is to the RIGHT of what we want to delete
        if(index == 0) {
            return false;
        }
        index -= 1;
        var size = this.text.length;
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
        // return true if something deleted
        return (size != this.text.length);
    };

    getPosition(index=-1) {
        if(index == -1) {
            index = this.text.length;
        }
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

    clear() {
        // return the current images and clear the current text
        var old_chars = this.text;
        this.text = [];
        return old_chars;
    };

    getChar(index) {
        // get character at index, or space if out of range
        if((index < 0) || (index >= this.text.length)) {
            return ' ';
        }
        return this.text[index].character;
    };

    size() {
        return this.text.length;
    }

    editable(index=-1) {
        if(this.text.length == 0) {
            return false;
        }
        if(index == -1) {
            index = this.text.length - 1;
        }
        return this.text[index].can_edit;
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
    constructor(scene, line_length, prompt) {
        this.text = new TextLine(line_length);
        this.line_length = line_length;
        this.display = [];
        this.prompt = prompt;
        this.scene = scene;
        this.rendered_lines = [];
        this.cursor = new Cursor(scene, this.text.getPosition());
        this.index = 0;
        this.addPrompt();
    };

    buildChar(new_char, pos, color=null) {
        // reset color?
        if(color != null) {
            var new_char = this.scene.add.text(pos.x, pos.y, new_char,
                                               Object.assign({}, FONT, {'color': color}));
        }
        else {
            var new_char = this.scene.add.text(pos.x, pos.y, new_char, FONT);
        }
        return new_char
    };

    add(new_char, can_edit=true, color=null) {
        var pos = this.text.getPosition();
        var new_text = this.buildChar(new_char, pos, color);
        this.text.add(new TerminalCharacter(new_char, new_text, can_edit), this.index);
        this.index += 1;
        this.updateCursor();
    };

    delete() {
        if(this.text.remove(this.index) == true) {
            this.index -= 1;
        }
        this.updateCursor();
    };

    newline() {
        // cursor moves to next line and input is removed
        //this.convertOld(this.text.clear());
        this.convertOld(this.text.clear());
        // TODO: push all lines up
        // letters already have the offset baked in
        var offset = TEXT_SIZE.height - TEXT_SIZE.y;
        this.text.yoffset = (this.display.length * TEXT_SIZE.height);
        this.addPrompt();
        this.updateCursor();
    };

    convertOld(old_chars) {
        // old_chars is a list of TerminalCharacters
        // we start by splitting up the lines
        while(old_chars.length) {
            this.display.push(this.renderLine(old_chars.splice(0, this.line_length)));
        }
        // delete all the old ones
        for(var i of old_chars) {
            i.delete();
        }
    };

    renderLine(line) {
        // render a line in the right location and return it
        // first we start with possible prompts
        var images = [];
        var prompt = [];
        var index = 0;
        while(line[index].can_edit == false) {
            prompt.push(line[index]);
            index += 1;
        }
        if(prompt.length > 0) {
            line.splice(0, prompt.length);
            // render the prompt
            images.push(this.scene.add.text(prompt[0].image.x,
                                            prompt[0].image.y,
                                            prompt.map(x => x.character).join(''),
                                            Object.assign({}, FONT, {color: PROMPT_COLOR})));
        }
        // render and add if needed
        if(index.lengh > 0) {
            images.push(this.scene.add.text(index[0].image.x,
                                            index[0],image.y,
                                            index.map(x => x.character).join(''),
                                            Object.assign({}, FONT, {color: PROMPT_COLOR})));
        }
        return images;
    };

    updateCursor() {
        // render the cursor properly
        var over_char = this.text.getChar(this.index);
        this.cursor.update(this.text.getPosition(this.index), over_char);
    }

    addPrompt() {
        // reset the cursor and add a prompt
        this.index = 0;
        for(var c of this.prompt) {
            this.add(c, false, PROMPT_COLOR);
        }
    };

    cursorLeft() {
        // can move left if index > 0 and index - 1 can be edited
        if((this.index > 0) && (this.text.editable(this.index - 1))) {
            this.index -= 1;
        }
        this.updateCursor();
    };

    cursorRight() {
        // can move right if less than text size
        if(this.index < this.text.size()) {
            this.index += 1;
        }
        this.updateCursor();
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
