extends "res://pawns/_base/items/_attack/item_attack.gd"

var orbitDirs = [-1, 1]
var orbitDir = orbitDirs.pick_random()
var orbitDistance = 32
var orbitSpeed = 5
var orbitRotation = 0.0
var spinSpeed = 5
var parentPawn
var duration

func _ready() -> void:

	attackName = "Skates"
	$FizzleTimer.start(duration)
	isSkateAttack = true
	areaAttack = false
	z_as_relative = false
	z_index = get_node("/root/main").layerAir

	parentPawn = get_parent().get_parent()
	orbitSpeed *= randf_range(1.0, 1.5)
	orbitDistance *= randf_range(0.75, 1.0)
	scale *= randf_range(1, 1.5)

func _physics_process(delta: float) -> void:

	orbitRotation += orbitSpeed * delta
	if orbitRotation > 360: orbitRotation = 0
	position = parentPawn.position + (Vector2.ONE * orbitDistance).rotated(orbitDir * orbitRotation)
	rotation += spinSpeed * delta

func _on_fizzle_timer_timeout() -> void:
	queue_free()
