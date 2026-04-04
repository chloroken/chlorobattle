extends "res://pawns/base/base_attack.gd"

var growRate = 1.0125

# Randomly rotate splash
func _ready() -> void:
	rotation = randf_range(0, TAU)

# Grow splash rapidly
func _physics_process(_delta: float) -> void:
	self.scale *= growRate

# Clean up
func _on_fizzle_timer_timeout() -> void:
	self.queue_free()
