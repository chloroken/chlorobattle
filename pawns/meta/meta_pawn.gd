extends "res://pawns/base/base_pawn.gd"

@export var girlSprite: Resource
var girlScaredDuration = 9999

@export var soulAttack: Resource
var soulCooldownMin = 1.0
var soulCooldownMax = 2.0
var soulDurationMin = 10.0
var soulDurationMax = 10.0
var soulDirChangeMin = 2.0
var soulDirChangeMax = 3.0
var soulMoveSpeedMin = 25
var soulMoveSpeedMax = 50
var soulReturnHeal = 1.0
var soulSizeMin = 0.8
var soulSizeMax = 1.0
var soulColorVariance = 0.8

@export var demonSprite: Resource
var demonFormCooldown = 60.0
var demonFormDuration = 5.0
var demonSoulCooldownReduction = 2.0
var demonSoulAttackCooldown = 0.1
var demonFormActive = false

func _ready() -> void:
	super()

	if !attacksDisabled:
		start_attack_cooldown()
		$DemonDurationTimer.one_shot = true
		$DemonCooldownTimer.one_shot = true
		$DemonCooldownTimer.start(demonFormCooldown)
		$Status.start_scared(girlScaredDuration)

func start_attack_cooldown() -> void:
	if !demonFormActive:
		$AttackCooldownTimer.start(asp * randf_range(soulCooldownMin, soulCooldownMax))
	else:
		$AttackCooldownTimer.start(demonSoulAttackCooldown)

func _on_attack_cooldown_timer_timeout() -> void:
	start_attack_cooldown()
	if disarm_check(): return

	# Soul Attack
	var newAttack = soulAttack.instantiate()
	newAttack.position = position
	newAttack.dmg = self.dmg
	newAttack.spd = randf_range(soulMoveSpeedMin, soulMoveSpeedMax)
	newAttack.scale = Vector2.ONE * randf_range(soulSizeMin, soulSizeMax)
	newAttack.modulate.g = randf_range(soulColorVariance, 1.0)
	newAttack.modulate.b = randf_range(soulColorVariance, 1.0)
	$AttackContainer.add_child(newAttack)

func _on_demon_cooldown_timer_timeout() -> void:
	$Status.start_stuck(demonFormDuration)
	$Status.start_tanky(demonFormDuration)
	$Status.stop_scared()
	demonFormActive = true
	start_attack_cooldown()
	$PawnSprite.texture = demonSprite
	$DemonDurationTimer.start(demonFormDuration)

func _on_demon_duration_timer_timeout() -> void:
	demonFormActive = false
	$PawnSprite.texture = girlSprite
	$Status.start_scared(girlScaredDuration)
	$DemonCooldownTimer.start(demonFormCooldown)

func _process(_delta: float) -> void:
	if !attacksDisabled:
		if !demonFormActive:
			var demonTimer = $DemonCooldownTimer
			$DemonLabel.text = str(int(demonTimer.get_time_left()))
		else:
			var demonTimer = $DemonDurationTimer
			$DemonLabel.text = str(int(demonTimer.get_time_left()))
	#if girl, add scared timer
	#if demon, clear scared
	pass
