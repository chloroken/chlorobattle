extends "res://pawns/_base/base_pawn.gd"

# Glyph variables
@export var glyphAttack: Resource
var glyphChannelDur = 2.0
var glyphAttackDur = 3.0
var glyphCooldownMin = 8.0
var glyphCooldownMax = 12.0
var innerRotateSpeed = .25
var outerRotateSpeed = .50
var glyphDisarmDuration = 3.0 # used in base pawn
var purpleDuration = 1.0

# Curse variables
var curseDuration = 99999
var curseResetTimer = 10 # used in base pawn
var cursePassDuration = 5.0 # used in base pawn

func _ready() -> void:
	super()

	# Start attack cycle
	if !attacksDisabled: 
		$CursedResetTimer.one_shot = true
		isCursed = true
		$Status.start_weak(curseDuration)
		start_attack_cooldown()

func start_attack_cooldown() -> void:
	var glyphCooldown = asp * aspMod * randf_range(glyphCooldownMin, glyphCooldownMax)
	$AttackCooldownTimer.start(glyphCooldown)

func _on_attack_cooldown_timer_timeout() -> void:
	start_attack_cooldown()
	if disarm_check(): return

	# Glyph attack
	var newAttack = glyphAttack.instantiate()
	newAttack.position = self.position
	newAttack.dmg = self.dmg
	$AttackContainer.add_child(newAttack)

	# Set statuses
	$Status.start_stuck(glyphChannelDur, self)
	$Status.start_void(glyphChannelDur)

func _on_cursed_reset_timer_timeout() -> void:
	isCursed = true
	$Status.start_weak(curseDuration)
