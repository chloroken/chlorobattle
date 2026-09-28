extends Node2D

var dur = 1.0

func _ready() -> void:
	modulate.r = randf_range(0.5, 1.0)
	modulate.b = randf_range(0.5, 1.0)
	modulate.g = randf_range(0.5, 1.0)
	$FizzleTimer.start(dur)

func _on_fizzle_timer_timeout() -> void:
	queue_free()
