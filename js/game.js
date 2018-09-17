var config = {
    type: Phaser.AUTO,
    width: 800,
    height: 616,
    physics: {
        default: 'matter',
        matter: {
            enableSleeping: false,
            debug: true,
            gravity: {x: 0,
                      y: 0.4}
        }
    },
    scene: [TerminalScene, MainScene, IntroScene]
};

var game = new Phaser.Game(config);
