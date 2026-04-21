extends "res://pawns/base/base_attack.gd"

var scaleMod

func _ready() -> void:
	
	# Randomly rotate splash
	rotation = randf_range(0, TAU)
	
	# Lock scale base to grow from
	scale.x = scaleMod - 1
	scale.y = scaleMod - 1

	# Set visibility order
	z_as_relative = false
	z_index = get_node("/root/main").layerArena

# Grow splash
func _physics_process(_delta: float) -> void:
	scale.x = scaleMod - $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()
	scale.y = scaleMod - $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()

# Clean up
func _on_fizzle_timer_timeout() -> void:
	self.queue_free()
