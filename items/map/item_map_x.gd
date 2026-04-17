extends Node2D

func _ready() -> void:
	z_index = get_node("/root/main").layerGround
	rotation = randf_range(0, TAU)
	var sizeRatio = randf_range(0.75, 1.0)
	scale *= sizeRatio

func _process(_delta: float) -> void:
	var fadeRatio = $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()
	$MapXSprite.modulate.a = fadeRatio

func _on_fizzle_timer_timeout() -> void:
	queue_free()
