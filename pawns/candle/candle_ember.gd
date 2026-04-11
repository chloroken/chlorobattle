extends Node2D

func _ready() -> void:
	scale.x = 1.0
	scale.y = 1.0

func _process(_delta: float) -> void:
	var timerRatio = $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()
	scale.x = 2 - timerRatio
	scale.y = 2 - timerRatio
	#$CandleEmberSprite.modulate.a = max(0.25, timerRatio)

func _on_fizzle_timer_timeout() -> void:
	queue_free()
