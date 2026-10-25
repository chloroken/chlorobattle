extends "res://pawns/_base/attacks/base_attack.gd"

var duration
var direction
var speed

func _ready() -> void:
	super()

	random_meow_color()
	$FizzleTimer.start(duration)

func random_meow_color() -> void:
	$BaseSprite.modulate = Color(randf(), randf(), randf())

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_fizzle_timer_timeout() -> void:
	queue_free()

func _on_area_exited(area: Area2D) -> void:
	if area.get_collision_layer_value(6):
		direction = (position.direction_to(basePawn.center) + direction).normalized()
