extends "res://pawns/_base/attacks/base_item_attack.gd"

var targetHole = null

func _ready() -> void:
	isShovelAttack = true

func _on_fizzle_timer_timeout() -> void:
	queue_free()
