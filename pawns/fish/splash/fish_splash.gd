extends "res://pawns/_base/base_attack.gd"

var scaleMod
var dur
var tintAmount = 0.5

func _ready() -> void:
	rotation = randf_range(0, TAU)
	scale = Vector2.ONE * scaleMod
	randomize_splash_color()
	z_index = get_node("/root/main").layerArena
	$FizzleTimer.start(dur)

func randomize_splash_color() -> void:
	modulate.r = randf_range(tintAmount, 1.0)
	modulate.g = randf_range(tintAmount, 1.0)

func _physics_process(_delta: float) -> void:
	var fizzleRatio = $FizzleTimer.get_time_left() / $FizzleTimer.get_wait_time()
	var scaleAmount = scaleMod + scaleMod * (1 - fizzleRatio)
	scale = Vector2.ONE * scaleAmount

func _on_fizzle_timer_timeout() -> void:
	self.queue_free()
