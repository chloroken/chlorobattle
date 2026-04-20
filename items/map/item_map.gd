extends Node2D

# X variables
var effectDuration
var sizeMin = 0.75
var sizeMax = 1.0

# Line variables
var mapLine
var mapLineWidth = 2
var mapLineAlpha = 0.5
var mapLineMinAlpha = 0.1

func _ready() -> void:
	
	# Randomize physics
	rotation = randf_range(0, TAU)
	var sizeRatio = randf_range(sizeMin, sizeMax)
	scale *= sizeRatio
	
	# Set visibility ordering
	z_as_relative = false
	z_index = get_node("/root/main").layerGround

# Fade out alpha over time
func _process(_delta: float) -> void:
	var fadeRatio = $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()
	$MapSprite.modulate.a = fadeRatio
	if mapLine != null:
		mapLine.default_color = Color(0, 0, 0, max(mapLineMinAlpha, mapLineAlpha * fadeRatio))

# Create a line to former location
func new_line(pos) -> void:
	mapLine = Line2D.new()
	mapLine.width = mapLineWidth
	mapLine.add_point(position)
	mapLine.add_point(pos)
	add_sibling(mapLine)

# Clean up
func _on_fizzle_timer_timeout() -> void:
	mapLine.queue_free()
	queue_free()
