extends Node2D

var direction
var speed = 25

func _ready() -> void:
	direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	speed *= randf_range(0.5, 2.0)
	$FizzleTimer.start(0.25)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_fizzle_timer_timeout() -> void:
	queue_free()
