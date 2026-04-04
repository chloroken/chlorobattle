extends "res://pawns/base/base_attack.gd"

var swingSpd = 15
var swingDirs = [-1, 1]
var swingDir = swingDirs.pick_random()

# Choose a direction to swing
func _ready() -> void:
	rotation = randf_range(0, TAU)

# Swing attack
func _process(delta: float) -> void:
	rotation += swingDir * swingSpd * delta

# Clean up
func _on_fizzle_timer_timeout() -> void:
	self.queue_free()
