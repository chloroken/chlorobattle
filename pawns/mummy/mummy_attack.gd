extends "res://pawns/base/base_attack.gd"

func _ready() -> void:
	$BaseSprite.rotation = randf_range(0, TAU)
	set_collision_layer_value(1, false)
	$BaseSprite.modulate.a = 0.0
	scale.x = 2.0
	scale.y = 2.0

func _process(_delta: float) -> void:
	var spriteAlpha = 1.0
	if $FizzleTimer.get_time_left() > 1:
		spriteAlpha = 0.2 * (1 - ($FizzleTimer.get_time_left()-1) / ($FizzleTimer.get_wait_time()-1))
	else:
		set_collision_layer_value(1, true)
		spriteAlpha = $FizzleTimer.get_time_left()
		
	$BaseSprite.modulate.a = spriteAlpha

func _on_fizzle_timer_timeout() -> void:
	queue_free()
