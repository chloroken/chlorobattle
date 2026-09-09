extends Node2D

var duration = 5.0

func _ready() -> void:
	$FizzleTimer.start(duration)

func _process(_delta: float) -> void:
	modulate.a = $FizzleTimer.get_time_left() / duration

func _on_fizzle_timer_timeout() -> void:
	queue_free()
