extends "res://pawns/base/base_attack.gd"

var destination
var speed = 250
var basePawn

func _ready() -> void:
	isEmberAttack = true
	basePawn = get_parent().get_parent()
	$FizzleTimer.start(randf_range(basePawn.nemberDurationMin, basePawn.nemberDurationMax))
	scale = Vector2.ONE * basePawn.nemberScale
	set_collision_layer_value(1, false)

func _process(delta: float) -> void:
	if position.distance_to(destination) > 10:
		position += position.direction_to(destination) * speed * delta
	else:
		set_collision_layer_value(1, true)
		scale = Vector2.ONE * basePawn.nemberScale * $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()

func _on_fizzle_timer_timeout() -> void:
	queue_free()
