extends Node2D

var direction = Vector2.UP
var speed = 25
var duration = 3.0

func _ready() -> void:
	z_index = get_node("/root/main").layerAir
	$FizzleTimer.start(duration)

func _process(_delta: float) -> void:
	$Sprite.modulate.a = $FizzleTimer.get_time_left() / duration
	scale = Vector2.ONE * lerp(0.0, 2.0, $FizzleTimer.get_time_left() / duration)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_fizzle_timer_timeout() -> void:
	queue_free()
