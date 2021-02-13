extends StaticBody2D

func _ready() -> void:
	pass

func _on_Timer_timeout() -> void:
	if $Light2D.visible:
		$Light2D.hide()
	else:
		$Light2D.show()
