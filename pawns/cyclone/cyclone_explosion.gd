extends "res://pawns/base/base_attack.gd"

func _ready() -> void:
	rotation = randf_range(0, TAU)
	scale.x = 0
	scale.y = 0

func _process(_delta: float) -> void:
	$BaseSprite.modulate.a = $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()
	scale.x = 1 - $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()
	scale.y = 1 - $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()

# Clean up
func _on_fizzle_timer_timeout() -> void:
	self.queue_free()
