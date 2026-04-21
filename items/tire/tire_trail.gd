extends Node2D

var trailDuration = 5

func _ready() -> void:
	
	# Randomize rotation
	rotation = randf_range(0, TAU)
	
	# Set visibility order
	z_as_relative = false
	z_index = get_node("/root/main").layerArena
	
	# Set timers
	$FizzleTimer.start(trailDuration)

# Adjust alpha
func _process(_delta: float) -> void:
	$TireTrailSprite.modulate.a = $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()

func _on_fizzle_timer_timeout() -> void:
	queue_free()
