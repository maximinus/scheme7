class TerminalScene extends Phaser.Scene {
    constructor() {
        super({key: 'TerminalScene'});
        this.message = `This is a really long scrolly message. So long, I had to 
                        learn about multi-line strings in ES6. However, it is only 
                        long for demo purposes, and it likely boring to read.  `
        this.index = 0;
    };

    preload() {
        // and the font
        this.load.bitmapFont('terminal', 
                             'assets/fonts/terminal/font.png',
                             'assets/fonts/terminal/font.fnt');
    };

    create() {
        var text = this.add.bitmapText(200, 200, 'terminal', 'Hello, World!')
        var ttf = this.add.text(200, 400, 'Hello, TTF!', 
            {fontFamily: 'terminal',
             fontSize: '64px',
             color: '#cc8800'});
        this.buildStringSprite();
    };

    update() {
        // pass
    };

    buildStringSprite() {
        var text = this.getNextCharacter();
        var text_image = this.add.text(800, 50, 'Hello, TTF!',
            {fontFamily: 'terminal',
             fontSize: '64px',
             color: '#cc8800'});
        var width = text_image.width;
        // what is speed, pixel/s? 100p/s = 8000m/s
        // given X pixels, time = (X / 100 p/s) * 1000 m/s = X * 10
        this.tweens.add({
            targets: text_image,
            x: 300,
            duration: 200,
            onComplete: () => { 
                this.tweens.add({
                    targets: text_image,
                    x: 0,
                    duration: 8000 - (this.width * 10),
                    onComplete: () => {
                        text_image.destroy();
                        this.buildStringSprite;
                    }
                })
            }
        });
    };

    getNextCharacter() {
        if(this.index >= this.message.length) {
            this.index = 0;
        }
        this.index += 1;
        return this.message.substr(this.index - 1, this.index);
    };
};
