extends StaticBody2D

var now = 0

func _ready():
	pass

func _on_Timer_timeout():
	if $Light2D.visible:
		$Light2D.hide()
	else:
		$Light2D.show()
