extends Node2D

# Randomize bubble size
func _ready() -> void:
	$GrouperBubbleSprite.scale *= randf_range(1.0, 2.0)

# Clean up
func _on_fizzle_timer_timeout() -> void:
	queue_free()
