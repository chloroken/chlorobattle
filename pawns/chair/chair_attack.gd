extends "res://pawns/base/base_attack.gd"

var swingDir
var swingSpd
var swingDur
var scaleMod

func _ready() -> void:
	
	# Start with no scale to avoid scale snapping
	scale = Vector2.ONE * 0.5

	# Set visibility layer
	z_as_relative = false
	z_index = get_node("/root/main").layerPawnFront

	# Set timers
	$FizzleTimer.start(swingDur)

func _physics_process(delta: float) -> void:
	
	# Attack swing
	rotation += swingDir * swingSpd * delta
	position = get_parent().get_parent().position
	
	# Scale growth
	var scaleAmt = $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()
	scale.x = 0.5 + 0.5 * (scaleMod - scaleAmt * scaleMod)
	scale.y = 0.5 + 0.5 * (scaleMod - scaleAmt * scaleMod)

# Clean up
func _on_fizzle_timer_timeout() -> void:
	queue_free()
