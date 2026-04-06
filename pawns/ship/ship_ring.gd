extends Node2D

# Grow ring for effect
func _process(_delta: float) -> void:
	scale.x = 1 - $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()
	scale.y = 1 - $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()
	$ShipRingSprite.modulate.a = $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()

# Clean up
func _on_fizzle_timer_timeout() -> void:
	queue_free()
