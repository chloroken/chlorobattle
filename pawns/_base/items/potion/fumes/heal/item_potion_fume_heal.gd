extends Node2D

var durationMin = 1.0
var durationMax = 2.0
var direction
var spd = 10.0

func _ready() -> void:
	direction = Vector2.ONE.rotated(randf_range(0, TAU))
	$FizzleTimer.start(randf_range(durationMin, durationMax))
	
	# Set visibility order
	z_as_relative = false
	z_index = get_node("/root/main").layerAir

func _process(delta: float) -> void:
	position += direction * spd * delta
	
	modulate.a = $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()
	scale = Vector2.ONE * (2 - $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time())

func _on_fizzle_timer_timeout() -> void:
	queue_free()
