extends Node2D

func _ready() -> void:
	
	# Prepare scale for growth
	scale.x = 0
	scale.y = 0
	
	# Set visibility order
	z_as_relative = false
	z_index = get_node("/root/main").layerPawnBehind

# Grow ring for effect
func _process(_delta: float) -> void:
	scale.x = 1 - $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()
	scale.y = 1 - $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()
	$ShipRingSprite.modulate.a = $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()

# Clean up
func _on_fizzle_timer_timeout() -> void:
	queue_free()
