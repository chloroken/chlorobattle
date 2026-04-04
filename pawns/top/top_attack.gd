extends "res://pawns/base/base_attack.gd"

var direction
var speed = 0

func _ready() -> void:
	areaAttack = false

	# Randomize physics & color
	var randomScale = randf_range(0.75, 1.0)
	$BaseSprite.scale.x = randomScale
	$BaseSprite.scale.y = randomScale
	$BaseSprite.modulate.r = randf_range(0.8, 1.0)
	$BaseSprite.modulate.b = randf_range(0.8, 1.0)
	$BaseSprite.modulate.g = randf_range(0.8, 1.0)

# Move & grow sprite
func _physics_process(delta: float) -> void:
	$BaseSprite.scale *= 1.1
	position += direction * speed * delta

func _on_fizzle_timer_timeout() -> void:
	queue_free()
