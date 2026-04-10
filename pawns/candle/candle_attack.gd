extends "res://pawns/base/base_attack.gd"

func _ready() -> void:
	# Randomize flicker size & color
	scale *= randf_range(1.0, 1.5)
	$BaseSprite.modulate.b *= randf_range(0.5, 1.0)
	$BaseSprite.modulate.g *= randf_range(0.5, 1.0)

	# Become more transparent as Pawn loses hitpoints
	$BaseSprite.modulate.a = max(0.1, 0.5 * get_parent().get_parent().hp / get_parent().get_parent().baseHp)

# Gracefully phase out flicker
func _physics_process(_delta: float) -> void:
	position = get_parent().get_parent().position
	$BaseSprite.modulate.a *= .9
	$OutlineSprite.modulate.a *= .9

# Clean up
func _on_fizzle_timer_timeout() -> void:
	self.queue_free()
