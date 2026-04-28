extends "res://pawns/base/base_attack.gd"

func _ready() -> void:
	
	# Set random rotation and scale
	rotation = randf_range(0, TAU)

	# Set visibility order
	z_as_relative = false
	z_index = get_node("/root/main").layerArena

# Clean up
func _on_fizzle_timer_timeout() -> void:
	queue_free()
