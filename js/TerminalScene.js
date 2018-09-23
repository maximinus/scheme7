/*
TODO: Scroll terminal on long input
*/

// keycodes we wish to render
var CHARS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890!@#$%^&*()_+-=<>?,./:";\'{}[] '

// keycodes that have special meanings
const KEYS = {
    BACKSPACE: 8,
    RETURN: 13,
    CURSOR_RIGHT: 39,
    CURSOR_LEFT: 37,
    END: 35,
    HOME: 36
};

// keycodes we prevent from passing up the event tree
const STOP_BUBBLING = [KEYS.BACKSPACE, KEYS.RETURN];

// params we want:

DATA_SENT = {PROMPT_COLOR: '#BBBBBB',
             TEXT_COLOR: '#C85746',
             FONT: {fontFamily: 'scheme7-terminal',
                       fontSize: '16px',
                       color: '#000000'},
             BACKGROUND_COLOR: '#000000',
             PROMPT_TEXT: 'Hello >',
             TERMINAL: new Phaser.Geom.Rectangle(0, 0, 500, 400)};

// the params that are passed or calculated
const PARAMS = {PROMPT_COLOR: '#BBBBBB',
                TEXT_COLOR: '#C85746',
                TEXT_SIZE: null,
                CHARS_PER_LINE: 0,
                MAX_LINES: 0,
                FONT: {fontFamily: 'scheme7-terminal',
                       fontSize: '20px',
                       color: '#000000'},
                CURSOR_FONT: {fontFamily: 'scheme7-terminal',
                              color: '#000000',
                              backgroundColor: '#000000'},
                MARGIN: 10,
                TERMINAL_BACKGROUND: '#202060AA',
                TERMINAL_SIZE: new Phaser.Geom.Rectangle(30, 30, 668, 480)};

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
        this.cursor = this.scene.add.text(position.x, position.y, ' ', PARAMS.CURSOR_FONT);
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
        this.cursor.visible = true;
    };

    hide() {
        this.cursor.visible = false;
    };

    update(position, character) {
        this.updateImage(position, character);
        this.cursor.visible = true;
        this.startFlash();
    };

    updateImage(position, character) {
        this.stopFlash();
        this.cursor.destroy();
        this.cursor = this.scene.add.text(position.x, position.y, character, PARAMS.CURSOR_FONT);
    };

    destroy() {
        this.cursor.destroy()
    };
};


