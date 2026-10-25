extends Node2D

var duration = 5.0
var vertOffset = 32
var driftDist = 32

func _ready() -> void:
	z_index = get_node("/root/main").layerAir
	$FizzleTimer.start(duration)

func _process(delta: float) -> void:
	
	var ratio = $FizzleTimer.get_time_left() / duration
	
	var pawnPos = get_parent().get_parent().position
	var offset = Vector2.UP * vertOffset
	position = pawnPos + offset + (1.0 - ratio) * Vector2.UP * driftDist
	modulate.a = ratio

func _on_fizzle_timer_timeout() -> void:
	queue_free()
