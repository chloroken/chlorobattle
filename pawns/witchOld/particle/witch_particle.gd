extends Node2D

var fizzleDurationMin = 1.0
var fizzleDurationMax = 2.0
var direction
var speed
var speedMin = 5
var speedMax = 10
var sizeMin = 0.5
var sizeMax = 2.0

func _ready() -> void:
	scale = Vector2.ONE * randf_range(sizeMin, sizeMax)
	direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	speed = randf_range(speedMin, speedMax)
	$FizzleTimer.start(randf_range(fizzleDurationMin, fizzleDurationMax))
	if randi_range(1, 10) != 10: set_random_color()

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_fizzle_timer_timeout() -> void:
	queue_free()

func set_random_color():
	$Sprite2D.modulate.r = randf_range(0.8, 1.0)
	$Sprite2D.modulate.g = 0.5
	$Sprite2D.modulate.b = randf_range(0.8, 1.0)
