extends StaticBody2D

const LANDER_WIDTH: int = 78
const LANDER_OFFSET: int = 3

func _ready() -> void:
	pass

func _on_Timer_timeout() -> void:
	if $PointLight2D.visible:
		$PointLight2D.hide()
	else:
		$PointLight2D.show()

func shipOnLander(ship_position) -> bool:
	var feet_position = ship_position.y + Globals.SHIP_SIZE.y
	var feet_offset = global_position.y - feet_position
	if feet_offset > 2.0:
		return false
	# double check the x positions
	var left_offset = global_position.x - (ship_position.x - Globals.SHIP_SIZE.x)
	var right_offset = global_position.x - (ship_position.x + Globals.SHIP_SIZE.x)
	if left_offset >= LANDER_OFFSET and right_offset <= LANDER_OFFSET + LANDER_WIDTH:
		return true
	return false
