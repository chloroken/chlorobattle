extends "res://pawns/_base/base_attack.gd"

var dur
var orbitDirs = [-1, 1]
var orbitDir = orbitDirs.pick_random()
var orbitDistance = 15
var orbitDriftSpeed
var orbitSpeed = 2
var orbitRotation = 0.0

var isChasingTree = false
var chaseTimer = 8.0

func _ready() -> void:
	super()
	areaAttack = false
	$FizzleTimer.start(dur)
	rotation = randf_range(0, TAU)
	$LeafChaseTimer.one_shot = true

func _physics_process(delta: float) -> void:
	orbitRotation += orbitSpeed * delta
	if orbitRotation > 360: orbitRotation = 0
	if $LeafChaseTimer.is_stopped():
		position = basePawn.position + (Vector2.ONE * orbitDistance).rotated(orbitDir * orbitRotation)
	else:
		var timeRem = $LeafChaseTimer.get_time_left() / $LeafChaseTimer.get_wait_time()
		position = lerp(position, basePawn.position + (Vector2.ONE * orbitDistance).rotated(orbitDir * orbitRotation), 1 - timeRem)
	orbitDistance += orbitDriftSpeed * delta

func _on_fizzle_timer_timeout() -> void:
	queue_free()
