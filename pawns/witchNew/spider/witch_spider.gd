extends "res://pawns/_base/base_attack.gd"

var duration
var wanderCooldownMin = 1.0
var wanderCooldownMax = 2.0
var jumpDuration = 0.1
var direction
var speed = 200

var decayStart = 0.25
var decayRate = 10.0

func _ready() -> void:
	super()
	$JumpDuration.one_shot = true
	$DirectionChange.one_shot = true
	$DirectionChange.start(randf_range(wanderCooldownMin, wanderCooldownMax))
	$FizzleTimer.start(duration)

func _process(delta: float) -> void:
	if $FizzleTimer.get_time_left() < $FizzleTimer.get_wait_time() * decayStart:
		modulate.a -= delta * decayRate
	

func _physics_process(delta: float) -> void:
	if !$JumpDuration.is_stopped():	position += direction * speed * delta
	if position.distance_to(basePawn.center) > basePawn.get_parent().boardRadius:
		queue_free()

func _on_fizzle_timer_timeout() -> void:
	queue_free()

func _on_direction_change_timeout() -> void:
	if position.distance_to(basePawn.position) > basePawn.familiarTetherDistance:
		direction = position.direction_to(basePawn.position)
	else:
		direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	$DirectionChange.start(randf_range(wanderCooldownMin, wanderCooldownMax))
	$JumpDuration.start(jumpDuration)
