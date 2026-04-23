extends "res://pawns/base/base_pawn.gd"

# Candle attack variables
@export var candleAttack: PackedScene
var attackCooldownMin = 0.1
var attackCooldownNormal = 1.0
var attackCooldownMax = 2.0

# Ember variables
@export var emberObject: PackedScene
var emberSpawnCooldownMax = 5.0
var emberSpawnCooldownMin = 4.0
var emberPositionOffset = 50
var emberScale = 0.5

func _ready() -> void:
	super()

	$EmberSpawnTimer.one_shot = true
	if !attacksDisabled:
		start_ember_cooldown()
		start_attack_cooldown()

func _on_attack_cooldown_timer_timeout() -> void:
	start_attack_cooldown()
	if disarm_check(): return

	# Flicker around Candle
	var newAttack = candleAttack.instantiate()
	newAttack.position = self.position
	newAttack.dmg = self.dmg
	attackObjects.append(newAttack)
	$AttackContainer.add_child(newAttack)
	
	# Flicker around embers
	for child in $EmberContainer.get_children():
		var newEmberAttack = candleAttack.instantiate()
		newEmberAttack.position = child.position
		newEmberAttack.dmg = self.dmg
		newEmberAttack.emberFlicker = true
		newEmberAttack.scale.x = emberScale
		newEmberAttack.scale.y = emberScale
		newEmberAttack.isPersistentSummon = true
		attackObjects.append(newEmberAttack)
		$AttackContainer.add_child(newEmberAttack)

func start_attack_cooldown() -> void:
	$AttackCooldownTimer.start(asp * calculate_flicker_cooldown())

func calculate_flicker_cooldown() -> float:
	var missingHealthPercent = 1 - hp / baseHp
	var dwindlingCooldown = attackCooldownMax * missingHealthPercent
	var actualMaxCooldown = max(attackCooldownNormal, dwindlingCooldown)
	var flickerRange = randf_range(attackCooldownMin, actualMaxCooldown)
	return(flickerRange)

# Embers
func start_ember_cooldown() -> void:
	$EmberSpawnTimer.start(asp * randf_range(emberSpawnCooldownMin, emberSpawnCooldownMax))

func _on_ember_spawn_timer_timeout() -> void:
	if attacksDisabled: return
	var newEmber = emberObject.instantiate()
	newEmber.position = good_ember_position()
	attackObjects.append(newEmber)
	$EmberContainer.add_child(newEmber)
	start_ember_cooldown()

func good_ember_position() -> Vector2:
	var newPos = try_ember_position()
	while newPos.distance_to(center) > get_parent().boardRadius:
		newPos = try_ember_position()
	return(newPos)

func try_ember_position() -> Vector2:
	var offsetX = randf_range(-emberPositionOffset, emberPositionOffset)
	var offsetY = randf_range(-emberPositionOffset, emberPositionOffset)
	return(position + Vector2(offsetX, offsetY))
