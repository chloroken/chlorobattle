extends "res://pawns/base/base_attack.gd"

var swingDirs = [-1, 1]
var swingDir = swingDirs.pick_random()
var swingDuration
var swingSpd
var scaleMultiplier

# Choose a direction to swing
func _ready() -> void:
	swingDuration = randf_range(0.5, 1.0)
	swingSpd = randf_range(5.0, 15.0)
	scaleMultiplier = randf_range(1.0, 2.0)
	
	$FizzleTimer.start(swingDuration)
	get_parent().get_parent().get_node("AttackStutterTimer").start(swingDuration)
	
	
	scale.x = 0.0
	scale.y = 0.0
	rotation = randf_range(0, TAU)

# Swing attack
func _physics_process(delta: float) -> void:
	rotation += swingDir * swingSpd * delta
	var scaleAmt = $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()
	scale.x = scaleMultiplier - scaleAmt * scaleMultiplier
	scale.y = scaleMultiplier - scaleAmt * scaleMultiplier

# Clean up
func _on_fizzle_timer_timeout() -> void:
	self.queue_free()
