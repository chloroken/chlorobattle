extends Node2D

var mapScaleMod = 1.5

# Grow map sprite
func _process(_delta: float) -> void:
	var mapScale = mapScaleMod * (1 - $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time())
	$MapSprite.scale.x = mapScale
	$MapSprite.scale.y = mapScale

# Clean up
func _on_fizzle_timer_timeout() -> void:
	queue_free()
