extends "res://pawns/base/base_pawn.gd"

@export var slugAttack: PackedScene
var slugAttackSpeed = 1.0
var trailDuration = 10.0
var trailOffset = 3
var healthRegen = 0.1

func _ready() -> void:
	super()

	# Start attack cycle
	if !attacksDisabled: start_attack_cooldown()

func _on_attack_cooldown_timer_timeout() -> void:
	start_attack_cooldown()
	if disarm_check(): return
	
	var newAttack = slugAttack.instantiate()
	var ranX = randi_range(-trailOffset, trailOffset)
	var ranY = randi_range(-trailOffset, trailOffset)
	newAttack.position = self.position + Vector2(ranX, ranY)
	newAttack.baseDmg = self.dmg
	newAttack.attackName = "Ooze"
	attackObjects.append(newAttack)
	$AttackContainer.add_child(newAttack)

	# Regenerate health every time slug attacks
	hp += healthRegen

	# Just in case
	#if hp > baseHp: hp = baseHp

func start_attack_cooldown() -> void:
	$AttackCooldownTimer.start(asp * slugAttackSpeed + random_variance())
