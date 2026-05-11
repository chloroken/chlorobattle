extends Node2D

var direction = Vector2.UP
var speed = 25
var duration = 3.0

func _ready() -> void:
	$FizzleTimer.start(duration)
	# Set visibility order
	z_as_relative = false
	z_index = get_node("/root/main").layerAir

func _process(_delta: float) -> void:
	$Sprite.modulate.a = $FizzleTimer.get_time_left() / duration
	scale = Vector2.ONE * lerp(0.0, 2.0, $FizzleTimer.get_time_left() / duration)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_fizzle_timer_timeout() -> void:
	queue_free()
