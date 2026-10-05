extends "res://pawns/_base/base_pawn.gd"

@export var demonChildSprite: Resource
var girlScaredDuration = 999

@export var soulAttackScene: Resource
var soulAttackName = "Soul"
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

@export var demonUnleashSprite: Resource
var unleashFormCooldown = 30.0
var unleashFormDuration = 5.0
var unleashSoulCooldownReduction = 1.0
var unleashSoulAttackCooldown = 0.2
var unleashFormActive = false
var unleashHalfHealthProc = false

@export var assumeEffectScene: PackedScene
var assumeSoulArray = []
var assumeCooldownMin = 8.0
var assumeCooldownMax = 12.0
var assumeHealPercent = 1
var assumeDelayDuration = 1.0
var assumeSoulColor = Color.INDIAN_RED
var assumeCurrentSoul = null

func _ready() -> void:
	super()

	if !attacksDisabled:
		start_attack_cooldown()
		$UnleashDurationTimer.one_shot = true
		$UnleashCooldownTimer.one_shot = true
		$AssumeCooldownTimer.one_shot = true
		$AssumeDurationTimer.one_shot = true
		start_assume_cooldown()
		$UnleashCooldownTimer.start(unleashFormCooldown)
		$Status.start_scared(girlScaredDuration)

func start_attack_cooldown() -> void:
	if !unleashFormActive:
		$AttackCooldownTimer.start(asp * aspMod * randf_range(soulCooldownMin, soulCooldownMax))
	else:
		$AttackCooldownTimer.start(unleashSoulAttackCooldown)

func _on_attack_cooldown_timer_timeout() -> void:
	start_attack_cooldown()
	if disarm_check(): return
	new_soul_attack()

func new_soul_attack() -> void:
	var newAttack = soulAttackScene.instantiate()
	newAttack.position = position
	newAttack.dmg = self.dmg
	newAttack.areaAttack = false
	newAttack.isSoulAttack = true
	newAttack.attackName = soulAttackName
	newAttack.basePawn = self
	newAttack.spd = randf_range(soulMoveSpeedMin, soulMoveSpeedMax)
	newAttack.scale = Vector2.ONE * randf_range(soulSizeMin, soulSizeMax)
	newAttack.modulate.g = randf_range(soulColorVariance, 1.0)
	newAttack.modulate.b = randf_range(soulColorVariance, 1.0)
	$AttackContainer.add_child(newAttack)
	assumeSoulArray.append(newAttack)

func _on_unleash_cooldown_timer_timeout() -> void:
	$Status.start_stuck(unleashFormDuration, self)
	$Status.start_tanky(unleashFormDuration)
	unleashFormActive = true
	start_attack_cooldown()
	$PawnSprite.texture = demonUnleashSprite
	$UnleashDurationTimer.start(unleashFormDuration)

func _on_unleash_duration_timer_timeout() -> void:
	unleashFormActive = false
	$Status.start_scared(girlScaredDuration) # reapply just in case
	$PawnSprite.texture = demonChildSprite
	$Status.start_scared(girlScaredDuration)
	$UnleashCooldownTimer.start(unleashFormCooldown)

func start_assume_cooldown() -> void:
	$AssumeCooldownTimer.start(asp * aspMod * randf_range(assumeCooldownMin, assumeCooldownMax))

func _on_assume_cooldown_timer_timeout() -> void:
	start_assume_cooldown()
	if assumeSoulArray.size() == 0: return
	if unleashFormActive: return

	var furthestSoul = self
	for soul in assumeSoulArray:
		var distToSoul = self.position.distance_to(soul.position)
		var furthestDist = self.position.distance_to(furthestSoul.position)
		if distToSoul > furthestDist:
			furthestSoul = soul

	var soulToAssume = furthestSoul
	soulToAssume.isAssumeSoul = true
	soulToAssume.modulate = assumeSoulColor
	assumeCurrentSoul = soulToAssume
	
	$AssumeDurationTimer.start(assumeDelayDuration)
	
	for i in 10:
		var newAssumeEffect = assumeEffectScene.instantiate()
		newAssumeEffect.parentPawn = self
		newAssumeEffect.targetSoul = soulToAssume
		newAssumeEffect.duration = assumeDelayDuration
		$AttackContainer.add_child(newAssumeEffect)

func _on_assume_duration_timer_timeout() -> void:
	if assumeCurrentSoul == null: return
	self.position = assumeCurrentSoul.position
	assumeSoulArray.erase(assumeCurrentSoul)
	assumeCurrentSoul.queue_free()
	assumeCurrentSoul = null
