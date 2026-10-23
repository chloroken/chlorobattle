extends "res://pawns/_base/base_pawn.gd"

@export var swingAttackScene: PackedScene
var swingAttackName = "Swing"
var swingDurationMin = 1.0
var swingDurationMax = 2.0
var swingCooldownMin = 2.0
var swingCooldownMax = 4.0
var swingMaxLegs = 4
var swingRotateSpeed = 10
var swingScaleModifier = 1.25

var swingRedwoodName = "Redwood"
var redwoodChance = 10
var redwoodDmg = 2.0
var redwoodColor = Color(1.0, 0.25, 0.25, 1.0)

func _ready() -> void:
	super()

	if !inLobby:
		$SwingDurationTimer.one_shot = true
		new_attack_cycle(swingCooldownMin, swingCooldownMax)

func _on_attack_cooldown_timer_timeout() -> void:
	var swingDuration = randf_range(swingDurationMin, swingDurationMax)
	new_attack_cycle(swingCooldownMin + swingDuration, swingCooldownMax + swingDuration)
	if disarm_check(): return

	swing_apply_status(swingDuration)
	leg_generation_procedure(swingDuration)
	$SwingDurationTimer.start(swingDuration)

func swing_apply_status(swingDuration) -> void:
	var buffChoice = randi_range(0, 1)
	if !buffChoice: $Status.start_sprint(swingDuration)
	else: $Status.start_tanky(swingDuration)

func leg_generation_procedure(swingDuration) -> void:
	var legCount = calculate_swing_leg_count()
	var redwoodUsed = false
	for i in legCount:
		var newAttack = create_swing_leg(legCount, i, swingDuration)
		if check_for_redwood(redwoodUsed, newAttack):
			redwoodUsed = true
		$AttackContainer.add_child(newAttack)

func calculate_swing_leg_count() -> int:
	var legCount = 1
	for i in swingMaxLegs - 1:
		if randi_range(0, 1) == 0:
			legCount += 1
		else:
			break
	return(legCount)

func create_swing_leg(legCount, i, swingDuration) -> Variant:
	var newAttack = swingAttackScene.instantiate()
	newAttack.position = self.position
	newAttack.dmg = self.dmg
	newAttack.rotation = TAU / legCount * i
	newAttack.attackName = swingAttackName
	newAttack.areaAttack = false
	newAttack.swingDur = swingDuration
	newAttack.swingDir = 1
	newAttack.swingSpd = swingRotateSpeed
	newAttack.scaleMod = swingScaleModifier
	return(newAttack)

func check_for_redwood(redwoodUsed, newAttack) -> bool:
	if randi_range(1, redwoodChance) == 1 && !redwoodUsed:
		redwoodUsed = true
		newAttack.get_node("BaseSprite").modulate = redwoodColor
		newAttack.dmg *= redwoodDmg
		newAttack.attackName = swingRedwoodName
		newAttack.areaAttack = true
		return(true)
	return(false)
