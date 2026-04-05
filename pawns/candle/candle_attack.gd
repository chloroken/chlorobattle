extends "res://pawns/base/base_attack.gd"

func _physics_process(delta: float) -> void:
	$BaseSprite.modulate.a = 0.1 * $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()

# Clean up
func _on_fizzle_timer_timeout() -> void:
	self.queue_free()
