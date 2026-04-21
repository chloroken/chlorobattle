extends "res://pawns/base/base_pawn.gd"

@export var slugAttack: PackedScene
var trailDuration = 10.0
var trailOffset = 3
var healthRegen = 0.1

func _ready() -> void:
	super()
	
	# Start attack cycle
	if !attacksDisabled:
		$AttackCooldownTimer.one_shot = true
		$AttackCooldownTimer.start(asp * baseAttackCooldown + random_variance())

# Drop slug trail attack
func _on_attack_cooldown_timer_timeout() -> void:
	var newAttack = slugAttack.instantiate()
	var ranX = randi_range(-trailOffset, trailOffset)
	var ranY = randi_range(-trailOffset, trailOffset)
	newAttack.position = self.position + Vector2(ranX, ranY)
	newAttack.baseDmg = self.dmg
	attackObjects.append(newAttack)
	$AttackContainer.add_child(newAttack)
	$AttackCooldownTimer.start(asp * baseAttackCooldown + random_variance())
	
	# Regenerate health every time slug attacks
	hp += healthRegen
