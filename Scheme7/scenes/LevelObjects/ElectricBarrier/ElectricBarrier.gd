extends StaticBody2D

signal electric_contact_start
signal electric_contact_end

func _ready():
	pass

func _on_Area2D_area_entered(area):
	emit_signal('electric_contact')


func _on_Area2D_body_entered(body):
	if body.is_in_group('breakable'):
		body.collide(Vector2(0, 0))
	if body.is_in_group('player'):
		emit_signal('electric_contact_start')


func _on_Area2D_body_exited(body):
	if body.is_in_group('player'):
		emit_signal('electric_contact_end')
