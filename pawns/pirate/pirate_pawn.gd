extends "res://pawns/base/base_pawn.gd"

# Parrot variables
@export var pirateAttack: PackedScene
var minDmgRatio = 0.5
var birdSpeed = 75
var birdMaxDist = 100
var birdSizeMin = 0.5
var birdSizeMax = 0.75
var birdReturnSpeed = 5

func _ready() -> void:
	super()
	
	# Start attack cycle
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
