extends "res://pawns/_base/base_attack.gd"

var duration

func _ready() -> void:
	super()
	$FizzleTimer.start(duration)
	z_index = get_node("/root/main").layerGround

func _on_fizzle_timer_timeout() -> void:
	queue_free()
