class TerminalScene extends Phaser.Scene {
    constructor() {
        super({key: 'TerminalScene'});
    };

    preload() {
        // pass
    };

    create() {
        var ttf = this.add.text(100, 100, '(format "Hello, World!")', 
            {fontFamily: 'scheme7-terminal',
             fontSize: '32px',
             color: '#C85746'});
    };

    update() {
        // pass
    };
};
