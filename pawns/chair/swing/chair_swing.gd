extends "res://pawns/_base/attacks/base_attack.gd"

var swingDur
var swingDir
var swingSpd
var scaleMod

func _ready() -> void:
	scale = Vector2.ONE * 0.5
	z_index = get_node("/root/main").layerPawnFront
	$FizzleTimer.start(swingDur)

func _physics_process(delta: float) -> void:
	adjust_swing_rotation(delta)
	adjust_swing_scale()

func adjust_swing_rotation(delta) -> void:
	rotation += swingDir * swingSpd * delta
	position = get_parent().get_parent().position

func adjust_swing_scale() -> void:
	var scaleRatio = $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()
	var scaleAmount = 0.5 + 0.5 * (scaleMod - scaleRatio * scaleMod)
	scale = Vector2.ONE * scaleAmount

func _on_fizzle_timer_timeout() -> void:
	queue_free()
