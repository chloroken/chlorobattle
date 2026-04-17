extends "res://pawns/base/base_attack.gd"

var direction
var speed = 0
var baseScale
var duration = 5.0
var durVariance = 0.5
var minScale = 0.25

func _ready() -> void:
	z_index = get_node("/root/main").layerGround
	$FizzleTimer.start(randf_range(duration, duration * durVariance))
	areaAttack = false
	baseScale = randf_range(0.5, 1.0)
	scale.x = baseScale
	scale.y = baseScale

	# Randomize color
	$BaseSprite.modulate.g = randf_range(0.75, 1.0)

# Move & grow sprite
func _physics_process(delta: float) -> void:
	scale.x = max(minScale, baseScale * $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time())
	scale.y = max(minScale, baseScale * $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time())
	position += direction * speed * delta

func _on_fizzle_timer_timeout() -> void:
	queue_free()
