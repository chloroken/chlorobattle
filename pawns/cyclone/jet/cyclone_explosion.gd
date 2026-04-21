extends "res://pawns/base/base_attack.gd"

func _ready() -> void:

	# Lock scale to grow from
	scale.x = 0.5
	scale.y = 0.5

	# Randomize explosion direction
	rotation = randf_range(0, TAU)

	# Set visibility order
	z_as_relative = false
	z_index = get_node("/root/main").layerPawnFront

# Grow explosion & fade alpha
func _process(_delta: float) -> void:
	$BaseSprite.modulate.a = $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()
	scale.x = 0.5 + (1 - $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time())
	scale.y = 0.5 + (1 - $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time())

# Clean up
func _on_fizzle_timer_timeout() -> void:
	self.queue_free()
