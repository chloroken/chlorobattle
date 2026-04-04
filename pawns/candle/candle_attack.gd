extends "res://pawns/base/base_attack.gd"

# Clean up
func _on_fizzle_timer_timeout() -> void:
	self.queue_free()
