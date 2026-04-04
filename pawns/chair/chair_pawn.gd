extends "res://pawns/base/base_pawn.gd"

@export var chairAttack: PackedScene
var baseSpd

# Save speed for stuttering
func _ready() -> void:
	super()
	baseSpd = spd

func _on_attack_cooldown_timer_timeout() -> void:
	var newAttack = chairAttack.instantiate()
	newAttack.position = self.position
	newAttack.dmg = self.dmg
	attackObjects.append(newAttack)
	$AttackContainer.add_child(newAttack)
	$AttackCooldownTimer.start($AttackCooldownTimer.get_wait_time() + random_variance())

	# Stutter step after every attack
	spd = 0
	$AttackStutterTimer.start()

func _on_attack_stutter_timer_timeout() -> void:
	spd = baseSpd
