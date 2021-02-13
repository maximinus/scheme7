extends Node

class_name Shield

# shield - an electrical shield to protect
# struct - structure of external frame
# internal - the rest
# ship is dead when internal is all gone
	
# Damage as follows:
# all damage goes to struct up to 50%
# from 50% lower on struct, internals takes 30%
# When struct is zero, internals takes over
	
const MAX_SHIELD: float = 1000.0
const MAX_STRUCT: float = 700.0
const HALF_STRUCT: float = MAX_STRUCT / 2.0
const MAX_INTERNALS: float = 1000.0
const HALF_INTERNALS: float = MAX_INTERNALS / 2.0
const SPEED_CUTOFF: float = 30.0
const SPEED_DAMAGE_RATIO: float = 1.0
	
var shield: float = 0.0
var struct: float = MAX_STRUCT
var internals: float = MAX_INTERNALS
var last_speed: float = 0.0

func _init() -> void:
	pass

func update(player, collider) -> bool:
	# called when a collision happens
	# we need the speed of the object and the player
	player -= collider
	var speed: float = abs(player.x) + abs(player.y)
	if speed == last_speed:
		# ignore this extra collision
		return internals <= 0
	if speed <= SPEED_CUTOFF:
		# not fast enough to cause damage
		return internals <= 0
	# damage is half the speed
	updateDamage(speed * SPEED_DAMAGE_RATIO)
	last_speed = speed
	return internals <= 0.0

func updateDamage(damage_amount: float) -> void:
	if struct <= 0:
		internals = max(0.0, internals - damage_amount)
		return
	elif struct > (HALF_STRUCT + damage_amount):
		struct -= damage_amount
		return
	elif struct > HALF_STRUCT:
		# some of the damage will go to the internals
		var delta: float = struct - HALF_STRUCT
		damage_amount -= delta
		struct = HALF_STRUCT
	# share between struct and internals
	var sdamage: float = 0.7 * damage_amount
	var idamage: float = 0.3 * damage_amount
	if sdamage > struct:
		idamage += sdamage - struct
		struct = 0.0
	else:
		struct -= sdamage
	internals = max(0.0, internals - idamage)

func getShield() -> float:
	return shield / MAX_SHIELD
	
func getStruct() -> float:
	return struct / MAX_STRUCT
	
func getInternals() -> float:
	return internals / MAX_INTERNALS
	
func getDamageFrame() -> int:
	# return the frame used to draw the ship showing damage
	if struct > 0:
		var frame: int = ceil((struct / MAX_STRUCT) * 5.0)
		# gives 1 to 5, with 5 being best
		return 5 - frame
	# no struct
	if internals > HALF_INTERNALS:
		return 5
	# worst damage
	return 6

func reset() -> void:
	shield = 0
	struct = MAX_STRUCT
	internals = MAX_INTERNALS
	last_speed = 0
