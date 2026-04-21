extends "res://pawns/base/base_attack.gd"

var swingDirs = [-1, 1]
var swingDir = swingDirs.pick_random()
var swingSpd
var swingDur
var scaleMod

func _ready() -> void:
	
	# Randomize swing
	rotation = randf_range(0, TAU)

	# Start with no scale to avoid scale snapping
	scale = Vector2.ZERO

	# Set visibility layer
	z_as_relative = false
	z_index = get_node("/root/main").layerPawnFront

	# Set timers
	$FizzleTimer.start(swingDur)

func _physics_process(delta: float) -> void:
	
	# Attack swing
	rotation += swingDir * swingSpd * delta
	
	# Scale growth
	var scaleAmt = $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()
	scale.x = scaleMod - scaleAmt * scaleMod
	scale.y = scaleMod - scaleAmt * scaleMod

# Clean up
func _on_fizzle_timer_timeout() -> void:
	queue_free()
