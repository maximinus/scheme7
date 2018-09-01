var config = {
    type: Phaser.AUTO,
    width: 800,
    height: 600,
    physics: {
        default: 'matter',
        matter: {
            enableSleeping: false,
            debug: true,
            gravity: {x: 0,
                      y: 0.3}
        }
    },
    scene: [IntroScene, MainScene]
};

var game = new Phaser.Game(config);
