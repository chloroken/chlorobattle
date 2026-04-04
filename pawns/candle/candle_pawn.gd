extends "res://pawns/base/base_pawn.gd"


@export var candleAttack: PackedScene

func _on_attack_cooldown_timer_timeout() -> void:
	var newAttack = candleAttack.instantiate()
	newAttack.position = self.position
	newAttack.dmg = self.dmg
	attackObjects.append(newAttack)
	$AttackContainer.add_child(newAttack)
	var flickerRange = randf_range(0.1, 1.0)
	$AttackCooldownTimer.start(flickerRange)
