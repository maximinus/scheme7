extends StaticBody2D

func _ready() -> void:
	pass

func _on_Timer_timeout() -> void:
	if $PointLight2D.visible:
		$PointLight2D.hide()
	else:
		$PointLight2D.show()
