extends "res://pawns/base/attack/base_attack.gd"

var chanceToMixUp = 10
var mixUpHealAmount = 0.1
var isMixedUp = false

func _ready() -> void:
	isVialAttack = true
	dmg = 0
	rotation = randf_range(0, TAU)

	# Chance to mix up
	var diceRoll = randi_range(1, 100)
	if diceRoll <= chanceToMixUp:
		isMixedUp = true
		$ItemVialPoolSprite.modulate.r = randf_range(0.2, 0.4)
		$ItemVialPoolSprite.modulate.g = randf_range(0.3, 0.5)
		$ItemVialPoolSprite.modulate.b = randf_range(0.6, 0.8)
	else:
		# not m ixing up
		$ItemVialPoolSprite.modulate.r = randf_range(0.4, 0.6)
		$ItemVialPoolSprite.modulate.g = randf_range(0.8, 1.0)
		$ItemVialPoolSprite.modulate.b = randf_range(0.4, 0.6)

	# Set visibility order
	z_as_relative = false
	z_index = get_node("/root/main").layerArena

func _on_fizzle_timer_timeout() -> void:
	queue_free()
