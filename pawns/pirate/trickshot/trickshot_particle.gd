extends Node2D

var direction
var speed = 50
var duration

func _ready() -> void:
	modulate.r = randf_range(0.0, 1.0)
	modulate.b = randf_range(0.0, 1.0)
	modulate.g = randf_range(0.0, 1.0)
	
	$FizzleTimer.one_shot = true
	$FizzleTimer.start(duration)

func _physics_process(_delta: float) -> void:
	modulate.a = $FizzleTimer.get_time_left() / duration

func _on_fizzle_timer_timeout() -> void:
	pass#queue_free()
