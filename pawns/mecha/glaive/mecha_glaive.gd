extends "res://pawns/_base/attacks/base_attack.gd"

var rotationSpeed

func _ready() -> void:
	super()
	scale = Vector2.ZERO * 1.5

func _physics_process(delta: float) -> void:
	position = basePawn.position
	adjust_glaive_alpha()
	adjust_glaive_scale()
	adjust_glaive_rotation(delta)
func adjust_glaive_alpha() -> void:
	$BaseSprite.modulate.a = $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()
func adjust_glaive_scale() -> void:
	scale = Vector2.ONE * (1.5 - $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time())
func adjust_glaive_rotation(delta) -> void:
	rotation += rotationSpeed * delta

func _on_fizzle_timer_timeout() -> void:
	self.queue_free()
