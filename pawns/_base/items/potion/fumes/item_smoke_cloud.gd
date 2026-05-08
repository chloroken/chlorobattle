extends "res://pawns/_base/items/_attack/item_attack.gd"

var fumeCooldownMin = 0.1
var fumeCooldownMax = 1.0
var basePawn

func _ready() -> void:
	attackName = "Potion"
	basePawn = get_parent().get_parent()
	isSmokeAttack = true
	dmg = basePawn.get_node("Items").smokeDamage
	rotation = randf_range(0, TAU)
	scale = Vector2.ZERO
	$Sprite.modulate.a = 0.5

	# Set visibility order
	z_as_relative = false
	z_index = get_node("/root/main").layerAir

	# Start timers
	$FizzleTimer.start(basePawn.get_node("Items").smokeFumeDuration)

func _process(_delta: float) -> void:
	var timer = $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()
	var timerRatio = 1 - timer
	var pawnItems = basePawn.get_node("Items")
	scale = Vector2.ONE * pawnItems.smokeScaleMax * timerRatio
	if timer < 0.25:
		$Sprite.modulate.a = timer * 2

func _on_fizzle_timer_timeout() -> void:
	queue_free()
