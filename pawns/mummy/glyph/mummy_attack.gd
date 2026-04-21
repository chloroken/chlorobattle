extends "res://pawns/base/base_attack.gd"

@export var purpleAttack: Resource

func _ready() -> void:
	
	# Turn off collision while channeling
	set_collision_layer_value(1, false)

	# Set random direction
	$BaseSprite.rotation = randf_range(0, TAU)

	# Prepare visuals for channeling
	modulate.a = 0.0
	scale.x = 2.0
	scale.y = 2.0
	$GlyphCenterSprite.scale.x = 0.9
	$GlyphCenterSprite.scale.y = 0.9

	# Randomize glyph spin directions
	if randi_range(0, 1) == 0:
		get_parent().get_parent().innerRotateSpeed *= -1
	else:
		get_parent().get_parent().outerRotateSpeed *= -1

	# Set visibility order
	z_as_relative = false
	z_index = get_node("/root/main").layerArena
	
	# Set timers
	$PurpleAttackTimer.one_shot = true
	$PurpleAttackTimer.start(get_parent().get_parent().glyphChannelDur)
	$FizzleTimer.start(get_parent().get_parent().glyphAttackDur)

func _process(delta: float) -> void:
	
	# Fade in opacity
	var spriteAlpha = 1.0
	if $FizzleTimer.get_time_left() > 1:
		spriteAlpha = 0.25 * (1 - ($FizzleTimer.get_time_left()-1) / ($FizzleTimer.get_wait_time()-1))
	else:
		set_collision_layer_value(1, true)
		spriteAlpha = $FizzleTimer.get_time_left()
	modulate.a = spriteAlpha

	# Rotate glyphs
	$GlyphInnerSprite.rotation += get_parent().get_parent().innerRotateSpeed * delta
	$GlyphOuterSprite.rotation += get_parent().get_parent().outerRotateSpeed * delta

func _on_fizzle_timer_timeout() -> void:
	queue_free()

func _on_purple_attack_timer_timeout() -> void:
	var pawnParent = get_parent().get_parent()
	var newAttack = purpleAttack.instantiate()
	newAttack.position = self.position
	newAttack.dmg = pawnParent.dmg
	pawnParent.attackObjects.append(newAttack)
	add_sibling(newAttack)
	$GlyphCenterSprite.modulate.a = 0
