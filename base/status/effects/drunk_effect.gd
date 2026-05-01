extends Node2D

var fizzleDelay = 5.0

func _ready() -> void:
	$FizzleTimer.start(fizzleDelay)

func _process(_delta: float) -> void:
	$DrunkSprite.modulate.a = $FizzleTimer.get_time_left() / fizzleDelay

func _physics_process(_delta: float) -> void:
	global_position = get_parent().global_position + Vector2.UP * 55

func _on_fizzle_timer_timeout() -> void:
	queue_free()
