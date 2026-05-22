extends "res://pawns/_base/items/_attack/item_attack.gd"

var duration

func _ready() -> void:
	attackName = "Map"
	$FizzleTimer.start(duration)
	scale = Vector2.ZERO

func _process(_delta: float) -> void:
	scale = Vector2.ONE * (1.5 - $FizzleTimer.get_time_left() / duration)
	modulate.a = max(0.5, $FizzleTimer.get_time_left() / duration)

func _on_fizzle_timer_timeout() -> void:
	queue_free()
