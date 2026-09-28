extends "res://pawns/_base/items/_attack/item_attack.gd"

var basePawn

var orbitDirs = [-1, 1]
var orbitDir = orbitDirs.pick_random()
var orbitDistanceMin = 32
var orbitDistanceMax = 64
var orbitDistance
var orbitSpeed = 1
var orbitRotation = 0.0
var orbitPos = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()

var treatSpinSpeed = 1.0
var treatSpinDirs = [-1, 1]
var treatSpinDir = treatSpinDirs.pick_random()

var durMin = 30.0
var durMax = 40.0

func _ready() -> void:
	modulate.a = 0.5
	areaAttack = false
	basePawn = get_parent().get_parent()
	orbitDistance = randf_range(orbitDistanceMin, orbitDistanceMax)
	$FizzleTimer.start(randf_range(durMin, durMax))

func _physics_process(delta: float) -> void:
	rotation += treatSpinSpeed * treatSpinDir * delta
	
	orbitRotation += orbitSpeed * delta
	if orbitRotation > 360: orbitRotation = 0
	position = basePawn.position + (orbitPos * orbitDistance).rotated(orbitDir * orbitRotation)

func _on_fizzle_timer_timeout() -> void:
	queue_free()
