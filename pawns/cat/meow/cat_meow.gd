extends "res://pawns/_base/attack/base_attack.gd"

var direction
var speed
var speedMin = 50
var speedMax = 75
var durationMin = 3.0
var durationMax = 5.0

func _ready() -> void:
	attackName = "Meow"
	areaAttack = false
	speed = randf_range(speedMin, speedMax)
	$FizzleTimer.start(randf_range(durationMin, durationMax))
	$BaseSprite.modulate = Color(randf(), randf(), randf())

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_fizzle_timer_timeout() -> void:
	queue_free()
