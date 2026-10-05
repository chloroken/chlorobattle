extends "res://pawns/_base/base_attack.gd"

var duration
var speed
var direction

func _ready() -> void:
	super()
	$FizzleTimer.start(duration)
	z_index = get_node("/root/main").layerAir

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_fizzle_timer_timeout() -> void:
	queue_free()
