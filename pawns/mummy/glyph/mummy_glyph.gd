extends "res://pawns/_base/attacks/base_attack.gd"

var channelDuration
var glyphDuration

func _ready() -> void:
	super()
	set_up_glyph_visual_effect()
	randomize_glyph_directions()
	z_index = get_node("/root/main").layerArena
	$ChannelDurationTimer.start(channelDuration)
	$FizzleTimer.start(glyphDuration)
func set_up_glyph_visual_effect() -> void:
	set_collision_layer_value(2, false)
	modulate.a = 0.0
	scale = Vector2.ONE
	$GlyphCenterSprite.scale = Vector2.ONE * 0.9
func randomize_glyph_directions() -> void:
	$BaseSprite.rotation = randf_range(0, TAU)
	if randi_range(0, 1) == 0:
		get_parent().get_parent().glyphInnerRotationSpeed *= -1
	else:
		get_parent().get_parent().glyphOuterRotationSpeed *= -1

func _physics_process(delta: float) -> void:
	adjust_glyph_alpha()
	adjust_glyph_rotation(delta)
func adjust_glyph_alpha() -> void:
	var spriteAlpha = 1.0
	if $FizzleTimer.get_time_left() > 1:
		spriteAlpha = 0.25 * (1 - ($FizzleTimer.get_time_left()-1) / ($FizzleTimer.get_wait_time()-1))
	else:
		spriteAlpha = $FizzleTimer.get_time_left()
	modulate.a = spriteAlpha
func adjust_glyph_rotation(delta) -> void:
	$GlyphInnerSprite.rotation += get_parent().get_parent().glyphInnerRotationSpeed * delta
	$GlyphOuterSprite.rotation += get_parent().get_parent().glyphOuterRotationSpeed * delta

func _on_fizzle_timer_timeout() -> void:
	queue_free()
func _on_channel_duration_timer_timeout() -> void:
	set_collision_layer_value(2, true)
