extends "res://pawns/base/base_pawn.gd"

# Ember
@export var nemberAttack: PackedScene
var nemberCooldownMin = 0.1
var nemberCooldownMax = 1.0
var nemberScale = 1.0
var nemberDurationMin = 2.0
var nemberDurationMax = 3.0
var nemberDestination
var emberPositionOffset = 50
var nemberThrowDistMod = 1
var emberBurnDuration = 5.0

func _ready() -> void:
	super()

	if !attacksDisabled:
		start_attack_cooldown()

func _on_attack_cooldown_timer_timeout() -> void:
	start_attack_cooldown()
	if disarm_check(): return

	# Nember Attack
	var newAttack = nemberAttack.instantiate()
	newAttack.position = position
	newAttack.destination = good_ember_position()
	newAttack.dmg = self.dmg
	newAttack.attackName = "Ember"

	attackObjects.append(newAttack)
	$AttackContainer.add_child(newAttack)

func start_attack_cooldown() -> void:
	$AttackCooldownTimer.start(randf_range(nemberCooldownMin, nemberCooldownMax))

func good_ember_position() -> Vector2:
	var newPos = try_ember_position(false)
	var maxTries = 0

	# Try to find a position in front of Candle
	while maxTries < 10 && newPos.distance_to(center) > get_parent().boardRadius:
		newPos = try_ember_position(false)
		maxTries += 1

	# Otherwise find a position around Candle
	if newPos.distance_to(center) > get_parent().boardRadius:
		while newPos.distance_to(center) > get_parent().boardRadius:
			newPos = try_ember_position(true)

	return(newPos)

func try_ember_position(centered) -> Vector2:
	var offsetX = randf_range(-emberPositionOffset, emberPositionOffset)
	var offsetY = randf_range(-emberPositionOffset, emberPositionOffset)
	var mod = Vector2.ZERO
	if !centered: mod = direction * spd * statusSpdMod * nemberThrowDistMod
	return(position + mod + Vector2(offsetX, offsetY))
