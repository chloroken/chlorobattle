extends "res://pawns/_base/base_attack.gd"

var duration
var baseSpeed
var direction
var speedDecay
var ringBounceModifier

func _ready() -> void:
	super()
	$FizzleTimer.start(duration)

func _physics_process(delta: float) -> void:
	var distToWall = basePawn.board.boardRadius - position.distance_to(basePawn.center)
	var speed = min(baseSpeed, max(baseSpeed/2, distToWall))
	position += direction * speed * delta
	baseSpeed *= speedDecay
	check_for_out_of_bounds()
	modulate.r = randf_range(0.5, 1.0)
	var alphaRatio = $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()
	if alphaRatio < 0.1:
		modulate.a = 10 * alphaRatio
func check_for_out_of_bounds() -> void:
	if position.distance_to(basePawn.center) > basePawn.board.boardRadius:
		direction = ring_bounce()
func _on_area_exited(area: Area2D) -> void:
	if area.get_collision_layer_value(6):
		direction = ring_bounce()
func ring_bounce() -> Vector2:
	return((position.direction_to(basePawn.center) + direction/2 + Vector2.ONE*basePawn.ringBounceModifier).normalized())
func _on_fizzle_timer_timeout() -> void:
	queue_free()
