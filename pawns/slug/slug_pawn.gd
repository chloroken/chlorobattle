extends "res://pawns/base/base_pawn.gd"

@export var slugAttack: PackedScene
var trailDuration = 10.0
var trailOffset = 3
var healthRegen = 0.1

func _ready() -> void:
	super()

	# Start attack cycle
	if !attacksDisabled:
		$AttackCooldownTimer.start(asp * baseAttackCooldown + random_variance())

# Drop slug trail attack
func _on_attack_cooldown_timer_timeout() -> void:

	# Prevent attacks if timid
	if !$Status.get_node("TimidStatusTimer").is_stopped():
		$AttackCooldownTimer.start(asp * baseAttackCooldown + random_variance())
		return
	
	var newAttack = slugAttack.instantiate()
	var ranX = randi_range(-trailOffset, trailOffset)
	var ranY = randi_range(-trailOffset, trailOffset)
	newAttack.position = self.position + Vector2(ranX, ranY)
	newAttack.baseDmg = self.dmg
	attackObjects.append(newAttack)
	$AttackContainer.add_child(newAttack)

	# Regenerate health every time slug attacks
	hp += healthRegen

	# Just in case
	#if hp > baseHp: hp = baseHp

	$AttackCooldownTimer.start(asp * baseAttackCooldown + random_variance())
