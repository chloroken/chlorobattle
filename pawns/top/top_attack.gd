extends "res://pawns/base/base_attack.gd"

var direction
var speed = 0

func _ready() -> void:
	areaAttack = false
	scale.x = 0
	scale.y = 0

	# Randomize physics & color
	$BaseSprite.modulate.r = randf_range(0.8, 1.0)
	$BaseSprite.modulate.b = randf_range(0.8, 1.0)
	$BaseSprite.modulate.g = randf_range(0.8, 1.0)

# Move & grow sprite
func _physics_process(delta: float) -> void:
	scale.x = 1 - $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()
	scale.y = 1 - $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()
	position += direction * speed * delta

func _on_fizzle_timer_timeout() -> void:
	queue_free()
