var ISPRITES = {'ball1': 'intro_up.png',
                'ball2': 'intro_down.png',
                'logo': 'logo.png'};

class IntroScene extends Phaser.Scene {
    constructor() {
        super({key: 'IntroScene'});
        this.balls = new Array();
    };

    preload() {
        // add our sprites
        for(var key in ISPRITES) {
            if(ISPRITES.hasOwnProperty(key)) {
                this.load.image(key, 'assets/sprites/' + ISPRITES[key]);
            }
        }
    };

    create() {
        // add lots of balls
        for(var i = 0; i < 150; i++) {
            this.addBall(true);
        }
        // and then the logo
        this.logo = this.add.sprite(400, 240, 'logo');
        this.logo.setDepth(1);

        // and some info text
        var ttf = this.add.text(400, 330, 'Press Any Key',
            {fontFamily: 'terminal',
             fontSize: '40px',
             color: '#cc8800'});
        
        var xpos = Math.trunc((game.config.width - ttf.width) / 2);
        ttf.x = xpos;
        ttf.setDepth(1);
        // flash the text
        this.add.tween({
            targets: ttf,
            duration: 1000,
            alpha: {
                getStart: () => 0,
                getEnd: () => 1
            },
            yoyo: true,
            repeat: -1
        });

        // change the scene when a key is pressed
        this.input.keyboard.on('keydown', () => this.scene.start('MainScene'));
    };

    update() {
        // pass
    };

    addBall(start=false) {
        var ypos = Phaser.Math.Between(350, 600);
        var delta = ypos - 300;
        var ball = this.add.sprite(-32, ypos, 'ball1');
        ball.setAlpha(0.5 - (delta / 500));
        ball.setScale((delta / 400) + 0.5);

        // if top, switch ypos and change sprite
        if(Math.random() < 0.5) {
            ball.y = 600 - ypos;
            ball.setTexture('ball2');
        }

        if(start == true) {
            // need to change 2 things: the start xpos, and the time taken
            // reduce the range to reduce possible bugs
            ball.x = Phaser.Math.Between(10, 822);
            var time = ((11000 - (delta * 30)) / 832) * (832 - ball.x);
        }
        else {
            var time = 11000 - (delta * 30);
        }

        this.tweens.add({
            targets: ball,
            x: 832,
            duration: time,
            onComplete: () => { ball.destroy(); this.addBall(); }
        });
        return(ball);
    };
};
