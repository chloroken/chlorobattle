extends Node2D

var shakeScaleMod = 2.0

func _ready() -> void:
	z_index = get_node("/root/main").layerPawnBehind

# Grow Milkshake sprite
func _process(_delta: float) -> void:
	var shakeScale = shakeScaleMod * (1 - $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time())
	$MilkshakeSprite.scale.x = shakeScale
	$MilkshakeSprite.scale.y = shakeScale

# Clean up
func _on_fizzle_timer_timeout() -> void:
	queue_free()
