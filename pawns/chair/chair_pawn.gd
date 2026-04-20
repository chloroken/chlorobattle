extends "res://pawns/base/base_pawn.gd"

@export var chairAttack: PackedScene
var baseSpd

func _ready() -> void:
	super()

	# Lock in base speed to stutter
	baseSpd = spd

	# Start timers
	if !attacksDisabled:
		$AttackStutterTimer.one_shot = true
		$AttackCooldownTimer.one_shot = true
		$AttackCooldownTimer.start(asp * baseAttackCooldown + random_variance())

func _on_attack_cooldown_timer_timeout() -> void:
	
	# Attack with Chair leg
	var newAttack = chairAttack.instantiate()
	newAttack.position = self.position
	newAttack.dmg = self.dmg
	attackObjects.append(newAttack)
	$AttackContainer.add_child(newAttack)
	$AttackCooldownTimer.start(asp * baseAttackCooldown + random_variance())

	# Stutter step after every attack
	spd = 0

# Reset speed to finish stutter 
func _on_attack_stutter_timer_timeout() -> void:
	spd = baseSpd
