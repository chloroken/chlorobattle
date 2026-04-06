extends "res://pawns/base/base_pawn.gd"

@export var candleAttack: PackedScene

func _on_attack_cooldown_timer_timeout() -> void:
	var newAttack = candleAttack.instantiate()
	newAttack.position = self.position
	newAttack.dmg = self.dmg
	attackObjects.append(newAttack)
	$AttackContainer.add_child(newAttack)

	# Slow attack rate from (0.1 ~ 1.0) to (0.1 ~ 2.0)
	# starting from half hitpoints down to none
	var flickerRange = randf_range(0.1, 2.0 * max(0.5, (1 - hp / baseHp)))
	$AttackCooldownTimer.start(flickerRange)
