extends "res://pawns/base/base_pawn.gd"

# Swing attack variables
@export var chairAttack: PackedScene
var swingCooldown = 2.0
var swingDurMin = 0.75
var swingDurMax = 1.0
var swingSpdMin = 10.0
var swingSpdMax = 20.0
var scaleMin = 0.75
var scaleMax = 1.0

# Redwood variables
var critScale = 2.0
var critChance = 5
var critDmgMod = 1.25
var woodColor = Color(1.0, 0.25, 0.25, 1.0)

func _ready() -> void:
	super()
	if !attacksDisabled: start_attack_cooldown()

func _on_attack_cooldown_timer_timeout() -> void:
	start_attack_cooldown()
	if disarm_check(): return
	
	# Attack with Chair leg
	var newAttack = chairAttack.instantiate()
	newAttack.position = self.position
	newAttack.dmg = self.dmg
	
	# Swing duration & speed
	newAttack.swingDur = randf_range(swingDurMin, swingDurMax)
	newAttack.swingSpd = randf_range(swingSpdMin, swingSpdMax)

	# Redwood "crit" mechanic
	if randi_range(1, critChance) != 1:
		newAttack.scaleMod = randf_range(scaleMin, scaleMax)
	else:
		# Convert to redwood
		newAttack.get_node("BaseSprite").modulate = woodColor
		newAttack.scaleMod = critScale
		newAttack.swingSpd = swingSpdMin
		newAttack.swingDur = swingDurMax
		newAttack.dmg *= critDmgMod

	# Finish creating swing
	attackObjects.append(newAttack)
	$AttackContainer.add_child(newAttack)
	$Status.start_stuck(newAttack.swingDur)

func start_attack_cooldown() -> void:
	$AttackCooldownTimer.start(asp * swingCooldown + random_variance())
