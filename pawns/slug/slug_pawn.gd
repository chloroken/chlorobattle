extends "res://pawns/base/base_pawn.gd"

@export var slugAttack: PackedScene
var gooOffset = 5
var slugRegeneration = 0.1

# Drop slug trail attack
func _on_attack_cooldown_timer_timeout() -> void:
	var newAttack = slugAttack.instantiate()
	var ranX = randi_range(-gooOffset, gooOffset)
	var ranY = randi_range(-gooOffset, gooOffset)
	newAttack.position = self.position + Vector2(ranX, ranY)
	newAttack.dmg = self.dmg
	newAttack.baseDmg = self.dmg
	attackObjects.append(newAttack)
	$AttackContainer.add_child(newAttack)
	$AttackCooldownTimer.start(asp * baseAsp + random_variance())
	
	# Regenerate health every time slug attacks
	hp += slugRegeneration
