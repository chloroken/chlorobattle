extends "res://pawns/base/base_attack.gd"

var spinSpd = 10
var spinDirs = [-1, 1]
var spinDir = spinDirs.pick_random()
var spinAlphaFloor = 0.5

func _ready() -> void:
	#scale = Vector2.ZERO
	$BaseSprite.modulate.r = randf_range(0.5, 1.0)
	#$BaseSprite.modulate.b = randf_range(0.5, 1.0)
	$BaseSprite.modulate.g = randf_range(0.5, 1.0)

func _process(delta: float) -> void:
	rotation += spinSpd * spinDir * delta
	#scale = Vector2.ONE * (2 - 2 * $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time())
	$BaseSprite.modulate.a = max(spinAlphaFloor, $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time())

func _on_fizzle_timer_timeout() -> void:
	queue_free()
