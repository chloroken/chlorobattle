extends "res://pawns/_base/attack/base_attack.gd"

var dur
var basePawn
var orbitDirs = [-1, 1]
var orbitDir = orbitDirs.pick_random()
var orbitDistance = 15
var orbitDriftSpeed
var orbitSpeed = 2
var orbitRotation = 0.0

func _ready() -> void:
	areaAttack = false
	basePawn = get_parent().get_parent()
	$FizzleTimer.start(dur)
	rotation = randf_range(0, TAU)

func _physics_process(delta: float) -> void:
	orbitRotation += orbitSpeed * delta
	if orbitRotation > 360: orbitRotation = 0
	position = basePawn.position + (Vector2.ONE * orbitDistance).rotated(orbitDir * orbitRotation)
	orbitDistance += orbitDriftSpeed * delta

func _on_fizzle_timer_timeout() -> void:
	queue_free()
