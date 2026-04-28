extends "res://pawns/base/base_attack.gd"

func _ready() -> void:	
	isVialAttack = true
	dmg = 0
	rotation = randf_range(0, TAU)
	
	$ItemVialPoolSprite.modulate.r = randf_range(0.4, 0.6)
	$ItemVialPoolSprite.modulate.g = randf_range(0.8, 1.0)
	$ItemVialPoolSprite.modulate.b = randf_range(0.4, 0.6)
	
	# Set visibility order
	z_as_relative = false
	z_index = get_node("/root/main").layerArena

func _on_fizzle_timer_timeout() -> void:
	queue_free()
