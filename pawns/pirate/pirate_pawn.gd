extends "res://pawns/base/base_pawn.gd"

@export var pirateAttack: PackedScene

func _ready() -> void:
	super()
	if !attacksDisabled:
		$AttackCooldownTimer.one_shot = true
		$AttackCooldownTimer.start(asp * baseAttackCooldown + random_variance())

func _on_attack_cooldown_timer_timeout() -> void:
	var newAttack = pirateAttack.instantiate()
	newAttack.position = self.position
	newAttack.baseDmg = self.dmg
	attackObjects.append(newAttack)
	$AttackContainer.add_child(newAttack)
	$AttackCooldownTimer.start(asp * baseAttackCooldown + random_variance())
