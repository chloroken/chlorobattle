extends "res://pawns/base/base_pawn.gd"

@export var candleAttack: PackedScene
@export var emberObject: PackedScene

var emberSpawnCooldownMax = 5.0
var emberSpawnCooldownMin = 1.0
var emberPositionOffset = 50

func _on_attack_cooldown_timer_timeout() -> void:
	var newAttack = candleAttack.instantiate()
	newAttack.position = self.position
	newAttack.dmg = self.dmg
	attackObjects.append(newAttack)
	$AttackContainer.add_child(newAttack)

	for child in $EmberContainer.get_children():
		var newEmberAttack = candleAttack.instantiate()
		newEmberAttack.position = child.position
		newEmberAttack.dmg = self.dmg
		newEmberAttack.emberFlicker = true
		newEmberAttack.isPersistentSummon = true
		newEmberAttack.scale.x = 0.5
		newEmberAttack.scale.y = 0.5
		attackObjects.append(newEmberAttack)
		$AttackContainer.add_child(newEmberAttack)

	# Slow attack rate from (0.1 ~ 1.0) to (0.1 ~ 2.0)
	# starting from half hitpoints down to none
	var flickerRange = randf_range(0.1, 2.0 * max(0.5, (1 - hp / baseHp)))
	$AttackCooldownTimer.start(asp * flickerRange)

func _on_ember_spawn_timer_timeout() -> void:
	if attacksDisabled: return
	var newEmber = emberObject.instantiate()

	var newPos = position + Vector2(randf_range(-emberPositionOffset, emberPositionOffset), randf_range(-emberPositionOffset, emberPositionOffset))
	while newPos.distance_to(center) > get_parent().boardRadius:
		newPos = position + Vector2(randf_range(-emberPositionOffset, emberPositionOffset), randf_range(-emberPositionOffset, emberPositionOffset))
	newEmber.position = newPos

	attackObjects.append(newEmber)
	$EmberContainer.add_child(newEmber)
	$EmberSpawnTimer.start(randf_range(emberSpawnCooldownMin, emberSpawnCooldownMax) + random_variance())
