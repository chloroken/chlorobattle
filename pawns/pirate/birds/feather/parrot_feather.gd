extends Node2D

var direction
var speed
var color

func _ready() -> void:
	direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	rotation = randf_range(0, TAU)
	speed = randf_range(10, 50)
	scale *= randf_range(0.5, 1.0)
	$Sprite.modulate = color
	$FizzleTimer.start(randf_range(1.0, 0.5))

func _process(delta: float) -> void:
	position += direction * speed * delta
	$Sprite.modulate.a = $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()

func _on_fizzle_timer_timeout() -> void:
	queue_free()
