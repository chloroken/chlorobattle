extends "res://pawns/base/base_attack.gd"

#var growRate = 1.1

# Randomly rotate splash
func _ready() -> void:
	z_index = get_node("/root/main").layerGround
	rotation = randf_range(0, TAU)
	scale.x = 0
	scale.y = 0

# Grow splash rapidly
func _physics_process(_delta: float) -> void:
	scale.x = 1.5 - $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()
	scale.y = 1.5 - $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()

# Clean up
func _on_fizzle_timer_timeout() -> void:
	self.queue_free()
