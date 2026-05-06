extends "res://items/_base/_attack/item_attack.gd"

@export var fumeHeal: Resource
var fumeCooldownMin = 0.1
var fumeCooldownMax = 1.0
var fumeHealOffset = 4
var chanceToMixUp = 10
var mixUpHealAmount = 0.1
var isMixedUp = false
var basePawn

func _ready() -> void:
	attackName = "Potion"
	basePawn = get_parent().get_parent()
	isPotionAttack = true
	dmg = basePawn.get_node("Items").potionDamage
	rotation = randf_range(0, TAU)
	scale = Vector2.ZERO
	$Sprite.modulate.a = 0.5

	# Chance to mix up
	var diceRoll = randi_range(1, 100)
	if diceRoll <= chanceToMixUp:
		isMixedUp = true
		dmg = 0
		$Sprite.modulate.r = 0.1
		$Sprite.modulate.g = randf_range(0.2, 0.4)
		$Sprite.modulate.b = randf_range(0.8, 1.0)
		$HealTimer.one_shot = true
		$HealTimer.start(randf_range(fumeCooldownMin, fumeCooldownMax))
	else:
		$Sprite.modulate.r = randf_range(0.2, 0.4)
		$Sprite.modulate.g = randf_range(0.8, 1.0)
		$Sprite.modulate.b = 0.1

	# Set visibility order
	z_as_relative = false
	z_index = get_node("/root/main").layerAir

	# Start timers
	$FizzleTimer.start(basePawn.get_node("Items").potionFumeDuration)

func _process(_delta: float) -> void:
	var timer = $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()
	var timerRatio = 1 - timer
	var pawnItems = basePawn.get_node("Items")
	scale = Vector2.ONE * pawnItems.potionScaleMax * timerRatio
	if timer < 0.25:
		$Sprite.modulate.a = timer * 2

func _on_fizzle_timer_timeout() -> void:
	queue_free()

func _on_heal_timer_timeout() -> void:
	var newHeal = fumeHeal.instantiate()
	var offset = Vector2(randf_range(-fumeHealOffset, fumeHealOffset), randf_range(-fumeHealOffset, fumeHealOffset))
	newHeal.position = position + offset
	add_sibling(newHeal)
	$HealTimer.start(randf_range(fumeCooldownMin, fumeCooldownMax))
