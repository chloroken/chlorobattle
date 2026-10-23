extends "res://pawns/_base/base_item_attack.gd"

var basePawn

var orbitDirs = [-1, 1]
var orbitDir = orbitDirs.pick_random()
var orbitDistanceMin = 24
var orbitDistanceMax = 48
var orbitDistance
var orbitSpeed = 1
var orbitRotation = 0.0
var orbitPos = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()

var treatSpinSpeed = 5.0
var treatSpinDirs = [-1, 1]
var treatSpinDir = treatSpinDirs.pick_random()

func _ready() -> void:
	areaAttack = false
	basePawn = get_parent().get_parent()
	orbitDistance = randf_range(orbitDistanceMin, orbitDistanceMax)

func _physics_process(delta: float) -> void:
	rotation += treatSpinSpeed * treatSpinDir * delta
	
	orbitRotation += orbitSpeed * delta
	if orbitRotation > 360: orbitRotation = 0
	position = basePawn.position + (orbitPos * orbitDistance).rotated(orbitDir * orbitRotation)

func _on_fizzle_timer_timeout() -> void:
	queue_free()
