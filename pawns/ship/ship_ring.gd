extends Node2D

# Grow ring for effect
func _process(_delta: float) -> void:
	$ShipRingSprite.scale *= 1.01
	$ShipRingSprite.modulate.a *= 0.99

# Clean up
func _on_fizzle_timer_timeout() -> void:
	queue_free()
