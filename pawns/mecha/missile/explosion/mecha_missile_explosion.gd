extends "res://pawns/_base/attacks/base_attack.gd"

func _ready() -> void:
	super()
	scale = Vector2.ZERO
	rotation = randf_range(0, TAU)
	z_index = get_node("/root/main").layerPawnFront

func _process(_delta: float) -> void:
	var fizzleRatio = $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()
	adjust_explosion_alpha(fizzleRatio)
	var scaleRatio = 1 - fizzleRatio
	adjust_explosion_scale(scaleRatio)
func adjust_explosion_alpha(amount) -> void:
	$BaseSprite.modulate.a = amount
func adjust_explosion_scale(amount) -> void:
	scale = Vector2.ONE * amount

func _on_fizzle_timer_timeout() -> void:
	self.queue_free()
