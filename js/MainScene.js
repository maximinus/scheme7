var SPRITES = {'rock': 'rock.png',
               'player': 'test.png',
               'background': 'background.png',
               'spark': 'spark.png',
               'blue': 'blue.png'};

class MainScene extends Phaser.Scene {
    constructor() {
        super({key: 'MainScene'});
    };

    preload() {
        // add our sprites
        for(var key in SPRITES) {
            if(SPRITES.hasOwnProperty(key)) {
                this.load.image(key, 'assets/sprites/' + SPRITES[key]);
            }
        }
    };

    create() {
        // setup world parameters
        // 32 - thickness of wall. Boolean walls - left, right, top, bottom
        this.matter.world.setBounds(0, 0, 800, 600, 32, false, false, false, false);

        // add the background
        this.background = this.add.tileSprite(-256, -256, 4096, 4096, 'background');

        // add the player
        this.player = this.addPlayer(game.config.width / 2.0);
        
        // and then the 5 walls
        var xpos = Math.round(game.config.width / 2.0) - (256);
        var ypos = game.config.height - 64;
        for(var i of Array(5)) {
            this.addWall(xpos, ypos);
            xpos += 128;
        }
        this.addWall(xpos - 640, ypos - 128);
        this.addWall(xpos - 128, ypos - 128);

        // add cursor reading
        this.cursors = this.input.keyboard.createCursorKeys();

        // make the camera follow the player
        this.cameras.main.startFollow(this.player, true, 1, 1, 0, 0);

        // TODO: Bug in 3.11 means you must NOT add the blend mode,
        // otherwise the emitter will not show up
        this.spark_emitter = this.add.particles('spark');

        // handle collisions
        this.matter.world.on("collisionstart", event => {
            // loop through all paired events
            event.pairs.forEach(pair => {
                this.checkCollision(pair);
            });
        });
    };

    update() {
        // check all input
        if(this.cursors.up.isDown) {
            // do the thrust based on the angle that we get
            var x = Math.sin(this.player.rotation) * 0.08;
            var y = Math.cos(this.player.rotation) * -0.08;
            this.player.applyForce(new Phaser.Math.Vector2(x, y));
        }

        if(this.cursors.left.isDown) {
            // turn left
            this.player.setRotation(this.player.rotation - (Math.PI / 72));
        }
        if(this.cursors.right.isDown) {
            // turn right
            this.player.setRotation(this.player.rotation + (Math.PI / 72));
        }
    };

    addPlayer(xpos) {
        // make the points first
        // string is [x y x y x y] etc
        var player_shape = this.matter.world.fromPath('2 0 4 4 2 3 0 4');
        var player = this.matter.add.image(xpos, 0, 'player', null, 
                                            {shape: {type: 'fromVerts', verts: player_shape}});
        player.setRectangle(32, 64, {});
        player.setFriction(0.005);
        player.setBounce(1.0);
        player.setFrictionAir(0.05);
        player.setMass(100);
        return(player);
    };

    addWall(xpos, ypos) {
        // add the wall
        var rock = this.matter.add.image(xpos, ypos, 'rock')
        rock.setRectangle(128, 128, {});
        rock.setStatic(true);
    };

    checkCollision(collide_data) {
        var a = collide_data.bodyA;
        var b = collide_data.bodyB;
        // did the player collide?
        if(a.gameObject === this.player) {
            return this.handlePlayerCollision(b, collide_data.collision);
        } 
        if(b.gameObject === this.player) {
            return this.handlePlayerCollision(a, collide_data.collision);
        }
        this.handlePlayerCollision(player, collide_data.collision);
    };

    handlePlayerCollision(collider, collision) {
        // collider - what we smashed into
        // collision - the data from the collision
        // we need 2 things: the force of the collision, and the location
        for(var i of collision.supports) {
            this.addCollisionSpark(i.x, i.y);
        }
    }

    addCollisionSpark(xpos, ypos) {
        var emitter = this.spark_emitter.createEmitter({
            x: xpos,
            y: ypos,
            speed: {min: 50, max: 100},
            gravityY: 200,
            lifespan: 1500
        });
        emitter.explode(30, xpos, ypos);
    };
};
