extends "res://pawns/base/base_pawn.gd"

# Swing variables
@export var chairAttack: PackedScene
var swingDurMin = 1.0
var swingDurMax = 2.0
var swingCooldownMin = 2.0
var swingCooldownMax = 3.0

# Redwood variables
var redwoodChance = 10
var redwoodDmg = 1.5
var redwoodColor = Color(1.0, 0.25, 0.25, 1.0)

func _ready() -> void:
	super()
	if !attacksDisabled:
		start_attack_cooldown()
		$RushDurationTimer.one_shot = true

func start_attack_cooldown() -> void:
	var cooldown = asp * randf_range(swingCooldownMin, swingCooldownMax)
	$AttackCooldownTimer.start(cooldown)

func _on_attack_cooldown_timer_timeout() -> void:
	if disarm_check():
		start_attack_cooldown()
		return

	# Determine length of attack
	var rushDur = randf_range(swingDurMin, swingDurMax)
	$Status.start_sprint(rushDur)

	# Swing
	var legCount = randi_range(1, 4)
	var redwoodUsed = false
	for i in legCount:
		var newAttack = chairAttack.instantiate()
		newAttack.position = self.position
		newAttack.dmg = self.dmg
		newAttack.rotation = TAU / legCount * i
		newAttack.attackName = "Swing"
		newAttack.swingDur = rushDur
		newAttack.swingDir = 1
		newAttack.swingSpd = 10
		newAttack.scaleMod = 1

		# Redwood
		if randi_range(1, redwoodChance) == 1 && !redwoodUsed:
			redwoodUsed = true
			newAttack.get_node("BaseSprite").modulate = redwoodColor
			newAttack.dmg *= redwoodDmg
			newAttack.attackName = "Redwood"

		attackObjects.append(newAttack)
		$AttackContainer.add_child(newAttack)

	$RushDurationTimer.start(rushDur)

func _on_rush_duration_timer_timeout() -> void:
	start_attack_cooldown()
