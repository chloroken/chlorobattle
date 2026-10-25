extends "res://pawns/_base/attacks/base_attack.gd"

var orbitDirs = [-1, 1]
var orbitDir = orbitDirs.pick_random()
var orbitRotation = 0.0
var orbitDistance
var orbitSpeed
var orbitVariation

func _ready() -> void:
	super()
	orbitDistance *= 1.0 + randf_range(-orbitVariation, orbitVariation)
	orbitSpeed *= 1.0 + randf_range(-orbitVariation, orbitVariation)
	z_index = get_node("/root/main").layerAir

func _physics_process(delta: float) -> void:
	enable_boo_sprite()
	advance_boo_orbit(delta)
	var booBasePosition = (Vector2.ONE * orbitDistance)
	var booRotationAmount = orbitDir * advance_boo_orbit(delta)
	var booRotatedPosition = booBasePosition.rotated(booRotationAmount)
	position = basePawn.position + booRotatedPosition
func enable_boo_sprite() -> void:
	if modulate.a != 1.0:
		modulate.a = 1.0
func advance_boo_orbit(delta) -> float:
	orbitRotation += orbitSpeed * delta
	if orbitRotation > 360:
		orbitRotation = 0
	return(orbitRotation)
func _on_fizzle_timer_timeout() -> void:
	queue_free()
func _on_tree_exiting() -> void:
	basePawn.booCurrentCount -= 1