class TextLine {
    // a line of text, or one command, currently in the terminal
    constructor(yoffset=0) {
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
        var xpos = index % PARAMS.CHARS_PER_LINE;
        var ypos = Math.trunc(index / PARAMS.CHARS_PER_LINE);
        xpos = (xpos * PARAMS.TEXT_SIZE.width) + PARAMS.TEXT_SIZE.x;
        ypos = (ypos * PARAMS.TEXT_SIZE.height) + PARAMS.TEXT_SIZE.y + this.yoffset;
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
    constructor(scene, prompt) {
        this.scene = scene;
        this.text = new TextLine();
        this.display = [];
        this.prompt = prompt;
        this.cursor = new Cursor(scene, this.text.getPosition());
        this.index = 0;
        this.addPrompt();
        this.interpreter = new MalLanguage(this.printLine.bind(this));
    };

    buildChar(new_char, pos, color=null) {
        // reset color?
        if(color != null) {
            var new_char = this.scene.add.text(pos.x, pos.y, new_char,
                                               Object.assign({}, PARAMS.FONT, {'color': color}));
        }
        else {
            var new_char = this.scene.add.text(pos.x, pos.y, new_char, PARAMS.FONT);
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
        // get the current text
        var command = this.text.toString();
        // pause the cursor and hide
        this.cursor.stopFlash();
        this.cursor.hide();
        // cursor moves to next line and input is removed
        this.convertOld(this.text.clear());
        this.updateCursorYpos();
        // run the command, which may print a line
        this.interpreter.runCommand(command);
        this.addPrompt();
        this.updateCursor();
    };

    updateCursorYpos() {
        while(this.display.length >= PARAMS.MAX_LINES) {
            this.moveLinesUp();
        }
        // letters already have the offset baked in
        this.text.yoffset = (this.display.length * PARAMS.TEXT_SIZE.height);
    };

    printLine(string) {
        var index = 0;
        // split line up if it goes over the bounds
        while(index < string.length) {
            var line_string = string.slice(index, index + PARAMS.CHARS_PER_LINE);
            // build the string and push to the display
            var pos = this.text.getPosition(0);
            var text = this.scene.add.text(pos.x, pos.y, line_string, PARAMS.FONT);
            this.display.push([text]);
            this.updateCursorYpos();
            index += PARAMS.CHARS_PER_LINE;
        }
    };

    moveLinesUp() {
        // remove the first line
        var old_images = this.display.splice(0, 1)[0];
        for(var i of old_images) {
            i.destroy();
        }
        // move all others up by 1 line
        for(var line of this.display) {
            for(var image of line) {
                image.y -= PARAMS.TEXT_SIZE.height;
            }
        }
    };

    convertOld(old_chars) {
        if(old_chars.length == 0) {
            // no chars, do nothing (although we still add a line)
            this.display.push([]);
            return;
        }
        // old_chars is a list of TerminalCharacters
        // delete all the images
        for(var i of old_chars) {
            i.destroy();
        }
        // we start by splitting up the lines
        while(old_chars.length) {
            this.display.push(this.renderLine(old_chars.splice(0, PARAMS.CHARS_PER_LINE)));
        }
    };

    renderLine(line) {
        // render a line in the right location and return it
        // first we start with possible prompts
        var images = [];
        var prompt = [];
        var index = 0;
        while(index < line.length) {
            if(line[index].can_edit == true) {
                break;
            }
            prompt.push(line[index]);
            index += 1;
        }

        if(prompt.length > 0) {
            line.splice(0, prompt.length);
            // render the prompt
            images.push(this.scene.add.text(prompt[0].image.x,
                                            prompt[0].image.y,
                                            prompt.map(x => x.character).join(''),
                                            Object.assign({}, PARAMS.FONT, {color: PARAMS.PROMPT_COLOR})));
        }
        // render and add if needed
        if(line.length > 0) {
            images.push(this.scene.add.text(line[0].image.x,
                                            line[0].image.y,
                                            line.map(x => x.character).join(''),
                                            Object.assign({}, PARAMS.FONT, {color: PARAMS.TEXT_COLOR})));
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
            this.add(c, false, PARAMS.PROMPT_COLOR);
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

    cursorToStart() {
        while((this.index > 0) && (this.text.editable(this.index - 1))) {
            this.index -= 1;
        }
        this.updateCursor();
    };

    cursorToEnd() {
        this.index = this.text.size()
        this.updateCursor();
    };
};

class TerminalScene extends Phaser.Scene {
    constructor() {
        super({key: 'TerminalScene'});
        // this.calculateData();
        
    };

    preload() {
        // pass
    };

    create() {
        this.setParams(this.getFontSize());
        this.drawBackground();
        this.text = new TextHolder(this, 'S7> ');
        // we need to tell Phaser what keys to not bubble
        for(var keycode of STOP_BUBBLING) {
            this.input.keyboard.addKey(keycode);
        }
        this.input.keyboard.on('keydown', this.keydown, this);
    };

    getFontSize() {
        var text = this.add.text(0, 0, 'X', PARAMS.FONT);
        // this is a rectangle
        var size = text.getBounds();
        text.destroy();
        return size;
    };

    setParams(text_size) {
        PARAMS.FONT.color = PARAMS.TEXT_COLOR;
        PARAMS.CURSOR_FONT.backgroundColor = PARAMS.TEXT_COLOR;
        text_size.x = PARAMS.MARGIN + PARAMS.TERMINAL_SIZE.x;
        text_size.y = PARAMS.MARGIN + PARAMS.TERMINAL_SIZE.y;
        PARAMS.TEXT_SIZE = text_size;
        var draw_width = PARAMS.TERMINAL_SIZE.width - (PARAMS.MARGIN * 2);
        var draw_height = PARAMS.TERMINAL_SIZE.height - (PARAMS.MARGIN * 2);
        PARAMS.CHARS_PER_LINE = Math.trunc(draw_width / PARAMS.TEXT_SIZE.width);
        PARAMS.MAX_LINES = Math.trunc(draw_height / PARAMS.TEXT_SIZE.height);
        PARAMS.CURSOR_FONT.fontSize = PARAMS.FONT.fontSize;
    };

    drawBackground() {
        // white outline around the outside
        // blue backdrop
        var gfx = this.add.graphics();
        gfx.fillStyle(0x202040, 0.5);
        gfx.fillRect(0, 0, PARAMS.TERMINAL_SIZE.width, PARAMS.TERMINAL_SIZE.height);
        gfx.lineStyle(1, PARAMS.TERMINAL_SIZE.width, PARAMS.TERMINAL_SIZE.height);
        var render = gfx.strokeRect(0, 0, PARAMS.TERMINAL_SIZE.width, PARAMS.TERMINAL_SIZE.height);
        render.generateTexture('gen_terminal', PARAMS.TERMINAL_SIZE.width, PARAMS.TERMINAL_SIZE.height);
        render.destroy()
        this.backdrop = this.add.image(PARAMS.TERMINAL_SIZE.x,
                                       PARAMS.TERMINAL_SIZE.y, 'gen_terminal');
        this.backdrop.setOrigin(0, 0);
    };

    keydown(event) {
        // we start by looking for special keys
        if(event.keyCode === KEYS.BACKSPACE) {
            return this.text.delete();
        }
        if(event.keyCode === KEYS.RETURN) {
            return this.text.newline();
        }
        if(event.keyCode === KEYS.CURSOR_RIGHT) {
            return this.text.cursorRight();
        }
        if(event.keyCode === KEYS.CURSOR_LEFT) {
            return this.text.cursorLeft();
        }
        if(event.keyCode === KEYS.END) {
            return this.text.cursorToEnd();
        }
        if(event.keyCode === KEYS.HOME) {
            return this.text.cursorToStart();
        }
        // if we can't render, don't
        if(!can_render(event.key)) {
            return;
        }
        // just some normal text, so render it
        this.text.add(event.key);
    };
};
