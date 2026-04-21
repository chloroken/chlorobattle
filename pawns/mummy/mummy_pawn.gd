extends "res://pawns/base/base_pawn.gd"

# Glyph variables
@export var glyphAttack: Resource
var glyphChannelDur = 3.0
var glyphAttackDur = 4.0
var glyphCooldownMin = 8.0
var glyphCooldownMax = 12.0
var innerRotateSpeed = .25
var outerRotateSpeed = .50
var glyphStuckDuration = 5.0 # used in base pawn
var purpleDuration = 1.0

# Curse variables
var curseDuration = 99999
var curseResetTimer = 10 # used in base pawn
var cursePassDuration = 5.0 # used in base pawn

func _ready() -> void:
	super()
	
	# Start curse routine
	isCursed = true
	$Status.start_weak(curseDuration)
	
	# Start attack cycle
	if !attacksDisabled:
		$CursedResetTimer.one_shot = true
		$AttackCooldownTimer.one_shot = true
		$AttackCooldownTimer.start(asp * randf_range(glyphCooldownMin, glyphCooldownMax) + random_variance())

func _on_attack_cooldown_timer_timeout() -> void:
	
	# Glyph attack
	var newAttack = glyphAttack.instantiate()
	newAttack.position = self.position
	newAttack.dmg = self.dmg
	attackObjects.append(newAttack)
	$AttackContainer.add_child(newAttack)
	
	# Set statuses
	$Status.start_stuck(glyphChannelDur)
	$Status.start_phase(glyphChannelDur)
	
	# Start timers
	$AttackCooldownTimer.start(asp * randf_range(glyphCooldownMin, glyphCooldownMax) + random_variance())

func _on_cursed_reset_timer_timeout() -> void:
	isCursed = true
	$Status.start_weak(curseDuration)
