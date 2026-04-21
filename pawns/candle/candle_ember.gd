extends Node2D

var isPersistentSummon = true

func _ready() -> void:

	# Start at 0 scale to grow
	scale.x = 0.0
	scale.y = 0.0

	# Set visibility layer
	z_as_relative = false
	z_index = get_node("/root/main").layerPawnBehind

func _process(_delta: float) -> void:

	# Grow Ember size
	var timerRatio = $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()
	scale.x = 1 - timerRatio
	scale.y = 1 - timerRatio

	# Destroy any Embers outside of the board area
	var center = get_viewport_rect().size / 2.0
	var radius = get_parent().get_parent().get_parent().boardRadius
	if global_position.distance_to(center) > radius * 1:
		queue_free()

func _on_fizzle_timer_timeout() -> void:
	queue_free()
