extends "res://pawns/base/base_pawn.gd"

# Parrot variables
@export var pirateAttack: PackedScene
var birdAttackCooldown = 1.0
var minDmgRatio = 0.5
var birdSpeed = 75
var birdMaxDist = 100
var birdSizeMin = 0.5
var birdSizeMax = 0.75
var birdReturnSpeed = 10

# Grog variables
var grogDuration = 5.0
var grogCooldownMin = 5.0
var grogCooldownMax = 10.0

func _ready() -> void:
	super()

	# Start attack cycle
	if !attacksDisabled:
		start_attack_cooldown()
		$GrogCooldownTimer.one_shot = true
		start_grog_cooldown()

func _on_attack_cooldown_timer_timeout() -> void:
	start_attack_cooldown()
	if disarm_check(): return
	
	var newAttack = pirateAttack.instantiate()
	newAttack.position = self.position
	newAttack.baseDmg = self.dmg
	newAttack.attackName = "Parrot"
	newAttack.birdSpeed = birdSpeed
	attackObjects.append(newAttack)
	$AttackContainer.add_child(newAttack)

func start_attack_cooldown() -> void:
	$AttackCooldownTimer.start(asp * birdAttackCooldown + random_variance())

func start_grog_cooldown() -> void:
	$GrogCooldownTimer.start(randf_range(grogCooldownMin, grogCooldownMax))

func _on_grog_cooldown_timer_timeout() -> void:
	$Status.start_drunk(grogDuration)
	start_grog_cooldown()
