extends Node2D

var parentPawn
var targetSoul
var duration
var offset = 16
var offsetX
var offsetY
var offsetVector = Vector2.ZERO

func _ready() -> void:
	offsetX = randf_range(-offset, offset)
	offsetY = randf_range(-offset, offset)
	offsetVector = Vector2(offsetX, offsetY)
	$FizzleTimer.start(duration)

func _physics_process(_delta: float) -> void:
	if targetSoul == null:
		queue_free()
		return
	look_at(targetSoul.position)
	var lerpRatio = $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()
	position = lerp(parentPawn.position + offsetVector, targetSoul.position, 1.0 - lerpRatio)

func _on_fizzle_timer_timeout() -> void:
	queue_free()
