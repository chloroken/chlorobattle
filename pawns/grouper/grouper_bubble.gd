extends "res://pawns/base/base_attack.gd"

# Randomize bubble size
func _ready() -> void:
	z_as_relative = false
	z_index = get_node("/root/main").layerArena
	areaAttack = false
	rotation = randf_range(0, TAU)
	scale *= randf_range(0.25, 1.0)

# Clean up
func _on_fizzle_timer_timeout() -> void:
	queue_free()
