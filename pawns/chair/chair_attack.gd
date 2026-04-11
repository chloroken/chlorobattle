extends "res://pawns/base/base_attack.gd"

var swingSpd = 15
var swingDirs = [-1, 1]
var swingDir = swingDirs.pick_random()

# Choose a direction to swing
func _ready() -> void:
	scale.x = 0.0
	scale.y = 0.0
	rotation = randf_range(0, TAU)

# Swing attack
func _physics_process(delta: float) -> void:
	scale.x = 2 - $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time() * 2
	scale.y = 2 - $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time() * 2 
	rotation += swingDir * swingSpd * delta

# Clean up
func _on_fizzle_timer_timeout() -> void:
	self.queue_free()
