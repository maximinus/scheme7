extends Node

class_name ShieldOff

# shield off: the ship never takes any damage
func _init() -> void:
	pass

func update(player, collider) -> bool:
	# returns true if player is dead
	return false

func updateDamage(_damage_amount: float) -> void:
	pass

func getShield() -> float:
	return Shield.MAX_SHIELD
	
func getStruct() -> float:
	return Shield.MAX_STRUCT
	
func getInternals() -> float:
	return Shield.MAX_INTERNALS
	
func getDamageFrame() -> int:
	# return the frame used to draw the ship showing damage
	return 0

func reset() -> void:
	pass
