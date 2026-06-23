extends "res://pawns/_base/base_pawn.gd"

# Parrot variables
@export var pirateAttack: PackedScene
var birdAttackCooldown = 2.0
var minDmgRatio = 0.5
var birdSpeed = 150
var birdMaxDist = 100
var birdSizeMin = 0.5
var birdSizeMax = 0.75
var birdReturnSpeed = 10

# Grog variables
var grogDuration = 5.0
var grogCooldownMin = 5.0
var grogCooldownMax = 10.0

# Trickshot variables
@export var trickshotAttack: PackedScene
var trickshotCooldownMin = 3.0
var trickshotCooldownMax = 4.0
var trickshotMaxBounces = 2
var trickshotSpeed = 500
var trickshotDamageRamp = 25

@export var birdAttack: Resource

func _ready() -> void:
	super()

	# Start attack cycle
	if !attacksDisabled:
		start_attack_cooldown()
		$GrogCooldownTimer.one_shot = true
		start_grog_cooldown()

func start_attack_cooldown() -> void:
	var parrotCooldown = asp * aspMod * birdAttackCooldown
	$AttackCooldownTimer.start(parrotCooldown)

func _on_attack_cooldown_timer_timeout() -> void:
	start_attack_cooldown()
	if disarm_check(): return

	var newAttack = birdAttack.instantiate()
	newAttack.position = self.position
	newAttack.dmg = self.dmg
	newAttack.attackName = "Parrot"
	newAttack.speed = birdSpeed
	$AttackContainer.add_child(newAttack)

func start_grog_cooldown() -> void:
	var grogCooldown = randf_range(grogCooldownMin, grogCooldownMax)
	$GrogCooldownTimer.start(grogCooldown)

func _on_grog_cooldown_timer_timeout() -> void:
	$Status.start_drunk(grogDuration)
	start_grog_cooldown()

func shoot_trickshot() -> void:
	var newAttack2 = trickshotAttack.instantiate()
	newAttack2.position = self.position
	newAttack2.dmg = self.dmg * 2
	newAttack2.attackName = "Trickshot"
	newAttack2.direction = self.direction
	newAttack2.speed = trickshotSpeed
	newAttack2.maxBounces = trickshotMaxBounces
	$AttackContainer.add_child(newAttack2)
