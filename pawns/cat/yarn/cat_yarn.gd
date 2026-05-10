extends "res://pawns/_base/attack/base_attack.gd"

var yarnDuration = 10.0

func _ready() -> void:
	attackName = "Yarn"
	isYarnAttack = true
	areaAttack = false
	$FizzleTimer.start(yarnDuration)

func _on_fizzle_timer_timeout() -> void:
	queue_free()
