extends "res://pawns/base/base_attack.gd"

@export var purpleAttack: Resource

var innerRotateSpeed = .25
var outerRotateSpeed = .50

func _ready() -> void:
	$BaseSprite.rotation = randf_range(0, TAU)
	set_collision_layer_value(1, false)
	modulate.a = 0.0
	scale.x = 2.0
	scale.y = 2.0
	$GlyphCenterSprite.scale.x = 0.9
	$GlyphCenterSprite.scale.y = 0.9

	# Randomize glyph spin directions
	if randi_range(0, 1) == 0:
		innerRotateSpeed *= -1
	else:
		outerRotateSpeed *= -1

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
	$GlyphInnerSprite.rotation += innerRotateSpeed * delta
	$GlyphOuterSprite.rotation += outerRotateSpeed * delta

	# Grow inner purple thingy
	#$GlyphCenterSprite.modulate.a = 1.0
	#$GlyphCenterSprite.scale.x = 1 - ($FizzleTimer.get_time_left()-1) / ($FizzleTimer.get_wait_time()-1)
	#$GlyphCenterSprite.scale.y = 1 - ($FizzleTimer.get_time_left()-1) / ($FizzleTimer.get_wait_time()-1)

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
