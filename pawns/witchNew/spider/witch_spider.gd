extends "res://pawns/_base/attacks/base_attack.gd"

var duration
var wanderCooldownMin
var wanderCooldownMax 
var jumpDuration = 0.1
var direction
var speed

var decayStart = 0.25
var decayRate = 10.0

var isTethered = false

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
		direction = position.direction_to(basePawn.center)
	check_for_tether_range()
	check_for_untether_range()

func check_for_tether_range() -> void:
	if position.distance_to(basePawn.position) > basePawn.familiarTetherDistance:
		isTethered = true
func check_for_untether_range() -> void:
	if position.distance_to(basePawn.position) < basePawn.familiarUntetherDistance:
		isTethered = false

func _on_fizzle_timer_timeout() -> void:
	queue_free()

func _on_direction_change_timeout() -> void:
	if isTethered:
		direction = position.direction_to(basePawn.position)
	else:
		direction = (basePawn.direction + Vector2.RIGHT.rotated(randf_range(0, TAU))).normalized()

	$DirectionChange.start(randf_range(wanderCooldownMin, wanderCooldownMax))
	$JumpDuration.start(jumpDuration)
