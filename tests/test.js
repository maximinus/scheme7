var config = {
    type: Phaser.AUTO,
    width: 800,
    height: 600,
    backgroundColor: '#1b1464',
    parent: 'phaser-example',
    physics: {
        default: 'matter',
        matter: {
            debug: true
        }
    },
    scene: {
        preload: preload,
        create: create
    }
};

var game = new Phaser.Game(config);

function preload ()
{
    this.load.image('orange', 'orange.png');
}

function create ()
{
    // this.matter.world.setBounds().disableGravity();
    this.matter.world.disableGravity();

    var chevron = this.matter.world.fromPath('100 5 75 50 100 100 25 100 0 50 25 0');
    var ship = this.matter.world.fromPath('30 0 60 100 0 100');

    // var poly = this.matter.add.image(200, 150, 'orange');
    var poly = this.matter.add.image(200, 150, 'orange', null, { shape: { type: 'fromVerts', verts: ship }});
    poly.alpha = 0.5;

    //  Just make the body move around and bounce
    //poly.setVelocity(0.01, 0.03);
    //poly.setAngularVelocity(0.02);
    poly.setBounce(1);
    poly.setFriction(0, 0, 0);
};