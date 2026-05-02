extends "res://pawns/base/attack/base_attack.gd"

var chanceToMixUp = 10
var mixUpHealAmount = 0.1
var isMixedUp = false
var basePawn

func _ready() -> void:
	basePawn = get_parent().get_parent()
	isPotionAttack = true
	dmg = 0
	rotation = randf_range(0, TAU)
	scale = Vector2.ZERO

	# Chance to mix up
	var diceRoll = randi_range(1, 100)
	if diceRoll <= chanceToMixUp:
		isMixedUp = true
		$ItemPotionFumeSprite.modulate.r = 0.1
		$ItemPotionFumeSprite.modulate.g = randf_range(0.2, 0.4)
		$ItemPotionFumeSprite.modulate.b = randf_range(0.8, 1.0)
	else:
		$ItemPotionFumeSprite.modulate.r = randf_range(0.2, 0.4)
		$ItemPotionFumeSprite.modulate.g = randf_range(0.8, 1.0)
		$ItemPotionFumeSprite.modulate.b = 0.1

	# Set visibility order
	z_as_relative = false
	z_index = get_node("/root/main").layerArena
	
	# Start timers
	$FizzleTimer.start(basePawn.get_node("Items").potionFumeDuration)

func _process(_delta: float) -> void:
	var timer = $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()
	var timerRatio = 1 - timer
	var pawnItems = basePawn.get_node("Items")
	scale = Vector2.ONE * pawnItems.potionScaleMax * timerRatio
	if timer < 0.25:
		$ItemPotionFumeSprite.modulate.a = timer * 4

func _on_fizzle_timer_timeout() -> void:
	queue_free()
