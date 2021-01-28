extends StaticBody2D

signal electric_contact_start
signal electric_contact_end

var on = true
# use this to save status of player when door is off
var player_inside = false

func _ready():
	pass

func _on_Area2D_body_entered(body):
	if on == false:
		if body.is_in_group('player'):
			player_inside = true
		return
	if body.is_in_group('breakable'):
		body.collide(Vector2(0, 0))
	if body.is_in_group('player'):
		emit_signal('electric_contact_start')
		player_inside = true

func _on_Area2D_body_exited(body):
	if body.is_in_group('player'):
		if on == false:
			player_inside = false
		else:
			emit_signal('electric_contact_end')
			player_inside = false

func doorHit():
	# if the button is hit when a player is inside, do nothing
	if player_inside == true:
		return
	# already off? do nothing
	if on == false:
		return
	on = false
	# turn off electric door and sound
	$Electric.hide()
	$ElectricHum.pitch_scale = 1.2
	$Timer.start()

func _on_Timer_timeout():
	$Electric.show()
	$ElectricHum.pitch_scale = 1.0
	on = true
	# is the player inside?
	if player_inside == true:
		emit_signal('electric_contact_start')
