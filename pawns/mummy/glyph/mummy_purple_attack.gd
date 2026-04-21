extends "res://pawns/base/base_attack.gd"

func _ready() -> void:
	
	# Prepare for visual effect
	mummyCenter = true
	modulate.a = 1.0
	scale.x = 2.0
	scale.y = 2.0
	$BaseSprite.scale *= 0.9
	
	# Set visibility order
	z_as_relative = false
	z_index = get_node("/root/main").layerGround

	# Set timers
	$FizzleTimer.start(get_parent().get_parent().purpleDuration)

# Grow for visual effect
func _process(_delta: float) -> void:
	modulate.a = min(0.9, $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time())

func _on_fizzle_timer_timeout() -> void:
	queue_free()
