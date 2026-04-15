extends "res://pawns/base/base_attack.gd"

var direction
var speed = 0
var baseScale

func _ready() -> void:
	areaAttack = false
	baseScale = randf_range(0.75, 1.0)
	scale.x = baseScale
	scale.y = baseScale

	# Randomize physics & color
	#$BaseSprite.modulate.r = randf_range(0.8, 1.0)
	#$BaseSprite.modulate.b = randf_range(0.5, 1.0)
	$BaseSprite.modulate.g = randf_range(0.75, 1.0)

# Move & grow sprite
func _physics_process(delta: float) -> void:
	scale.x = max(0.5, baseScale * $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time())
	scale.y = max(0.5, baseScale * $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time())
	position += direction * speed * delta

func _on_fizzle_timer_timeout() -> void:
	queue_free()
